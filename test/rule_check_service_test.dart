import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_trading_jurnal/models/account_timeline_model.dart';
import 'package:ocr_trading_jurnal/models/rule_violation_model.dart';
import 'package:ocr_trading_jurnal/models/trade_model.dart';
import 'package:ocr_trading_jurnal/services/rule_check_service.dart';

/// A sample XAU/USD sell trade. Change only what you want to test.
TradeModel makeTrade({
  String ticket = '1',
  String sl = '3904.980',
  String profit = '+100.00',
  String openTime = '2026-11-12 20:39:24',
}) {
  return TradeModel(
    ticket: ticket,
    pair: 'XAU/USD',
    type: 'Sell',
    lot: '0.80',
    profit: profit,
    openTime: openTime,
    closeTime: '2026-11-12 20:51:17',
    sl: sl,
    tp: '3888.567',
    openPrice: '3903.980',
    closePrice: '3888.567',
  );
}

void main() {
  // Balance 10,000 before the trades. With 2%, the limit is 200.
  final timeline = [
    AccountTimelineModel(
      date: DateTime(2026, 11, 1),
      type: 'Deposit',
      amount: 10000,
      balance: 10000,
      reference: 'Deposit',
    ),
  ];
  const settings = RuleSettings(maxLossPercent: 2);

  List<RuleId> rulesOf(List<TradeModel> trades) {
    final result = RuleCheckService.check(
      trades: trades,
      timeline: timeline,
      settings: settings,
    );
    return result.map((v) => v.rule).toList();
  }

  test('a good trade has no violation', () {
    // SL distance 1.0 x 0.80 lot x 100 = 80 (below 200)
    expect(rulesOf([makeTrade()]), isEmpty);
  });

  test('no stop loss is detected', () {
    expect(rulesOf([makeTrade(sl: '')]), contains(RuleId.noStopLoss));
  });

  test('stop loss too wide is detected', () {
    // SL distance 6.026 x 0.80 x 100 = 482.08 (above 200)
    expect(rulesOf([makeTrade(sl: '3,910.006')]), contains(RuleId.slTooWide));
  });

  test('a loss over the limit is detected', () {
    expect(
      rulesOf([makeTrade(profit: '-301.30')]),
      contains(RuleId.lossOverLimit),
    );
  });

  test('the 6th trade of a day is overtrading', () {
    final trades = List.generate(
      6,
      (i) => makeTrade(ticket: '$i', openTime: '2026-11-12 0$i:00:00'),
    );
    expect(rulesOf(trades), [RuleId.overtrading]);
  });
}