/// Satu titik pada grafik equity/balance di Dashboard (`EquityChart`).
///
/// [index] dipakai sebagai posisi X (urutan kejadian, bukan tanggal asli)
/// supaya jarak antar titik di grafik selalu rata, dan [balance] sebagai
/// posisi Y (saldo pada titik itu).
class EquityPointModel {
  final int index;

  final double balance;

  EquityPointModel({required this.index, required this.balance});
}
