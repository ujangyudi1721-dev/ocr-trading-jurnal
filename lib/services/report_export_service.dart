import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/daily_report_model.dart';
import '../models/trade_model.dart';
import '../utils/date_helper.dart';

class ReportExportService {
  // ==========================================================
  // CSV - HISTORY TRADE
  // ==========================================================

  static Future<void> exportTradesCsv(List<TradeModel> trades) async {
    final rows = <List<dynamic>>[
      [
        "Ticket",
        "Pair",
        "Type",
        "Lot",
        "Profit",
        "Open Time",
        "Close Time",
        "SL",
        "TP",
        "Open Price",
        "Close Price",
        "Emotion",
      ],
    ];

    // Urutkan LAMA -> BARU di file export.
    final sorted = [...trades]
      ..sort((a, b) {
        final da = a.closeDateTime;
        final db = b.closeDateTime;

        if (da == null || db == null) return 0;

        return da.compareTo(db);
      });

    for (final t in sorted) {
      rows.add([
        t.ticket,
        t.pair,
        t.type,
        t.lot,
        t.profit,
        t.openTime,
        t.closeTime,
        t.sl,
        t.tp,
        t.openPrice,
        t.closePrice,
        t.emotion ?? "",
      ]);
    }

    final csv = Csv().encode(rows);

    final file = await _writeToTempFile(
      "history_trade_${_timestamp()}.csv",
      csv,
    );

    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: "History Trade (CSV)"),
    );
  }

  // ==========================================================
  // CSV - REPORT HARIAN
  // ==========================================================

  static Future<void> exportDailyReportCsv(
    List<DailyReportModel> reports,
  ) async {
    final rows = <List<dynamic>>[
      [
        "Tanggal",
        "Balance Awal",
        "Balance Akhir",
        "Profit",
        "Profit %",
        "Total Trade",
        "Win",
        "Loss",
        "Win Rate %",
        "Deposit",
        "Withdraw",
      ],
    ];

    // Urutkan LAMA -> BARU di file export.
    final sorted = [...reports]..sort((a, b) => a.date.compareTo(b.date));

    for (final r in sorted) {
      rows.add([
        DateHelper.formatDisplay(r.date),
        r.openingBalance.toStringAsFixed(2),
        r.closingBalance.toStringAsFixed(2),
        r.profit.toStringAsFixed(2),
        r.profitPercent.toStringAsFixed(2),
        r.totalTrade,
        r.totalWin,
        r.totalLoss,
        r.winRate.toStringAsFixed(0),
        r.deposit.toStringAsFixed(2),
        r.withdraw.toStringAsFixed(2),
      ]);
    }

    final csv = Csv().encode(rows);

    final file = await _writeToTempFile(
      "report_harian_${_timestamp()}.csv",
      csv,
    );

    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: "Report Harian (CSV)"),
    );
  }

  // ==========================================================
  // PDF
  // ==========================================================

  static Future<void> exportDailyReportPdf(
    List<DailyReportModel> reports,
  ) async {
    final sorted = [...reports]..sort((a, b) => a.date.compareTo(b.date));

    final doc = pw.Document();

    final headers = [
      "Tanggal",
      "Balance Awal",
      "Balance Akhir",
      "Profit",
      "Profit %",
      "Trade",
      "W/L",
      "Deposit",
      "Withdraw",
    ];

    final data = sorted.map((r) {
      return [
        DateHelper.formatDisplay(r.date),
        r.openingBalance.toStringAsFixed(2),
        r.closingBalance.toStringAsFixed(2),
        r.profit.toStringAsFixed(2),
        "${r.profitPercent.toStringAsFixed(2)}%",
        "${r.totalTrade}",
        "${r.totalWin}/${r.totalLoss}",
        r.deposit.toStringAsFixed(2),
        r.withdraw.toStringAsFixed(2),
      ];
    }).toList();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "Report Harian Trading",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              "Dicetak: ${DateHelper.formatDateTime(DateTime.now())}",
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 10),
          ],
        ),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: data,
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.blueGrey800,
            ),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignment: pw.Alignment.centerRight,
            cellAlignments: {0: pw.Alignment.centerLeft},
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          ),
        ],
      ),
    );

    final file = await _writeBytesToTempFile(
      "report_harian_${_timestamp()}.pdf",
      await doc.save(),
    );

    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: "Report Harian (PDF)"),
    );
  }

  // ==========================================================
  // HELPER
  // ==========================================================

  static String _timestamp() {
    final now = DateTime.now();

    String two(int v) => v.toString().padLeft(2, "0");

    return "${now.year}${two(now.month)}${two(now.day)}_"
        "${two(now.hour)}${two(now.minute)}${two(now.second)}";
  }

  static Future<File> _writeToTempFile(String fileName, String content) async {
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/$fileName");

    return file.writeAsString(content);
  }

  static Future<File> _writeBytesToTempFile(
    String fileName,
    List<int> bytes,
  ) async {
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/$fileName");

    return file.writeAsBytes(bytes);
  }
}
