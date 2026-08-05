import '../models/trade_model.dart';

class TradeValidator {

  static bool isValid(
    TradeModel trade,
  ) {

    if (trade.ticket == "UNKNOWN") {
      return false;
    }

    if (trade.pair == "UNKNOWN") {
      return false;
    }

    return true;
  }
}