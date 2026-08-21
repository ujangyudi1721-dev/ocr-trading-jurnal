/// Batas risiko harian yang dihitung dari saldo saat ini + persentase
/// yang diset user (lihat `RiskLimitService` & `RiskLimitEditDialog`).
///
/// Dipakai oleh `RiskLimitCard` di Dashboard untuk mengingatkan user
/// kapan harus berhenti trading hari itu (sudah kena batas rugi atau
/// sudah capai target profit).
class RiskLimitModel {
  /// Saldo yang dipakai sebagai dasar perhitungan batas (biasanya
  /// saldo di awal hari/sesi trading).
  final double balance;

  /// Batas maksimal kerugian yang ditoleransi, dalam persen dari [balance].
  final double maxLossPercent;

  /// Target profit yang ingin dicapai, dalam persen dari [balance].
  final double profitTargetPercent;

  /// Versi nominal (bukan persen) dari [maxLossPercent].
  final double maxLossAmount;

  /// Versi nominal (bukan persen) dari [profitTargetPercent].
  final double profitTargetAmount;

  /// Saldo minimum sebelum dianggap kena batas rugi
  /// (= [balance] - [maxLossAmount]).
  final double lossLimitBalance;

  /// Saldo yang menandakan target profit tercapai
  /// (= [balance] + [profitTargetAmount]).
  final double profitTargetBalance;

  RiskLimitModel({
    required this.balance,
    required this.maxLossPercent,
    required this.profitTargetPercent,
    required this.maxLossAmount,
    required this.profitTargetAmount,
    required this.lossLimitBalance,
    required this.profitTargetBalance,
  });
}
