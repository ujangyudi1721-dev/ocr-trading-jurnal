import '../models/account_summary_model.dart';
import '../models/account_transaction_model.dart';
import '../models/trade_model.dart';

class AccountStatisticService {
  static AccountSummaryModel calculate(
    List<AccountTransactionModel> transactions,
    List<TradeModel> trades,
  ) {

    double deposit = 0;
    double withdraw = 0;
    double netProfit = 0;

    for (final tx in transactions) {

      if (tx.type == "Deposit") {
        deposit += tx.amount;
      }

      if (tx.type == "Withdraw") {
        withdraw += tx.amount;
      }
    }

    for (final trade in trades) {

      final profit =
          double.tryParse(
            trade.profit.replaceAll("+", ""),
          ) ??
          0;

      netProfit += profit;
    }

    return AccountSummaryModel(
      totalDeposit: deposit,
      totalWithdraw: withdraw,
      balance:
          deposit -
          withdraw +
          netProfit,
    );
  }
}