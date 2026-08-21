import 'package:flutter/material.dart';

import '../models/trade_model.dart';
import '../utils/date_helper.dart';
import '../widgets/trade_list_tile.dart';
import 'trade_detail_page.dart';

/// Daftar semua trade pada satu tanggal tertentu, dibuka dari
/// [DailyReportPage] saat sebuah kartu laporan harian ditekan. Tap
/// satu trade untuk buka detail lengkapnya lewat [TradeDetailPage].
class DailyTradesPage extends StatelessWidget {
  final DateTime date;
  final List<TradeModel> trades;

  const DailyTradesPage({super.key, required this.date, required this.trades});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Trade - ${DateHelper.formatDisplay(date)}")),
      body: trades.isEmpty
          ? const Center(child: Text("Tidak ada trade di hari ini"))
          : ListView.builder(
              itemCount: trades.length,
              itemBuilder: (context, index) {
                final trade = trades[index];

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
    );
  }
}
