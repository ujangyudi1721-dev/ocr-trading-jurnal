/// Ringkasan drawdown akun, dihitung oleh `DrawdownService` dari
/// [AccountTimelineModel] (butuh saldo berjalan/running balance).
///
/// "Drawdown" = seberapa jauh saldo turun dari titik tertinggi
/// (peak) yang pernah dicapai sebelumnya.
class DrawdownModel {
  /// Saldo tertinggi yang pernah dicapai sepanjang timeline.
  final double peakBalance;

  /// Saldo saat ini (titik terakhir di timeline).
  final double currentBalance;

  /// Selisih [peakBalance] - [currentBalance] saat ini (drawdown berjalan).
  final double currentDrawdown;

  /// Drawdown terbesar yang pernah terjadi di sepanjang timeline,
  /// bukan cuma drawdown saat ini.
  final double maximumDrawdown;

  const DrawdownModel({
    required this.peakBalance,
    required this.currentBalance,
    required this.currentDrawdown,
    required this.maximumDrawdown,
  });
}
