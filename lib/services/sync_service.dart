import '../models/account_transaction_model.dart';
import '../models/trade_model.dart';
import '../utils/app_logger.dart';
import 'hive_service.dart';
import 'settings_service.dart';
import 'supabase_service.dart';

/// Push/pull data lokal <-> Supabase.
///
/// Model konflik: **last-write-wins berbasis `updated_at` yang di-stamp
/// server** (trigger Postgres di `supabase/schema.sql`, bukan jam device).
/// Ini bukan CRDT/merge field-level — kalau dua device edit trade yang sama
/// saat offline, device yang sync terakhir menang penuh. Trade-off ini
/// disengaja untuk personal trading journal, lihat plan.
///
/// Push selalu best-effort: dibungkus try/catch, gagal (mis. offline) tidak
/// pernah melempar ke pemanggil — kegagalan itu akan tertutup sendiri lewat
/// [pullAndReconcile] berikutnya (dipanggil saat login & app resume), asal
/// `updatedAt` lokal sudah di-set sinkron sebelum push dicoba.
///
/// Hapus (dari app manapun, ATAU manual lewat Supabase Dashboard) adalah
/// hard delete di server — barisnya benar-benar hilang, bukan cuma ditandai
/// `deleted_at`. Supaya device lain tetap tahu sebuah baris sudah hilang
/// (termasuk yang dihapus manual di luar app, yang tidak meninggalkan jejak
/// apa pun untuk query delta biasa), [pullAndReconcile] menjalankan pass
/// tambahan: bandingkan seluruh ID yang masih ada di server dengan yang ada
/// di Hive, lalu hapus lokal yang sudah tidak ada di server — lihat
/// `_pruneDeletedRemotely`.
class SyncService {
  static String? get _userId => SupabaseService.currentUser?.id;

  // ==========================================
  // PUSH
  // ==========================================

  static Future<void> pushTrade(TradeModel trade) async {
    final userId = _userId;
    if (userId == null || trade.remoteId == null) return;

    try {
      await SupabaseService.client.from('trades').upsert({
        'id': trade.remoteId,
        'user_id': userId,
        'ticket': trade.ticket,
        'pair': trade.pair,
        'type': trade.type,
        'lot': trade.lot,
        'profit': trade.profit,
        'open_time': trade.openTime,
        'close_time': trade.closeTime,
        'sl': trade.sl,
        'tp': trade.tp,
        'open_price': trade.openPrice,
        'close_price': trade.closePrice,
        'emotion': trade.emotion,
      });
    } catch (e) {
      AppLogger.log('SyncService.pushTrade gagal (akan dicoba lagi saat reconcile): $e');
    }
  }

