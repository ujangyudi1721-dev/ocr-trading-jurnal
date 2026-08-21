import 'package:hive/hive.dart';
import '../utils/date_helper.dart';

part 'trade_model.g.dart';

/// Satu trade yang sudah selesai (closed), hasil OCR dari screenshot
/// histori trading (lihat `OcrService`/`OcrParser`) yang sudah dikoreksi
/// dan disimpan user. Ini adalah entity utama aplikasi — hampir semua
/// service (analytics, daily report, timeline) diturunkan dari data ini.
///
/// Semua field angka (lot, profit, harga) sengaja disimpan sebagai
/// `String`, bukan `double` — karena datanya berasal dari hasil OCR
/// yang formatnya bisa sedikit tidak konsisten, jadi konversi ke angka
/// dilakukan belakangan (per kebutuhan) di service masing-masing,
/// bukan dipaksakan saat parsing.
///
/// `typeId: 0` untuk Hive harus tetap unik & tidak berubah (lihat juga
/// `AccountTransactionModel` dengan `typeId: 1`).
@HiveType(typeId: 0)
class TradeModel extends HiveObject {
  /// Nomor tiket/ID trade dari platform trading (unik per trade).
  @HiveField(0)
  String ticket;

  /// Pasangan yang ditradingkan, mis. "XAUUSD", "EURUSD".
  @HiveField(1)
  String pair;

  /// Arah trade: "Buy" atau "Sell".
  @HiveField(2)
  String type;

  /// Ukuran lot trade (masih dalam bentuk String hasil OCR).
  @HiveField(3)
  String lot;

  /// Profit/loss trade ini (String, bisa berawalan "+"/"-").
  @HiveField(4)
  String profit;

  /// Waktu buka posisi (String, lihat [openDateTime] untuk versi parsed).
  @HiveField(5)
  String openTime;

  /// Waktu tutup posisi (String, lihat [closeDateTime] untuk versi parsed).
  /// Ini yang dipakai di seluruh app sebagai "tanggal" trade ini terjadi.
  @HiveField(6)
  String closeTime;

  /// Stop loss (harga).
  @HiveField(7)
  String sl;

  /// Take profit (harga).
  @HiveField(8)
  String tp;

  /// Harga saat posisi dibuka.
  @HiveField(9)
  String openPrice;

  /// Harga saat posisi ditutup.
  @HiveField(10)
  String closePrice;

  /// Tag emosi saat trade ini diambil (opsional, dipilih user saat simpan).
  /// Nilainya harus cocok dengan `EmotionOption.key` di [EmotionConstants].
  @HiveField(11)
  String? emotion;

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
    this.emotion,
  });

  /// [openTime] yang sudah di-parse jadi [DateTime].
  /// Return `null` kalau formatnya tidak dikenali oleh [DateHelper.parse].
  DateTime? get openDateTime {
    return DateHelper.parse(openTime);
  }

  /// [closeTime] yang sudah di-parse jadi [DateTime]. Ini tanggal yang
  /// dipakai di seluruh app untuk mengelompokkan trade per hari
  /// (lihat `AccountTimelineService`, `DailyReportPage`).
  DateTime? get closeDateTime {
    return DateHelper.parse(closeTime);
  }
}
