# Graph Report - ocr_trading_jurnal  (2026-08-23)

## Corpus Check
- Corpus is ~33,375 words - fits in a single context window. You may not need a graph.

## Summary
- 720 nodes · 924 edges · 59 communities (50 shown, 9 thin omitted)
- Extraction: 96% EXTRACTED · 4% INFERRED · 0% AMBIGUOUS · INFERRED: 37 edges (avg confidence: 0.89)
- Token cost: 93,730 input · 0 output

## Community Hubs (Navigation)
- Windows Plugin Registration
- macOS Flutter App Delegate
- Analytics Data Models
- Analytics Engine & Drawdown Calc
- Linux GTK App Shell
- Analytics Result Schema
- Account Timeline Model
- Roadmap & Project Docs
- Dashboard & Report Pages
- Home & History Pages
- Trade History Filtering
- Emotion Statistics Model
- Trade Model (Hive)
- Account Transaction Pages
- Risk Limit Edit Dialog
- Daily Trades & Report Export
- Hive Local Storage Service
- Account Page State
- Hive Adapter Boilerplate
- Daily Report & Drawdown Services
- Report Export Service
- Settings Service
- Windows Runner Entry Point
- Web App Manifest
- Trade Detail Page
- Emotion Constants
- Page State Classes
- Timeline Page
- Risk Limit Service & Card
- Stat Card Widget
- Date Helper Utility
- Daily Trades Section Widgets
- Loading Widget & Main Test
- Hive Type Adapters
- OCR Scan Service
- App Entry Point (main.dart)
- Health Card Widget
- Action Buttons Widget
- Balance Card Widget
- Trade List Tile Widget
- Image Cropper Service
- App Constants
- Account Timeline Service
- Equity Point Model
- Trade Validator
- App Logger
- Android MainActivity
- Sprint 2: Trade Classification
- Sprint 3: Risk Engine
- Sprint 4: Psychology Engine
- Sprint 5: Report Engine
- Milestone 7: Visualization
- iOS Launch Screen Assets
- Windows Runner Utils
- Project README

## God Nodes (most connected - your core abstractions)
1. `Win32Window` - 24 edges
2. `MessageHandler` - 12 edges
3. `FlutterWindow` - 10 edges
4. `Create` - 10 edges
5. `WndProc` - 10 edges
6. `MessageHandler` - 9 edges
7. `ocr_trading_jurnal Package Manifest` - 9 edges
8. `TradeModel` - 8 edges
9. `AnalyticsResult Model` - 8 edges
10. `_MyApplication` - 7 edges

## Surprising Connections (you probably didn't know these)
- `OCR Spreadsheet Google Apps Script Deployment` --conceptually_related_to--> `Milestone 8: Cloud`  [AMBIGUOUS]
  data address deploy untuk OCR spreadset.txt → docs/ROADMAP.txt
- `OCR Trading Project ChatGPT Share Link` --conceptually_related_to--> `TPMS Vision: Replace Excel Trading Journal`  [AMBIGUOUS]
  link project OCR trading.txt → docs/ROADMAP.txt
- `Flutter Web Index Shell (ocr_trading_jurnal)` --shares_data_with--> `ocr_trading_jurnal Package Manifest`  [INFERRED]
  web/index.html → pubspec.yaml
- `TPMS Vision: Replace Excel Trading Journal` --shares_data_with--> `google_mlkit_text_recognition dependency`  [INFERRED]
  docs/ROADMAP.txt → pubspec.yaml
