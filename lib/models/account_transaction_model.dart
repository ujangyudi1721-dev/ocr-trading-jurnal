import 'package:hive/hive.dart';
import '../utils/date_helper.dart';

part 'account_transaction_model.g.dart';

/// Satu transaksi akun manual (Deposit atau Withdraw) yang diinput
/// user sendiri, tersimpan langsung ke Hive (bukan hasil OCR).
///
/// `typeId: 1` harus tetap unik di seluruh model Hive di aplikasi ini
/// (lihat juga `TradeModel` dengan `typeId: 0`) — jangan diubah setelah
/// ada data tersimpan, karena Hive memakainya untuk tahu class mana
/// yang harus dipakai saat membaca data lama dari disk.
@HiveType(typeId: 1)
class AccountTransactionModel extends HiveObject {
  /// Tanggal transaksi, disimpan sebagai String (lihat [dateTime] untuk
  /// versi ter-parse-nya) — formatnya sama seperti openTime/closeTime.
  @HiveField(0)
  String date;

  /// Jenis transaksi: "Deposit" atau "Withdraw".
  @HiveField(1)
  String type;

  /// Nominal transaksi (selalu positif; tanda +/- ditentukan dari [type]).
  @HiveField(2)
  double amount;

  /// Catatan/keterangan bebas dari user (mis. "TF dari BCA"), `null`/kosong
  /// kalau tidak diisi.
  @HiveField(3)
  String? note;

  /// ID stabil untuk sync ke Supabase (uuid v4, di-generate sekali saat
  /// transaksi pertama kali disimpan / saat backfill data lama). `null`
  /// berarti baris ini belum pernah disentuh proses sync.
  @HiveField(4)
  String? remoteId;

  /// Kapan transaksi ini terakhir diubah secara lokal. Dipakai untuk
  /// keputusan last-write-wins saat sync — harus di-set sinkron setiap kali
  /// ada perubahan lokal, sebelum request ke Supabase dikirim.
  @HiveField(5)
  DateTime? updatedAt;

  /// Kapan transaksi ini dihapus (soft delete, dipropagasi ke device lain
  /// lewat sync). `null` selama transaksi masih aktif.
  @HiveField(6)
  DateTime? deletedAt;

  AccountTransactionModel({
    required this.date,
    required this.type,
    required this.amount,
    this.note,
    this.remoteId,
    this.updatedAt,
    this.deletedAt,
  });

  // ==========================================
  // GETTER DATETIME
  // ==========================================

  /// Versi [date] yang sudah di-parse jadi [DateTime].
  /// Return `null` kalau formatnya tidak dikenali oleh [DateHelper.parse].
  DateTime? get dateTime {
    return DateHelper.parse(date);
  }
}
