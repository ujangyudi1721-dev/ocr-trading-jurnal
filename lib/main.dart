import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/account_transaction_model.dart';
import 'models/trade_model.dart';
import 'pages/dashboard_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(TradeModelAdapter());

  Hive.registerAdapter(AccountTransactionModelAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OCR Trading Journal',
      home: const DashboardPage(),
    );
  }
}