  static Future<void> deleteRemoteTrade(String remoteId) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      await SupabaseService.client
          .from('trades')
          .delete()
          .eq('id', remoteId)
          .eq('user_id', userId);
    } catch (e) {
      AppLogger.log('SyncService.deleteRemoteTrade gagal: $e');
    }
  }

  static Future<void> pushAccountTransaction(AccountTransactionModel tx) async {
    final userId = _userId;
    if (userId == null || tx.remoteId == null) return;

    try {
      await SupabaseService.client.from('account_transactions').upsert({
        'id': tx.remoteId,
        'user_id': userId,
        'date': tx.date,
        'type': tx.type,
        'amount': tx.amount,
        'note': tx.note,
      });
    } catch (e) {
      AppLogger.log(
        'SyncService.pushAccountTransaction gagal (akan dicoba lagi saat reconcile): $e',
      );
    }
  }

  static Future<void> deleteRemoteAccountTransaction(String remoteId) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      await SupabaseService.client
          .from('account_transactions')
          .delete()
          .eq('id', remoteId)
          .eq('user_id', userId);
    } catch (e) {
      AppLogger.log('SyncService.deleteRemoteAccountTransaction gagal: $e');
    }
  }

  static Future<void> pushSettings({
    required double maxLossPercent,
    required double profitTargetPercent,
  }) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      await SupabaseService.client.from('user_settings').upsert({
        'user_id': userId,
        'max_loss_percent': maxLossPercent,
        'profit_target_percent': profitTargetPercent,
      });
    } catch (e) {
      AppLogger.log('SyncService.pushSettings gagal: $e');
    }
  }

  // ==========================================
  // PULL + RECONCILE
  // ==========================================

  /// Tarik perubahan dari Supabase sejak sync terakhir, gabungkan ke Hive
  /// lokal, lalu push balik baris lokal yang lebih baru dari server (contoh:
  /// edit yang dibuat saat offline). Dipanggil saat login sukses dan saat
  /// `AppLifecycleState.resumed`.
  static Future<void> pullAndReconcile() async {
    final userId = _userId;
    if (userId == null) return;

    final lastSyncedAt =
        await SettingsService.getLastSyncedAt() ?? DateTime.fromMillisecondsSinceEpoch(0);
    final cutoffIso = lastSyncedAt.toIso8601String();
    final syncStartedAt = DateTime.now();

    try {
      await _reconcileTrades(userId, cutoffIso, lastSyncedAt);
      await _reconcileAccountTransactions(userId, cutoffIso, lastSyncedAt);
      await _reconcileSettings(userId);
      await SettingsService.setLastSyncedAt(syncStartedAt);
    } catch (e) {
      AppLogger.log('SyncService.pullAndReconcile gagal: $e');
    }
  }

  static Future<void> _reconcileTrades(
    String userId,
    String cutoffIso,
    DateTime lastSyncedAt,
  ) async {
    final rows = await SupabaseService.client
        .from('trades')
        .select()
        .eq('user_id', userId)
        .gt('updated_at', cutoffIso) as List<dynamic>;

    final box = await HiveService.openTradeBox();
    final justPulled = <String>{};
    var overwroteLocalEdit = false;

    for (final raw in rows) {
      final row = raw as Map<String, dynamic>;
      final remoteId = row['id'] as String;
      final remoteUpdatedAt = DateTime.parse(row['updated_at'] as String);

      TradeModel? local;
      for (final t in box.values) {
        if (t.remoteId == remoteId) {
          local = t;
          break;
        }
      }

      if (local != null && local.updatedAt != null && local.updatedAt!.isAfter(remoteUpdatedAt)) {
        // Edit lokal lebih baru dari yang barusan ditarik — biarkan,
        // akan di-push ulang di pass reconcile di bawah.
        continue;
      }

      if (local != null) {
        final localWasDirty = local.updatedAt != null && local.updatedAt!.isAfter(lastSyncedAt);
        local
          ..ticket = row['ticket'] as String? ?? ''
          ..pair = row['pair'] as String? ?? ''
          ..type = row['type'] as String? ?? ''
          ..lot = row['lot'] as String? ?? ''
          ..profit = row['profit'] as String? ?? ''
          ..openTime = row['open_time'] as String? ?? ''
          ..closeTime = row['close_time'] as String? ?? ''
          ..sl = row['sl'] as String? ?? ''
          ..tp = row['tp'] as String? ?? ''
          ..openPrice = row['open_price'] as String? ?? ''
          ..closePrice = row['close_price'] as String? ?? ''
          ..emotion = row['emotion'] as String?
          ..updatedAt = remoteUpdatedAt;
        await local.save();
        if (localWasDirty) overwroteLocalEdit = true;
      } else {
        await box.add(
          TradeModel(
            ticket: row['ticket'] as String? ?? '',
            pair: row['pair'] as String? ?? '',
            type: row['type'] as String? ?? '',
            lot: row['lot'] as String? ?? '',
            profit: row['profit'] as String? ?? '',
            openTime: row['open_time'] as String? ?? '',
            closeTime: row['close_time'] as String? ?? '',
            sl: row['sl'] as String? ?? '',
            tp: row['tp'] as String? ?? '',
            openPrice: row['open_price'] as String? ?? '',
            closePrice: row['close_price'] as String? ?? '',
            emotion: row['emotion'] as String?,
            remoteId: remoteId,
            updatedAt: remoteUpdatedAt,
          ),
        );
      }
      justPulled.add(remoteId);
    }

    for (final t in box.values.toList()) {
      final id = t.remoteId;
      if (id == null || justPulled.contains(id)) continue;
      if (t.updatedAt == null || !t.updatedAt!.isAfter(lastSyncedAt)) continue;

      await pushTrade(t);
    }

    await _pruneTradesDeletedRemotely(userId, lastSyncedAt);

    if (overwroteLocalEdit) {
      AppLogger.log(
        'SyncService: tersinkron, sebagian perubahan trade lokal mungkin tertimpa data server.',
      );
    }
  }

  /// Hapus trade lokal yang sudah tidak ada di server SAMA SEKALI —
  /// menutup celah baris yang dihapus manual lewat Supabase Dashboard
  /// (hard delete langsung, tidak lewat [deleteRemoteTrade]) sehingga
  /// tidak pernah muncul di query delta biasa.
  ///
  /// Hanya menghapus baris yang `updatedAt`-nya SEBELUM [lastSyncedAt]
  /// (sync sebelumnya) — artinya baris itu sudah pernah berhasil tersinkron
  /// minimal sekali. Ini penting: trade yang baru dibuat offline & belum
  /// sempat ke-push (jadi wajar belum ada di server) TIDAK boleh ikut
  /// terhapus hanya karena "belum ada di server".
  static Future<void> _pruneTradesDeletedRemotely(
    String userId,
    DateTime lastSyncedAt,
  ) async {
    final idRows = await SupabaseService.client
        .from('trades')
        .select('id')
        .eq('user_id', userId) as List<dynamic>;
    final serverIds = idRows.map((r) => (r as Map<String, dynamic>)['id'] as String).toSet();

    final box = await HiveService.openTradeBox();
    for (final t in box.values.toList()) {
      final id = t.remoteId;
      if (id == null || serverIds.contains(id)) continue;
      if (t.updatedAt == null || !t.updatedAt!.isBefore(lastSyncedAt)) continue;

      await t.delete();
    }
  }

  static Future<void> _reconcileAccountTransactions(
    String userId,
    String cutoffIso,
    DateTime lastSyncedAt,
  ) async {
    final rows = await SupabaseService.client
        .from('account_transactions')
        .select()
        .eq('user_id', userId)
        .gt('updated_at', cutoffIso) as List<dynamic>;

    final box = await HiveService.openAccountBox();
    final justPulled = <String>{};
    var overwroteLocalEdit = false;

    for (final raw in rows) {
      final row = raw as Map<String, dynamic>;
      final remoteId = row['id'] as String;
      final remoteUpdatedAt = DateTime.parse(row['updated_at'] as String);

      AccountTransactionModel? local;
      for (final tx in box.values) {
        if (tx.remoteId == remoteId) {
          local = tx;
          break;
        }
      }

      if (local != null && local.updatedAt != null && local.updatedAt!.isAfter(remoteUpdatedAt)) {
        continue;
      }

      if (local != null) {
        final localWasDirty = local.updatedAt != null && local.updatedAt!.isAfter(lastSyncedAt);
        local
          ..date = row['date'] as String? ?? ''
          ..type = row['type'] as String? ?? ''
          ..amount = (row['amount'] as num?)?.toDouble() ?? 0
          ..note = row['note'] as String?
          ..updatedAt = remoteUpdatedAt;
        await local.save();
        if (localWasDirty) overwroteLocalEdit = true;
      } else {
        await box.add(
          AccountTransactionModel(
            date: row['date'] as String? ?? '',
            type: row['type'] as String? ?? '',
            amount: (row['amount'] as num?)?.toDouble() ?? 0,
            note: row['note'] as String?,
            remoteId: remoteId,
            updatedAt: remoteUpdatedAt,
          ),
        );
      }
      justPulled.add(remoteId);
    }

    for (final tx in box.values.toList()) {
      final id = tx.remoteId;
      if (id == null || justPulled.contains(id)) continue;
      if (tx.updatedAt == null || !tx.updatedAt!.isAfter(lastSyncedAt)) continue;

      await pushAccountTransaction(tx);
    }

    await _pruneAccountTransactionsDeletedRemotely(userId, lastSyncedAt);

    if (overwroteLocalEdit) {
      AppLogger.log(
        'SyncService: tersinkron, sebagian perubahan transaksi akun lokal mungkin tertimpa data server.',
      );
    }
  }

  /// Sama seperti [_pruneTradesDeletedRemotely], untuk transaksi akun.
  static Future<void> _pruneAccountTransactionsDeletedRemotely(
    String userId,
    DateTime lastSyncedAt,
  ) async {
    final idRows = await SupabaseService.client
        .from('account_transactions')
        .select('id')
        .eq('user_id', userId) as List<dynamic>;
    final serverIds = idRows.map((r) => (r as Map<String, dynamic>)['id'] as String).toSet();

    final box = await HiveService.openAccountBox();
    for (final tx in box.values.toList()) {
      final id = tx.remoteId;
      if (id == null || serverIds.contains(id)) continue;
      if (tx.updatedAt == null || !tx.updatedAt!.isBefore(lastSyncedAt)) continue;

      await tx.delete();
    }
  }

  static Future<void> _reconcileSettings(String userId) async {
    final rows = await SupabaseService.client
        .from('user_settings')
        .select()
        .eq('user_id', userId)
        .limit(1) as List<dynamic>;

    if (rows.isEmpty) return;

    final row = rows.first as Map<String, dynamic>;
    final maxLoss = (row['max_loss_percent'] as num?)?.toDouble();
    final profitTarget = (row['profit_target_percent'] as num?)?.toDouble();
    if (maxLoss != null && profitTarget != null) {
      await SettingsService.saveRiskLimitLocalOnly(
        maxLossPercent: maxLoss,
        profitTargetPercent: profitTarget,
      );
    }
  }
}
