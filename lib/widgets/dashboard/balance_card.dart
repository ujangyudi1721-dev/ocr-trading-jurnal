import 'package:flutter/material.dart';

/// Kartu utama di paling atas Dashboard: saldo saat ini + net profit,
/// dengan latar gradient supaya jadi fokus perhatian pertama di halaman.
/// Kalau [onTap] diisi, kartu bisa ditekan (dipakai untuk buka detail
/// timeline transaksi) dan menampilkan ikon panah kecil sebagai penanda.
class BalanceCard extends StatelessWidget {
  final double balance;
  final double netProfit;
  final VoidCallback? onTap;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.netProfit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isProfit = netProfit >= 0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A00E0), Color(0xFF2979FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2979FF).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "BALANCE",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        letterSpacing: 1.5,
                      ),
                    ),

                    if (onTap != null) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: Colors.white70,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  balance.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 15),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isProfit ? Icons.trending_up : Icons.trending_down,
                        color: isProfit ? Colors.greenAccent : Colors.redAccent,
                        size: 18,
                      ),

                      const SizedBox(width: 6),

                      Text(
                        "Net Profit : ${netProfit.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isProfit
                              ? Colors.greenAccent
                              : Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
