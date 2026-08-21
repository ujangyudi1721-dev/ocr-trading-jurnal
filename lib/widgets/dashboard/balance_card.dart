import 'package:flutter/material.dart';

/// Kartu utama di paling atas Dashboard: saldo saat ini + net profit.
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

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  if (onTap != null) ...[
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 12),

              Text(
                balance.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isProfit ? Icons.trending_up : Icons.trending_down,
                    color: isProfit ? Colors.green : Colors.red,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    "Net Profit : ${netProfit.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isProfit ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
