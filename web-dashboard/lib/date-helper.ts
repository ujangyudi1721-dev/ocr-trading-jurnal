// Port 1:1 dari lib/utils/date_helper.dart di app Flutter. Jangan ubah
// aturan parsing di sini tanpa mengubah juga versi Dart-nya — keduanya
// harus selalu membaca format tanggal yang sama persis.

const MONTHS: Record<string, number> = {
  Jan: 1,
  Feb: 2,
  Mar: 3,
  Apr: 4,
  Mei: 5,
  Jun: 6,
  Jul: 7,
  Agu: 8,
  Sep: 9,
  Okt: 10,
  Nov: 11,
  Des: 12,
};

/**
 * Parse tanggal dari 2 format yang dipakai app:
 * 1. ISO: "2026-08-06 08:41:08.572515"
 * 2. OCR: "2 Agu 2026 17.08.15"
 *
 * Return `null` kalau tidak dikenali format manapun — JANGAN fallback ke
 * `new Date()`, sama seperti versi Dart-nya (data dengan tanggal tidak
 * valid harus dilewati, bukan masuk ke timeline dengan tanggal salah).
 */
export function parseDate(text: string): Date | null {
  const trimmed = text.trim();

  // Format ISO
  const iso = new Date(trimmed.replace(" ", "T"));
  if (!Number.isNaN(iso.getTime()) && /^\d{4}-\d{2}-\d{2}/.test(trimmed)) {
    return iso;
  }

  // Format OCR: "2 Agu 2026 17.08.15"
  const parts = trimmed.split(" ");
  if (parts.length < 4) return null;

  const day = Number.parseInt(parts[0], 10);
  const month = MONTHS[parts[1]];
  const year = Number.parseInt(parts[2], 10);

  if (Number.isNaN(day) || month === undefined || Number.isNaN(year)) {
    return null;
  }

  const normalizedTime = parts[3].replaceAll(",", ".");
  const time = normalizedTime.split(".");
  if (time.length !== 3) return null;

  const hour = Number.parseInt(time[0], 10);
  const minute = Number.parseInt(time[1], 10);
  const second = Number.parseInt(time[2], 10);
  if ([hour, minute, second].some((v) => Number.isNaN(v))) return null;

  return new Date(year, month - 1, day, hour, minute, second);
}

function two(value: number): string {
  return value.toString().padStart(2, "0");
}

export function formatDisplay(date: Date): string {
  return `${two(date.getDate())}/${two(date.getMonth() + 1)}/${date.getFullYear()}`;
}

export function formatTime(date: Date): string {
  return `${two(date.getHours())}:${two(date.getMinutes())}:${two(date.getSeconds())}`;
}

export function formatDateTime(date: Date): string {
  return `${formatDisplay(date)} ${formatTime(date)}`;
}
