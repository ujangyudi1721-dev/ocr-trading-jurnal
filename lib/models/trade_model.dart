class TradeModel {
  String ticket;
  String pair;
  String type;
  String lot;
  String profit;

  String openTime;
  String closeTime;

  String sl;
  String tp;

  String openPrice;
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
}
