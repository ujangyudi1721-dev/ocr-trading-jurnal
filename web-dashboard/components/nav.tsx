import Link from "next/link";

const LINKS = [
  { href: "/", label: "Dashboard" },
  { href: "/history", label: "History" },
  { href: "/timeline", label: "Timeline" },
  { href: "/reports", label: "Laporan" },
] as const;

export function Nav() {
  return (
    <header className="sticky top-0 z-10 border-b border-border bg-surface-1/95 backdrop-blur">
      <nav className="mx-auto flex max-w-7xl items-center gap-1 overflow-x-auto px-6 py-3">
        <span className="mr-4 shrink-0 font-semibold text-text-primary">
          Trading Dashboard
        </span>
        {LINKS.map((link) => (
          <Link
            key={link.href}
            href={link.href}
            className="shrink-0 rounded-lg px-3 py-1.5 text-sm text-text-secondary hover:bg-gridline hover:text-text-primary"
          >
            {link.label}
          </Link>
        ))}
      </nav>
    </header>
  );
}
