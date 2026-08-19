import 'package:flutter/material.dart';
import '../../models/risk_limit_model.dart';

class RiskLimitCard extends StatelessWidget {
  final RiskLimitModel riskLimit;
  final VoidCallback? onTap;

  const RiskLimitCard({super.key, required this.riskLimit, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
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
                  "RISK MANAGEMENT",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                if (onTap != null) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.edit, size: 18, color: Colors.grey),
                ],
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              "MAX LOSS",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(
              "${riskLimit.maxLossPercent.toStringAsFixed(0)}%  |  ${riskLimit.maxLossAmount.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(
              "Batas balance: ${riskLimit.lossLimitBalance.toStringAsFixed(2)}",
            ),
            const SizedBox(height: 25),

            const Text(
              "PROFIT TARGET",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(
              "${riskLimit.profitTargetPercent.toStringAsFixed(0)}%  |  ${riskLimit.profitTargetAmount.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(
              "Target balance: ${riskLimit.profitTargetBalance.toStringAsFixed(2)}",
            ),
          ],
          ),
        ),
      ),
    );
  }
}
