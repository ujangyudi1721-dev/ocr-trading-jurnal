import 'package:flutter/material.dart';

import '../models/trade_model.dart';
import '../services/hive_service.dart';
import '../services/report_export_service.dart';
import '../utils/app_logger.dart';
import '../utils/date_helper.dart';
import '../widgets/trade_list_tile.dart';
import 'trade_detail_page.dart';

/// Daftar seluruh trade tersimpan, dengan filter rentang tanggal dan
/// export ke CSV (lewat [ReportExportService]). Trade ditampilkan dari
/// yang paling baru ke paling lama.
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  /// Seluruh trade dari database (belum difilter).
  List<TradeModel> trades = [];

  /// Rentang tanggal filter aktif, `null` kalau tidak ada filter.
  DateTimeRange? filterRange;

  bool exporting = false;

  @override
  void initState() {
    super.initState();
    loadTrades();
  }

  Future<void> loadTrades() async {
    trades = await HiveService.getTrades();

    AppLogger.log("=== STATISTIC ===");

    AppLogger.log("Total Trade : ${trades.length}");

    setState(() {});
  }

  // ==========================================================
  // FILTER TANGGAL
  // ==========================================================

  /// [trades] yang sudah disaring oleh [filterRange] (berdasarkan
  /// `closeDateTime`), atau seluruh [trades] kalau tidak ada filter.
  List<TradeModel> get filteredTrades {
    final range = filterRange;

    if (range == null) return trades;

    // Sertakan seluruh hari terakhir (sampai 23:59:59).
    final end = DateTime(
      range.end.year,
      range.end.month,
      range.end.day,
      23,
      59,
      59,
    );

    return trades.where((t) {
      final date = t.closeDateTime;

      if (date == null) return false;

      return !date.isBefore(range.start) && !date.isAfter(end);
    }).toList();
  }

  /// Buka [showDateRangePicker] bawaan Flutter untuk memilih [filterRange].
  Future<void> pickDateRange() async {
    final now = DateTime.now();

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: filterRange,
    );

    if (picked == null) return;

    setState(() => filterRange = picked);
  }

  /// Hapus [filterRange] supaya seluruh trade kembali ditampilkan.
  void clearFilter() {
    setState(() => filterRange = null);
  }

  // ==========================================================
  // EXPORT
  // ==========================================================

  /// Export [filteredTrades] (yang lagi tampil di layar) ke CSV lalu
  /// buka share sheet. Tidak melakukan apa-apa kalau tidak ada data
  /// atau sedang ada proses export lain berjalan.
  Future<void> exportCsv() async {
    final data = filteredTrades;

    if (data.isEmpty || exporting) return;

    setState(() => exporting = true);

    try {
      await ReportExportService.exportTradesCsv(data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal export: $e")));
      }
    } finally {
      if (mounted) setState(() => exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = filteredTrades;

    return Scaffold(
      appBar: AppBar(
        title: const Text("History Trade"),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: "Filter Tanggal",
            onPressed: pickDateRange,
          ),
          if (exporting)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.ios_share),
              tooltip: "Export CSV",
              onPressed: exportCsv,
            ),
        ],
      ),
      body: Column(
        children: [
          if (filterRange != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Chip(
                      avatar: const Icon(Icons.date_range, size: 18),
                      label: Text(
                        "${DateHelper.formatDisplay(filterRange!.start)}"
                        " - "
                        "${DateHelper.formatDisplay(filterRange!.end)}"
                        "  (${data.length} trade)",
                      ),
                      onDeleted: clearFilter,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: data.isEmpty
                ? const Center(child: Text("Belum ada data"))
                : ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final trade = data[data.length - 1 - index];

                      return TradeListTile(
                        trade: trade,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TradeDetailPage(trade: trade),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
