import 'package:hive/hive.dart';

class HiveService {
  static final Box tradesBox = Hive.box('trades');

  static Future<void> saveTrade(Map<String, dynamic> trade) async {
    await tradesBox.add(trade);
  }

  static List getTrades() {
    return tradesBox.values.toList();
  }

  static Future<void> deleteTrade(int index) async {
    await tradesBox.deleteAt(index);
  }
}