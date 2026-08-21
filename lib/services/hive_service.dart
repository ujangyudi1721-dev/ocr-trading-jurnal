import 'package:hive/hive.dart';

import '../models/trade_model.dart';
import '../models/account_transaction_model.dart';
import '../utils/app_logger.dart';

/// Lapisan akses ke database lokal (Hive).
///
/// Semua baca/tulis ke Hive box (`trades` dan `account_transactions`)
/// harus lewat sini, bukan dipanggil langsung dari halaman/service lain
/// — supaya nama box & cara buka box hanya didefinisikan di satu tempat.
class HiveService {
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

    await box.add(trade);
  }

  /// Ambil semua trade yang tersimpan.
  static Future<List<TradeModel>> getTrades() async {
    final box = await openTradeBox();

    return box.values.toList();
  }

  /// Hapus satu trade berdasarkan posisinya di box.
  static Future<void> deleteTrade(int index) async {
    final box = await openTradeBox();

    await box.deleteAt(index);
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

    await box.add(tx);

    AppLogger.log("SAVE ACCOUNT SUCCES");
  }

  /// Ambil semua transaksi akun yang tersimpan.
  static Future<List<AccountTransactionModel>> getAccountTransactions() async {
    final box = await openAccountBox();

    return box.values.toList();
  }

  /// Hapus satu transaksi akun tertentu.
  static Future deleteAccountTransaction(AccountTransactionModel tx) async {
    await tx.delete();
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
  static Future<void> clearAll() async {
    await clearTrades();

    await clearAccountTransactions();
  }
}
