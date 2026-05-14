import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/storage_service.dart';
import 'providers/market_provider.dart';
import 'providers/watchlist_provider.dart';
import 'providers/trade_provider.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = StorageService();
  try {
    await storage.init();
  } catch (e) {
    // 即使 Hive 初始化失败，也要启动 App（离线模式）
    debugPrint('Storage init failed: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storage),
        ChangeNotifierProvider(create: (_) => MarketProvider()),
        ChangeNotifierProvider(
          create: (ctx) => WatchlistProvider(storage: ctx.read<StorageService>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => TradeProvider(storage: ctx.read<StorageService>())..loadData(),
        ),
        ChangeNotifierProvider(
          create: (ctx) =>
              SettingsProvider(storage: ctx.read<StorageService>())..loadSettings(),
        ),
      ],
      child: const StockApp(),
    ),
  );
}
