import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/position.dart';
import '../models/order.dart';
import '../models/trading_account.dart';

class StorageService {
  static const _stockWatchlistBox = 'stockWatchlist';
  static const _fundWatchlistBox = 'fundWatchlist';
  static const _positionsBox = 'positions';
  static const _ordersBox = 'orders';
  static const _accountBox = 'account';
  static const _settingsBox = 'settings';

  Box? _stockWatchlistBoxInstance;
  Box? _fundWatchlistBoxInstance;
  Box? _positionsBoxInstance;
  Box? _ordersBoxInstance;
  Box? _accountBoxInstance;
  Box? _settingsBoxInstance;

  bool _initialized = false;

  Future<void> init() async {
    try {
      await Hive.initFlutter();
      _stockWatchlistBoxInstance = await Hive.openBox(_stockWatchlistBox);
      _fundWatchlistBoxInstance = await Hive.openBox(_fundWatchlistBox);
      _positionsBoxInstance = await Hive.openBox(_positionsBox);
      _ordersBoxInstance = await Hive.openBox(_ordersBox);
      _accountBoxInstance = await Hive.openBox(_accountBox);
      _settingsBoxInstance = await Hive.openBox(_settingsBox);
      _initialized = true;
    } catch (e) {
      debugPrint('Hive初始化失败: $e');
      _initialized = false;
    }
  }

  // --- 股票自选 ---
  List<String> getStockWatchlist() {
    if (!_initialized || _stockWatchlistBoxInstance == null) return [];
    final data = _stockWatchlistBoxInstance!.get('codes');
    if (data == null) return [];
    return (data as List).cast<String>();
  }

  Future<void> saveStockWatchlist(List<String> codes) {
    if (!_initialized || _stockWatchlistBoxInstance == null) return Future.value();
    return _stockWatchlistBoxInstance!.put('codes', codes);
  }

  // --- 基金自选 ---
  List<String> getFundWatchlist() {
    if (!_initialized || _fundWatchlistBoxInstance == null) return [];
    final data = _fundWatchlistBoxInstance!.get('codes');
    if (data == null) return [];
    return (data as List).cast<String>();
  }

  Future<void> saveFundWatchlist(List<String> codes) {
    if (!_initialized || _fundWatchlistBoxInstance == null) return Future.value();
    return _fundWatchlistBoxInstance!.put('codes', codes);
  }

  // --- 持仓 ---
  List<Position> getPositions() {
    if (!_initialized || _positionsBoxInstance == null) return [];
    final data = _positionsBoxInstance!.get('data');
    if (data == null) return [];
    return (data['positions'] as List? ?? [])
        .map((e) => Position.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> savePositions(List<Position> positions) {
    if (!_initialized || _positionsBoxInstance == null) return Future.value();
    return _positionsBoxInstance!.put('data', {
      'positions': positions.map((e) => e.toJson()).toList(),
    });
  }

  // --- 订单 ---
  List<Order> getOrders() {
    if (!_initialized || _ordersBoxInstance == null) return [];
    final data = _ordersBoxInstance!.get('data');
    if (data == null) return [];
    return (data['orders'] as List? ?? [])
        .map((e) => Order.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> saveOrders(List<Order> orders) {
    if (!_initialized || _ordersBoxInstance == null) return Future.value();
    return _ordersBoxInstance!.put('data', {
      'orders': orders.map((e) => e.toJson()).toList(),
    });
  }

  // --- 账户 ---
  TradingAccount getAccount() {
    if (!_initialized || _accountBoxInstance == null) {
      return const TradingAccount(
        initialCapital: 100000,
        availableCash: 100000,
        totalMarketValue: 0,
        totalAsset: 100000,
        totalProfitLoss: 0,
        totalProfitLossPercent: 0,
      );
    }
    final data = _accountBoxInstance!.get('data');
    if (data == null) {
      return const TradingAccount(
        initialCapital: 100000,
        availableCash: 100000,
        totalMarketValue: 0,
        totalAsset: 100000,
        totalProfitLoss: 0,
        totalProfitLossPercent: 0,
      );
    }
    return TradingAccount.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> saveAccount(TradingAccount account) {
    if (!_initialized || _accountBoxInstance == null) return Future.value();
    return _accountBoxInstance!.put('data', account.toJson());
  }

  // --- 设置 ---
  double getInitialCapital() {
    if (!_initialized || _settingsBoxInstance == null) return 100000;
    return (_settingsBoxInstance!.get('initialCapital')?['value'] ?? 100000)
        .toDouble();
  }

  Future<void> saveInitialCapital(double value) {
    if (!_initialized || _settingsBoxInstance == null) return Future.value();
    return _settingsBoxInstance!.put('initialCapital', {'value': value});
  }

  int getRefreshInterval() {
    if (!_initialized || _settingsBoxInstance == null) return 5;
    return _settingsBoxInstance!.get('refreshInterval')?['value'] ?? 5;
  }

  Future<void> saveRefreshInterval(int seconds) {
    if (!_initialized || _settingsBoxInstance == null) return Future.value();
    return _settingsBoxInstance!.put('refreshInterval', {'value': seconds});
  }
}
