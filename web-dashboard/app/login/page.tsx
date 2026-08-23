"use client";

import { useActionState } from "react";
import { loginAction, type LoginState } from "./actions";

const initialState: LoginState = { error: null };

export default function LoginPage() {
  const [state, action, pending] = useActionState(loginAction, initialState);

  return (
    <main className="flex min-h-screen items-center justify-center px-6">
      <form
        action={action}
        className="w-full max-w-sm rounded-xl border border-border bg-surface-1 p-6 shadow-sm"
      >
        <h1 className="text-lg font-semibold text-text-primary">Trading Dashboard</h1>
        <p className="mt-1 text-sm text-text-secondary">
          Masukkan password untuk melihat data.
        </p>

        <input
          type="password"
          name="password"
          autoFocus
          required
          placeholder="Password"
          className="mt-5 w-full rounded-lg border border-border bg-transparent px-3 py-2 text-text-primary outline-none focus:border-series-1"
        />

        {state.error && (
          <p className="mt-2 text-sm text-status-critical">{state.error}</p>
        )}

        <button
          type="submit"
          disabled={pending}
          className="mt-4 w-full rounded-lg bg-series-1 px-3 py-2 font-medium text-white disabled:opacity-60"
        >
          {pending ? "Memeriksa..." : "Masuk"}
        </button>
      </form>
    </main>
  );
}
