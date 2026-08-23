/** Persis `double.toStringAsFixed(2)` di Dart — 2 desimal, tanpa pemisah ribuan. */
export function fmt(n: number): string {
  return n.toFixed(2);
}

export function fmtPercent(n: number, digits = 2): string {
  return `${n.toFixed(digits)}%`;
}
