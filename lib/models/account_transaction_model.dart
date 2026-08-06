import 'package:hive/hive.dart';
import '../utils/date_helper.dart';

part 'account_transaction_model.g.dart';

@HiveType(typeId: 1)
class AccountTransactionModel {
  @HiveField(0)
  String date;

  @HiveField(1)
  String type;

  @HiveField(2)
  double amount;

  AccountTransactionModel({
    required this.date,
    required this.type,
    required this.amount,
  });

  // ==========================================
  // GETTER DATETIME
  // ==========================================

  DateTime? get dateTime {
    return DateHelper.parse(date);
  }
}
