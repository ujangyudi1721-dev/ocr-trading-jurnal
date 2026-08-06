import 'package:hive/hive.dart';
import '../utils/date_helper.dart';

part 'trade_model.g.dart';

@HiveType(typeId: 0)
class TradeModel extends HiveObject {
  @HiveField(0)
  String ticket;

  @HiveField(1)
  String pair;

  @HiveField(2)
  String type;

  @HiveField(3)
  String lot;

  @HiveField(4)
  String profit;

  @HiveField(5)
  String openTime;

  @HiveField(6)
  String closeTime;

  @HiveField(7)
  String sl;

  @HiveField(8)
  String tp;

  @HiveField(9)
  String openPrice;

  @HiveField(10)
  String closePrice;

  TradeModel({
    required this.ticket,
    required this.pair,
    required this.type,
    required this.lot,
    required this.profit,
    required this.openTime,
    required this.closeTime,
    required this.sl,
    required this.tp,
    required this.openPrice,
    required this.closePrice,
  });
  DateTime? get openDateTime {
    return DateHelper.parse(openTime);
  }

  DateTime? get closeDateTime {
    return DateHelper.parse(closeTime);
  }
}
