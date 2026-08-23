import 'dart:async';

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/trade_model.dart';
import '../models/account_transaction_model.dart';
import '../utils/app_logger.dart';
import 'sync_service.dart';

/// Lapisan akses ke database lokal (Hive).
///
/// Semua baca/tulis ke Hive box (`trades` dan `account_transactions`)
/// harus lewat sini, bukan dipanggil langsung dari halaman/service lain
/// — supaya nama box & cara buka box hanya didefinisikan di satu tempat.
///
/// Tiap simpan/hapus juga memberi `remoteId`+`updatedAt` pada row (kalau
/// belum ada) lalu memicu push ke Supabase lewat [SyncService] secara
/// best-effort (`unawaited`, tidak pernah menggagalkan write lokal kalau
/// offline — lihat dokumentasi [SyncService]).
class HiveService {
  static const _uuid = Uuid();

  // ==========================================
  // BOX NAMES
  // ==========================================

  static const String tradeBox = "trades";

  static const String accountBox = "account_transactions";

  // ==========================================
  // TRADE
  // ==========================================

  /// Buka (atau ambil yang sudah terbuka) box penyimpanan trade.
  static Future<Box<TradeModel>> openTradeBox() async {
    return await Hive.openBox<TradeModel>(tradeBox);
  }

  /// Simpan satu trade baru ke database.
  static Future<void> saveTrade(TradeModel trade) async {
    final box = await openTradeBox();

    trade.remoteId ??= _uuid.v4();
    trade.updatedAt = DateTime.now();

    await box.add(trade);

    unawaited(SyncService.pushTrade(trade));
  }

  /// Ambil semua trade yang tersimpan.
  static Future<List<TradeModel>> getTrades() async {
    final box = await openTradeBox();

    return box.values.toList();
  }

  /// Hapus satu trade tertentu. Pakai referensi objeknya langsung (bukan
  /// index) supaya tetap benar walau posisi trade di box bergeser akibat
  /// insert dari sync.
  static Future<void> deleteTrade(TradeModel trade) async {
    final remoteId = trade.remoteId;

    await trade.delete();

    if (remoteId != null) {
      unawaited(SyncService.deleteRemoteTrade(remoteId));
    }
  }

  /// Hapus seluruh data trade.
  static Future<void> clearTrades() async {
    final box = await openTradeBox();

    await box.clear();
  }

  // ==========================================
  // ACCOUNT TRANSACTION
  // ==========================================

  /// Buka (atau ambil yang sudah terbuka) box transaksi akun
  /// (Deposit/Withdraw manual).
  static Future<Box<AccountTransactionModel>> openAccountBox() async {
    return await Hive.openBox<AccountTransactionModel>(accountBox);
  }

  /// Simpan satu transaksi akun (Deposit/Withdraw) baru.
  static Future<void> saveAccountTransaction(AccountTransactionModel tx) async {
    AppLogger.log("SAVE ACCOUNT START");

    final box = await openAccountBox();

    tx.remoteId ??= _uuid.v4();
    tx.updatedAt = DateTime.now();

    await box.add(tx);

    unawaited(SyncService.pushAccountTransaction(tx));

    AppLogger.log("SAVE ACCOUNT SUCCES");
  }

  /// Ambil semua transaksi akun yang tersimpan.
  static Future<List<AccountTransactionModel>> getAccountTransactions() async {
    final box = await openAccountBox();

    return box.values.toList();
  }

  /// Hapus satu transaksi akun tertentu.
  static Future deleteAccountTransaction(AccountTransactionModel tx) async {
    final remoteId = tx.remoteId;

    await tx.delete();

    if (remoteId != null) {
      unawaited(SyncService.deleteRemoteAccountTransaction(remoteId));
    }
  }

  /// Hapus seluruh data transaksi akun.
  static Future<void> clearAccountTransactions() async {
    final box = await openAccountBox();

    await box.clear();
  }

  // ==========================================
  // RESET SEMUA DATA
  // ==========================================

  /// Hapus seluruh data aplikasi (trade + transaksi akun).
  /// Dipakai untuk fitur "reset semua data".
  ///
  /// Catatan: ini HANYA menghapus data lokal, tidak mempropagasi hapus
  /// massal ke Supabase — "reset" di device ini tidak dimaksudkan untuk
  /// menghapus backup cloud user.
  static Future<void> clearAll() async {
    await clearTrades();

    await clearAccountTransactions();
  }
}
