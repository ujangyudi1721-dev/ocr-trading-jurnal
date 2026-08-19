import 'package:hive/hive.dart';

import '../models/trade_model.dart';
import '../models/account_transaction_model.dart';

class HiveService {
  // ==========================================
  // BOX NAMES
  // ==========================================

  static const String tradeBox = "trades";

  static const String accountBox = "account_transactions";

  // ==========================================
  // TRADE
  // ==========================================

  static Future<Box<TradeModel>> openTradeBox() async {
    return await Hive.openBox<TradeModel>(tradeBox);
  }

  static Future<void> saveTrade(TradeModel trade) async {
    final box = await openTradeBox();

    await box.add(trade);
  }

  static Future<List<TradeModel>> getTrades() async {
    final box = await openTradeBox();

    return box.values.toList();
  }

  static Future<void> deleteTrade(int index) async {
    final box = await openTradeBox();

    await box.deleteAt(index);
  }

  static Future<void> clearTrades() async {
    final box = await openTradeBox();

    await box.clear();
  }

  // ==========================================
  // ACCOUNT TRANSACTION
  // ==========================================

  static Future<Box<AccountTransactionModel>> openAccountBox() async {
    return await Hive.openBox<AccountTransactionModel>(accountBox);
  }

  static Future<void> saveAccountTransaction(AccountTransactionModel tx) async {
    print("SAVE ACCOUNT START");

    final box = await openAccountBox();

    await box.add(tx);

    print("SAVE ACCOUNT SUCCES");
  }

  static Future<List<AccountTransactionModel>> getAccountTransactions() async {
    final box = await openAccountBox();

    return box.values.toList();
  }

  static Future deleteAccountTransaction(AccountTransactionModel tx) async {
    await tx.delete();
  }

  static Future<void> clearAccountTransactions() async {
    final box = await openAccountBox();

    await box.clear();
  }

  // ==========================================
  // RESET SEMUA DATA
  // ==========================================

  static Future<void> clearAll() async {
    await clearTrades();

    await clearAccountTransactions();
  }
}
