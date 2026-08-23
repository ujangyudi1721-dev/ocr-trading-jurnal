import 'package:uuid/uuid.dart';

import 'hive_service.dart';
import '../utils/app_logger.dart';

/// Migrasi satu-kali yang jalan di startup, setelah adapter Hive di-register
/// dan sebelum sync pertama dicoba.
///
/// Data trade/transaksi yang sudah ada di device SEBELUM fitur sync ini ada
/// tidak punya `remoteId`. Tanpa backfill ini, setiap kali push dicoba,
/// baris lama itu akan selalu terlihat seperti "baru" (tidak ada id stabil
/// untuk di-upsert) dan bisa menghasilkan duplikat di server tiap retry.
class MigrationService {
  static const _uuid = Uuid();

  /// Isi `remoteId` + `updatedAt` untuk semua trade & transaksi akun yang
  /// belum pernah disentuh proses sync (`remoteId == null`). Aman dipanggil
  /// berkali-kali — baris yang sudah punya `remoteId` dilewati.
  static Future<void> backfillRemoteIds() async {
    final tradeBox = await HiveService.openTradeBox();
    var tradeCount = 0;
    for (final trade in tradeBox.values) {
      if (trade.remoteId == null) {
        trade.remoteId = _uuid.v4();
        trade.updatedAt = DateTime.now();
        await trade.save();
        tradeCount++;
      }
    }

    final accountBox = await HiveService.openAccountBox();
    var accountCount = 0;
    for (final tx in accountBox.values) {
      if (tx.remoteId == null) {
        tx.remoteId = _uuid.v4();
        tx.updatedAt = DateTime.now();
        await tx.save();
        accountCount++;
      }
    }

    if (tradeCount > 0 || accountCount > 0) {
      AppLogger.log(
        'MigrationService: backfilled $tradeCount trade(s), '
        '$accountCount account transaction(s)',
      );
    }
  }
}
