// Port dari lib/constants/emotion_constants.dart. `key` HARUS persis sama
// dengan yang tersimpan di kolom trades.emotion (dipilih user di app
// mobile) — hanya label/warna yang berbeda representasinya di sini
// (hex color, bukan Flutter Color/IconData).
export interface EmotionOption {
  key: string;
  label: string;
  color: string;
}

export const EMOTION_OPTIONS: EmotionOption[] = [
  { key: "Tenang", label: "Tenang", color: "#22c55e" }, // green
  { key: "Percaya Diri", label: "Percaya Diri", color: "#3b82f6" }, // blue
  { key: "Serakah", label: "Serakah", color: "#f97316" }, // orange
  { key: "Takut / Ragu", label: "Takut / Ragu", color: "#a855f7" }, // purple
  { key: "FOMO", label: "FOMO", color: "#ef4444" }, // red
  { key: "Balas Dendam", label: "Balas Dendam", color: "#f43f5e" }, // redAccent
  { key: "Bosan", label: "Bosan", color: "#6b7280" }, // grey
];

export function findEmotion(key: string | null | undefined): EmotionOption | undefined {
  if (!key) return undefined;
  return EMOTION_OPTIONS.find((o) => o.key === key);
}