- `TPMS Vision: Replace Excel Trading Journal` --shares_data_with--> `hive dependency (Hive Database)`  [INFERRED]
  docs/ROADMAP.txt → pubspec.yaml

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Linux Flutter Build Pipeline** — linux_cmakelists_runner_target, linux_flutter_cmakelists_flutter_library, linux_runner_cmakelists_runner_executable [EXTRACTED 1.00]
- **Windows Flutter Build Pipeline** — windows_cmakelists_runner_target, windows_flutter_cmakelists_flutter_library, windows_runner_cmakelists_runner_executable [EXTRACTED 1.00]
- **AnalyticsResult Composition** — docs_analytics_result_model_analyticsresult, docs_analytics_result_model_trade_statistic, docs_analytics_result_model_pair_statistic, docs_analytics_result_model_equity, docs_analytics_result_model_drawdown, docs_analytics_result_model_daily_summary, docs_analytics_result_model_weekly_summary, docs_analytics_result_model_monthly_summary [EXTRACTED 1.00]

## Communities (59 total, 9 thin omitted)

### Community 0 - "Windows Plugin Registration"
Cohesion: 0.05
Nodes (57): PluginRegistry, RECT, unique_ptr, RegisterPlugins(), DartProject, HWND, LPARAM, LRESULT (+49 more)

### Community 1 - "macOS Flutter App Delegate"
Cohesion: 0.06
Nodes (29): Any, Cocoa, file_selector_macos, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterMacOS (+21 more)

### Community 2 - "Analytics Data Models"
Cohesion: 0.05
Nodes (39): account_timeline_model.dart, drawdown_model.dart, emotion_statistic_model.dart, equity_point_model.dart, averageLoss, averageWin, currentBalance, drawdown (+31 more)

### Community 3 - "Analytics Engine & Drawdown Calc"
Cohesion: 0.06
Nodes (34): drawdown_service.dart, AnalyticsResultModel, AnalyticsEngine, calculate, calculateEmotionPerformance, calculateEquity, calculatePairPerformance, analytics (+26 more)

### Community 4 - "Linux GTK App Shell"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 5 - "Analytics Result Schema"
Cohesion: 0.11
Nodes (26): AnalyticsResult Model, Daily Summary, Drawdown (priority metric), Equity, Monthly Summary, Pair Statistic, Trade Statistic, Weekly Summary (+18 more)

### Community 6 - "Account Timeline Model"
Cohesion: 0.08
Nodes (23): bool get, DateTime, AccountTimelineModel, amount, balance, date, emotion, pair (+15 more)

### Community 7 - "Roadmap & Project Docs"
Cohesion: 0.10
Nodes (24): Dart Analyzer Lint Configuration, OCR Spreadsheet Google Apps Script Deployment, Milestone 1: OCR Foundation (Completed), Milestone 8: Cloud, Milestone 9: AI Trading Coach, TPMS Project Flow (Screenshot to Cloud Sync), Sprint 6: Cloud, Sprint 7: AI Coach (+16 more)

### Community 8 - "Dashboard & Report Pages"
Cohesion: 0.09
Nodes (22): daily_report_page.dart, home_page.dart, analytics, createState, DashboardPage, _DashboardPageState, editRiskLimit, initState (+14 more)

### Community 9 - "Home & History Pages"
Cohesion: 0.10
Nodes (20): dashboard_page.dart, history_page.dart, createState, emotions, HomePage, _HomePageState, imageFiles, isScanning (+12 more)

### Community 10 - "Trade History Filtering"
Cohesion: 0.12
Nodes (17): DateTimeRange?, date, trades, clearFilter, createState, exportCsv, exporting, filterRange (+9 more)

### Community 11 - "Emotion Statistics Model"
Cohesion: 0.11
Nodes (17): double get, averageProfit, emotion, EmotionStatisticModel, profit, totalLoss, totalTrade, totalWin (+9 more)

### Community 12 - "Trade Model (Hive)"
Cohesion: 0.11
Nodes (17): hashCode, operator, read, typeId, write, closePrice, closeTime, emotion (+9 more)

### Community 13 - "Account Transaction Pages"
Cohesion: 0.12
Nodes (15): account_transaction_page.dart, build, createState, data, deleteItem, initState, loadData, build (+7 more)

