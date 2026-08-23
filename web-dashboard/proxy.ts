import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";
import { SESSION_COOKIE_NAME, verifySessionToken } from "./lib/auth";

// Next.js 16 renamed `middleware.ts` -> `proxy.ts` (same mechanism, new
// name/export). Defaults to the Node.js runtime, so `node:crypto` in
// lib/auth.ts works fine here.
export function proxy(request: NextRequest) {
  const { pathname } = request.nextUrl;

  if (pathname === "/login" || pathname.startsWith("/_next")) {
    return NextResponse.next();
  }

  const token = request.cookies.get(SESSION_COOKIE_NAME)?.value;
  if (verifySessionToken(token)) {
    return NextResponse.next();
  }

  const loginUrl = new URL("/login", request.url);
  return NextResponse.redirect(loginUrl);
}

export const config = {
  matcher: [
    // Semua route KECUALI asset statis/gambar/favicon.
    "/((?!_next/static|_next/image|favicon.ico).*)",
  ],
};
