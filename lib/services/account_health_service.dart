import '../models/account_health_model.dart';
import '../models/account_summary_model.dart';

class AccountHealthService {

  static AccountHealthModel calculate(
    AccountSummaryModel summary,
  ) {

    double growth = 0;

    if (summary.totalDeposit > 0) {

      growth =
          ((summary.balance -
                      summary.totalDeposit) /
                  summary.totalDeposit) *
              100;
    }

    // sementara drawdown = 0
    // nanti kita hitung dari equity curve

    double drawdown = 0;

    String status = "Normal";

    if (growth >= 20) {
      status = "Excellent";
    } else if (growth >= 10) {
      status = "Good";
    } else if (growth >= 0) {
      status = "Normal";
    } else {
      status = "Warning";
    }

    return AccountHealthModel(
      growth: growth,
      drawdown: drawdown,
      status: status,
    );
  }
}