### Community 14 - "Risk Limit Edit Dialog"
Cohesion: 0.13
Nodes (15): FormState, build, createState, dispose, formKey, initState, maxLossController, maxLossPercent (+7 more)

### Community 15 - "Daily Trades & Report Export"
Cohesion: 0.13
Nodes (14): daily_trades_page.dart, build, createState, exporting, exportReport, initState, loadReport, onTap (+6 more)

### Community 16 - "Hive Local Storage Service"
Cohesion: 0.13
Nodes (14): accountBox, clearAccountTransactions, clearAll, clearTrades, deleteAccountTransaction, deleteTrade, getAccountTransactions, getTrades (+6 more)

### Community 17 - "Account Page State"
Cohesion: 0.15
Nodes (12): account_history_page.dart, amountController, createState, dispose, initState, isEdit, noteController, pickDate (+4 more)

### Community 18 - "Hive Adapter Boilerplate"
Cohesion: 0.15
Nodes (12): class, hashCode, operator, read, typeId, write, int get, amount (+4 more)

### Community 19 - "Daily Report & Drawdown Services"
Cohesion: 0.17
Nodes (10): DailyReportService, generate, calculate, DrawdownService, OCRParser, parse, ../models/account_timeline_model.dart, ../models/daily_report_model.dart (+2 more)

### Community 20 - "Report Export Service"
Cohesion: 0.15
Nodes (12): exportDailyReportCsv, exportDailyReportPdf, exportTradesCsv, ReportExportService, _timestamp, _writeBytesToTempFile, _writeToTempFile, package:csv/csv.dart (+4 more)

### Community 21 - "Settings Service"
Cohesion: 0.15
Nodes (12): boxName, defaultMaxLossPercent, defaultProfitTargetPercent, getMaxLossPercent, getProfitTargetPercent, _maxLossKey, _openBox, _profitTargetKey (+4 more)

### Community 22 - "Windows Runner Entry Point"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, vector, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 23 - "Web App Manifest"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 24 - "Trade Detail Page"
Cohesion: 0.20
Nodes (8): ../constants/emotion_constants.dart, build, buildItem, trade, TradeDetailPage, build, trade, TradeCard

### Community 25 - "Emotion Constants"
Cohesion: 0.20
Nodes (9): color, EmotionConstants, EmotionOption, find, icon, key, label, options (+1 more)

### Community 26 - "Page State Classes"
Cohesion: 0.27
Nodes (10): AccountHistoryPage, _AccountHistoryPageState, AccountTransactionPage, _AccountTransactionPageState, DailyReportPage, _DailyReportPageState, HistoryPage, _HistoryPageState (+2 more)

### Community 27 - "Timeline Page"
Cohesion: 0.22
Nodes (9): build, createState, getColor, initState, loadTimeline, timeline, TimelinePage, _TimelinePageState (+1 more)

### Community 28 - "Risk Limit Service & Card"
Cohesion: 0.20
Nodes (8): calculate, RiskLimitService, build, onTap, riskLimit, RiskLimitCard, _riskPanel, ../../models/risk_limit_model.dart

### Community 29 - "Stat Card Widget"
Cohesion: 0.22
Nodes (8): Color, IconData?, build, color, icon, onTap, title, value

### Community 30 - "Date Helper Utility"
Cohesion: 0.22
Nodes (8): DateHelper, formatDateTime, formatDisplay, formatStorage, formatTime, _months, parse, static const Map

### Community 31 - "Daily Trades Section Widgets"
Cohesion: 0.25
Nodes (7): _DailyReportCard, DailyTradesPage, build, SectionTitle, title, StatCard, StatelessWidget

### Community 32 - "Loading Widget & Main Test"
Cohesion: 0.25
Nodes (6): build, LoadingWidget, package:flutter/material.dart, package:flutter_test/flutter_test.dart, package:ocr_trading_jurnal/main.dart, main

