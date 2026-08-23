"use server";

import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import {
  SESSION_COOKIE_NAME,
  SESSION_COOKIE_OPTIONS,
  checkDashboardPassword,
  createSessionToken,
} from "@/lib/auth";

export interface LoginState {
  error: string | null;
}

export async function loginAction(
  _prevState: LoginState,
  formData: FormData,
): Promise<LoginState> {
  const password = formData.get("password");
  if (typeof password !== "string" || password.length === 0) {
    return { error: "Password wajib diisi." };
  }

  let valid: boolean;
  try {
    valid = checkDashboardPassword(password);
  } catch (e) {
    return { error: e instanceof Error ? e.message : "Terjadi kesalahan." };
  }

  if (!valid) {
    return { error: "Password salah." };
  }

  const cookieStore = await cookies();
  cookieStore.set(SESSION_COOKIE_NAME, createSessionToken(), SESSION_COOKIE_OPTIONS);

  redirect("/");
}
