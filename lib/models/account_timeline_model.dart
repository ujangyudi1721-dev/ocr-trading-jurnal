/// Satu baris dalam "timeline akun": gabungan seluruh kejadian yang
/// mengubah saldo (Deposit, Withdraw, atau hasil sebuah Trade),
/// diurutkan berdasarkan tanggal dan dilengkapi saldo berjalan.
///
/// Dibuat oleh `AccountTimelineService.generate()` dari gabungan
/// [AccountTransactionModel] (deposit/withdraw) dan `TradeModel`
/// (hasil trade), lalu dipakai sebagai sumber data untuk laporan
/// harian (`DailyReportService`) dan analytics (`AnalyticsEngine`).
class AccountTimelineModel {
  /// Tanggal kejadian ini terjadi (dari transaksi atau closeTime trade).
  final DateTime date;

  // Deposit / Withdraw / Trade
  final String type;

  // Nilai transaksi
  final double amount;

  // Saldo setelah transaksi
  double balance;

  // Nomor ticket / Deposit / Withdraw
  final String reference;

  // ================================
  // Khusus Trade (Optional)
  // ================================

  final String? pair;

  final String? tradeType;

  final String? emotion;

  AccountTimelineModel({
    required this.date,
    required this.type,
    required this.amount,
    required this.balance,
    required this.reference,
    this.pair,
    this.tradeType,
    this.emotion,
  });
}
