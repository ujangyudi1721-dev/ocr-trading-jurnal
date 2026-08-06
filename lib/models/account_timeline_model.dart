class AccountTimelineModel {
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

  AccountTimelineModel({
    required this.date,
    required this.type,
    required this.amount,
    required this.balance,
    required this.reference,
    this.pair,
    this.tradeType,
  });
}
