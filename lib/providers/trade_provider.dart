import 'package:flutter/foundation.dart';
import '../models/position.dart';
import '../models/order.dart';
import '../models/trading_account.dart';
import '../services/storage_service.dart';

class TradeProvider extends ChangeNotifier {
  final StorageService _storage;

  TradeProvider({required StorageService storage}) : _storage = storage;

  double _availableCash = 100000;
  double _initialCapital = 100000;
  List<Position> _positions = [];
  List<Order> _orders = [];

  TradingAccount get account => _buildAccount();
  List<Position> get positions => _positions;
  List<Order> get orders => _orders;
  double get availableCash => _availableCash;
  double get totalAsset => _buildAccount().totalAsset;
  double get totalProfitLoss => _buildAccount().totalProfitLoss;
  double get totalProfitLossPercent => _buildAccount().totalProfitLossPercent;

  TradingAccount _buildAccount() {
    final marketValue =
        _positions.fold<double>(0, (sum, p) => sum + p.marketValue);
    final totalAsset = _availableCash + marketValue;
    return TradingAccount(
      initialCapital: _initialCapital,
      availableCash: _availableCash,
      totalMarketValue: marketValue,
      totalAsset: totalAsset,
      totalProfitLoss: totalAsset - _initialCapital,
      totalProfitLossPercent: _initialCapital != 0
          ? (totalAsset - _initialCapital) / _initialCapital * 100
          : 0,
    );
  }

  void loadData() {
    final saved = _storage.getAccount();
    _initialCapital = saved.initialCapital;
    _availableCash = saved.availableCash;
    _positions = _storage.getPositions();
    _orders = _storage.getOrders();
    notifyListeners();
  }

  Future<bool> buy({
    required String code,
    required String name,
    required double price,
    required int quantity,
    required String market,
  }) async {
    final totalAmount = price * quantity;

    if (totalAmount > _availableCash) return false;
    if (quantity <= 0) return false;

    _availableCash -= totalAmount;

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      code: code,
      name: name,
      type: OrderType.buy,
      price: price,
      quantity: quantity,
      totalAmount: totalAmount,
      status: OrderStatus.filled,
      createTime: DateTime.now(),
      market: market,
    );
    _orders.insert(0, order);

    final existIdx = _positions.indexWhere((p) => p.code == code);
    if (existIdx >= 0) {
      final old = _positions[existIdx];
      final newQuantity = old.quantity + quantity;
      final newTotalCost = old.totalCost + totalAmount;
      final newAvgCost = newTotalCost / newQuantity;
      _positions[existIdx] = Position(
        code: code,
        name: name,
        quantity: newQuantity,
        avgCost: newAvgCost,
        totalCost: newTotalCost,
        currentPrice: price,
        marketValue: price * newQuantity,
        profitLoss: (price - newAvgCost) * newQuantity,
        profitLossPercent: (price - newAvgCost) / newAvgCost * 100,
        market: market,
      );
    } else {
      _positions.add(Position(
        code: code,
        name: name,
        quantity: quantity,
        avgCost: price,
        totalCost: totalAmount,
        currentPrice: price,
        marketValue: totalAmount,
        profitLoss: 0,
        profitLossPercent: 0,
        market: market,
      ));
    }

    await _persist();
    notifyListeners();
    return true;
  }

  Future<bool> sell({
    required String code,
    required double price,
    required int quantity,
  }) async {
    final idx = _positions.indexWhere((p) => p.code == code);
    if (idx < 0) return false;

    final pos = _positions[idx];
    if (quantity > pos.quantity) return false;
    if (quantity <= 0) return false;

    final totalAmount = price * quantity;
    _availableCash += totalAmount;

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      code: code,
      name: pos.name,
      type: OrderType.sell,
      price: price,
      quantity: quantity,
      totalAmount: totalAmount,
      status: OrderStatus.filled,
      createTime: DateTime.now(),
      market: pos.market,
    );
    _orders.insert(0, order);

    if (pos.quantity == quantity) {
      _positions.removeAt(idx);
    } else {
      final newQuantity = pos.quantity - quantity;
      _positions[idx] = Position(
        code: pos.code,
        name: pos.name,
        quantity: newQuantity,
        avgCost: pos.avgCost,
        totalCost: pos.avgCost * newQuantity,
        currentPrice: pos.currentPrice,
        marketValue: pos.currentPrice * newQuantity,
        profitLoss: (pos.currentPrice - pos.avgCost) * newQuantity,
        profitLossPercent:
            (pos.currentPrice - pos.avgCost) / pos.avgCost * 100,
        market: pos.market,
      );
    }

    await _persist();
    notifyListeners();
    return true;
  }

  void updatePositionPrices(Map<String, double> prices) {
    for (var i = 0; i < _positions.length; i++) {
      final pos = _positions[i];
      final newPrice = prices[pos.code];
      if (newPrice != null) {
        _positions[i] = pos.copyWith(
          currentPrice: newPrice,
          marketValue: newPrice * pos.quantity,
          profitLoss: (newPrice - pos.avgCost) * pos.quantity,
          profitLossPercent:
              (newPrice - pos.avgCost) / pos.avgCost * 100,
        );
      }
    }
    notifyListeners();
  }

  Future<void> resetAccount(double initialCapital) async {
    _initialCapital = initialCapital;
    _availableCash = initialCapital;
    _positions = [];
    _orders = [];
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    await _storage.saveAccount(_buildAccount());
    await _storage.savePositions(_positions);
    await _storage.saveOrders(_orders);
  }
}
