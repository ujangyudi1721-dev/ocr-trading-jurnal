import 'package:flutter/material.dart';
import '../../models/risk_limit_model.dart';

/// Kartu Dashboard yang menampilkan batas rugi & target profit hasil
/// hitungan [RiskLimitModel] sebagai dua panel berwarna (merah untuk
/// Max Loss, hijau untuk Profit Target) supaya kontras sekilas. Kalau
/// [onTap] diisi, kartu bisa ditekan untuk membuka [RiskLimitEditDialog]
/// (ikon pensil kecil muncul sebagai penanda bisa diedit).
class RiskLimitCard extends StatelessWidget {
  final RiskLimitModel riskLimit;
  final VoidCallback? onTap;

  const RiskLimitCard({super.key, required this.riskLimit, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
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
                    "RISK MANAGEMENT",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  if (onTap != null) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.edit, size: 18, color: Colors.grey),
                  ],
                ],
              ),

              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _riskPanel(
                      color: Colors.red,
                      icon: Icons.trending_down,
                      label: "MAX LOSS",
                      percent: riskLimit.maxLossPercent,
                      amount: riskLimit.maxLossAmount,
                      balanceLabel: "Batas balance",
                      balance: riskLimit.lossLimitBalance,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _riskPanel(
                      color: Colors.green,
                      icon: Icons.trending_up,
                      label: "PROFIT TARGET",
                      percent: riskLimit.profitTargetPercent,
                      amount: riskLimit.profitTargetAmount,
                      balanceLabel: "Target balance",
                      balance: riskLimit.profitTargetBalance,
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

  /// Satu panel berwarna (Max Loss atau Profit Target) di dalam
  /// [RiskLimitCard], menampilkan persentase, nominal, dan level saldo.
  Widget _riskPanel({
    required Color color,
    required IconData icon,
    required String label,
    required double percent,
    required double amount,
    required String balanceLabel,
    required double balance,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            "${percent.toStringAsFixed(0)}%",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          Text(
            amount.toStringAsFixed(2),
            style: TextStyle(fontSize: 13, color: color.withValues(alpha: 0.9)),
          ),

          const SizedBox(height: 8),

          Text(
            "$balanceLabel: ${balance.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
