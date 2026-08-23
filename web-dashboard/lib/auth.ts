import "server-only";

import { createHmac, timingSafeEqual } from "node:crypto";

// Password gate sederhana (bukan Supabase Auth) — app ini untuk satu orang,
// jadi cukup 1 password bersama, bukan sistem akun. Sesi ditandai lewat
// cookie yang di-sign HMAC-SHA256, bukan disimpan di server (stateless).
//
// Proxy Next.js 16 default-nya jalan di Node.js runtime (bukan Edge lagi),
// jadi aman pakai `node:crypto` langsung di proxy.ts maupun di sini.
export const SESSION_COOKIE_NAME = "dashboard_session";
const SESSION_MAX_AGE_SECONDS = 60 * 60 * 24 * 30; // 30 hari

function getSecret(): string {
  const secret = process.env.SESSION_SECRET;
  if (!secret) {
    throw new Error("SESSION_SECRET kosong. Isi web-dashboard/.env.local (lihat .env.example).");
  }
  return secret;
}

function sign(payload: string): string {
  return createHmac("sha256", getSecret()).update(payload).digest("hex");
}

/** Buat token sesi baru yang berlaku 30 hari ke depan. */
export function createSessionToken(): string {
  const expiresAt = Date.now() + SESSION_MAX_AGE_SECONDS * 1000;
  const payload = `ok.${expiresAt}`;
  return `${payload}.${sign(payload)}`;
}

/** Verifikasi token dari cookie: signature valid & belum kedaluwarsa. */
export function verifySessionToken(token: string | undefined | null): boolean {
  if (!token) return false;

  const lastDot = token.lastIndexOf(".");
  if (lastDot === -1) return false;

  const payload = token.slice(0, lastDot);
  const signature = token.slice(lastDot + 1);
  const expected = sign(payload);

  const a = Buffer.from(signature, "hex");
  const b = Buffer.from(expected, "hex");
  if (a.length !== b.length || !timingSafeEqual(a, b)) return false;

  const expiresAt = Number.parseInt(payload.split(".")[1] ?? "0", 10);
  return Number.isFinite(expiresAt) && Date.now() < expiresAt;
}

export function checkDashboardPassword(input: string): boolean {
  const expected = process.env.DASHBOARD_PASSWORD;
  if (!expected) {
    throw new Error("DASHBOARD_PASSWORD kosong. Isi web-dashboard/.env.local (lihat .env.example).");
  }

  const a = Buffer.from(input);
  const b = Buffer.from(expected);
  // Panjang beda = pasti salah, tapi tetap bandingkan sesuatu bertimbang
  // waktu supaya panjang password tidak bocor lewat timing.
  if (a.length !== b.length) {
    timingSafeEqual(Buffer.from(expected), Buffer.from(expected));
    return false;
  }
  return timingSafeEqual(a, b);
}

export const SESSION_COOKIE_OPTIONS = {
  httpOnly: true,
  secure: process.env.NODE_ENV === "production",
  sameSite: "lax" as const,
  path: "/",
  maxAge: SESSION_MAX_AGE_SECONDS,
};
