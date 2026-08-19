import 'package:flutter/material.dart';

import '../models/daily_report_model.dart';
import '../services/account_timeline_service.dart';
import '../services/daily_report_service.dart';
import '../services/hive_service.dart';
import '../shared/loading_widget.dart';
import '../utils/date_helper.dart';

class DailyReportPage extends StatefulWidget {
  const DailyReportPage({super.key});

  @override
  State<DailyReportPage> createState() => _DailyReportPageState();
}

class _DailyReportPageState extends State<DailyReportPage> {
  List<DailyReportModel>? reports;

  @override
  void initState() {
    super.initState();
    loadReport();
  }

  // ==========================================================
  // LOAD DATA
  // ==========================================================

  Future<void> loadReport() async {
    final trades = await HiveService.getTrades();

    final transactions = await HiveService.getAccountTransactions();

    final timeline = AccountTimelineService.generate(
      transactions: transactions,
      trades: trades,
    );

    final result = DailyReportService.generate(timeline);

    // Tampilkan hari terbaru di paling atas
    reports = result.reversed.toList();

    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (reports == null) {
      return const LoadingWidget();
    }

    final data = reports!;

    return Scaffold(
      appBar: AppBar(title: const Text("Report Harian")),

      body: RefreshIndicator(
        onRefresh: loadReport,

        child: data.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 100),
                  Center(child: Text("Belum ada data")),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return _DailyReportCard(report: data[index]);
                },
              ),
      ),
    );
  }
}

// ============================================================
// CARD LAPORAN 1 HARI
// ============================================================

class _DailyReportCard extends StatelessWidget {
  final DailyReportModel report;

  const _DailyReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final Color color = report.isProfit ? Colors.green : Colors.red;

    final String sign = report.profit >= 0 ? "+" : "";

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ============================
            // TANGGAL
            // ============================
            Row(
              children: [
                Icon(
                  report.isProfit ? Icons.trending_up : Icons.trending_down,
                  color: color,
                ),

                const SizedBox(width: 8),

                Text(
                  DateHelper.formatDisplay(report.date),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const Divider(height: 20),

            // ============================
            // PROFIT / LOSS + PERSENTASE
            // ============================
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,

              children: [
                Text(
                  "$sign${report.profit.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),

                const SizedBox(width: 10),

                Padding(
                  padding: const EdgeInsets.only(bottom: 4),

                  child: Text(
                    "($sign${report.profitPercent.toStringAsFixed(2)}%)",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            const Text(
              "Persentase dihitung dari balance awal hari",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 15),

            // ============================
            // BALANCE
            // ============================
            _row(
              "Balance Awal",
              report.openingBalance.toStringAsFixed(2),
            ),

            _row(
              "Balance Akhir",
              report.closingBalance.toStringAsFixed(2),
            ),

            // ============================
            // TRADE
            // ============================
            _row(
              "Total Trade",
              "${report.totalTrade}",
            ),

            _row(
              "Win / Loss",
              "${report.totalWin} / ${report.totalLoss}"
              "  (${report.winRate.toStringAsFixed(0)}%)",
            ),

            // ============================
            // TRANSAKSI ACCOUNT
            // (hanya tampil kalau ada)
            // ============================
            if (report.deposit != 0)
              _row(
                "Deposit",
                report.deposit.toStringAsFixed(2),
              ),

            if (report.withdraw != 0)
              _row(
                "Withdraw",
                report.withdraw.toStringAsFixed(2),
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // BARIS LABEL - VALUE
  // ==========================================

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(label),

          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
