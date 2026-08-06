import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final double netProfit;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.netProfit,
  });

  @override
  Widget build(BuildContext context) {
    final bool isProfit = netProfit >= 0;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "BALANCE",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
                  isProfit
                      ? Icons.trending_up
                      : Icons.trending_down,
                  color:
                      isProfit ? Colors.green : Colors.red,
                ),

                const SizedBox(width: 8),

                Text(
                  "Net Profit : ${netProfit.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isProfit
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}