### Community 33 - "Hive Type Adapters"
Cohesion: 0.38
Nodes (7): @HiveType, AccountTransactionModelAdapter, TradeModelAdapter, HiveObject, AccountTransactionModel, TradeModel, TypeAdapter

### Community 34 - "OCR Scan Service"
Cohesion: 0.29
Nodes (6): dart:async, image_cropper_service.dart, OCRService, scanTrade, ocr_parser.dart, package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart

### Community 35 - "App Entry Point (main.dart)"
Cohesion: 0.29
Nodes (6): build, initFlutter, main, MyApp, package:hive_flutter/hive_flutter.dart, pages/dashboard_page.dart

### Community 36 - "Health Card Widget"
Cohesion: 0.29
Nodes (6): build, drawdown, growth, HealthCard, healthItem, status

### Community 37 - "Action Buttons Widget"
Cohesion: 0.33
Nodes (5): ActionButtons, build, onPickImage, onSave, onScanOCR

### Community 38 - "Balance Card Widget"
Cohesion: 0.33
Nodes (5): balance, BalanceCard, build, netProfit, onTap

### Community 39 - "Trade List Tile Widget"
Cohesion: 0.33
Nodes (5): build, onTap, trade, TradeListTile, VoidCallback?

### Community 40 - "Image Cropper Service"
Cohesion: 0.40
Nodes (4): dart:io, cropPopup, ImageCropperService, package:image/image.dart

### Community 41 - "App Constants"
Cohesion: 0.40
Nodes (4): AppConstants, appName, imagePreviewHeight, static const

### Community 42 - "Account Timeline Service"
Cohesion: 0.40
Nodes (4): AccountTimelineService, calculateBalance, generate, ../models/account_transaction_model.dart

### Community 43 - "Equity Point Model"
Cohesion: 0.50
Nodes (3): balance, EquityPointModel, index

### Community 44 - "Trade Validator"
Cohesion: 0.50
Nodes (3): isValid, TradeValidator, ../models/trade_model.dart

### Community 45 - "App Logger"
Cohesion: 0.50
Nodes (3): AppLogger, log, package:flutter/foundation.dart

## Ambiguous Edges - Review These
- `OCR Spreadsheet Google Apps Script Deployment` → `Milestone 8: Cloud`  [AMBIGUOUS]
  data address deploy untuk OCR spreadset.txt · relation: conceptually_related_to
- `TPMS Vision: Replace Excel Trading Journal` → `OCR Trading Project ChatGPT Share Link`  [AMBIGUOUS]
  link project OCR trading.txt · relation: conceptually_related_to

## Knowledge Gaps
- **342 isolated node(s):** `AppConstants`, `appName`, `imagePreviewHeight`, `EmotionOption`, `EmotionConstants` (+337 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **9 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What is the exact relationship between `OCR Spreadsheet Google Apps Script Deployment` and `Milestone 8: Cloud`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **What is the exact relationship between `TPMS Vision: Replace Excel Trading Journal` and `OCR Trading Project ChatGPT Share Link`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **Why does `AnalyticsResultModel` connect `Analytics Engine & Drawdown Calc` to `Dashboard & Report Pages`, `Analytics Data Models`?**
  _High betweenness centrality (0.017) - this node is a cross-community bridge._
- **Why does `RiskLimitModel` connect `Analytics Data Models` to `Risk Limit Service & Card`?**
  _High betweenness centrality (0.016) - this node is a cross-community bridge._
- **Why does `FlutterWindow` connect `Windows Plugin Registration` to `macOS Flutter App Delegate`?**
  _High betweenness centrality (0.015) - this node is a cross-community bridge._
- **Are the 4 inferred relationships involving `MessageHandler` (e.g. with `Destroy` and `GetClientArea`) actually correct?**
  _`MessageHandler` has 4 INFERRED edges - model-reasoned connections that need verification._
- **What connects `AppConstants`, `appName`, `imagePreviewHeight` to the rest of the system?**
  _342 weakly-connected nodes found - possible documentation gaps or missing edges._