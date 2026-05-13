import 'package:flutter/foundation.dart';
import '../models/stock_quote.dart';
import '../models/index_quote.dart';
import '../services/sina_api_service.dart';

class MarketProvider extends ChangeNotifier {
  final SinaApiService _sinaApi = SinaApiService();

  static const _indexMap = {
    'sh000001': '上证指数',
    'sz399001': '深证成指',
    'sz399006': '创业板指',
    'sh000688': '科创50',
    'sh000300': '沪深300',
  };

  List<IndexQuote> _indices = [];
  List<StockQuote> _hotStocks = [];
  bool _loading = false;
  String? _error;

  List<IndexQuote> get indices => _indices;
  List<StockQuote> get hotStocks => _hotStocks;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchIndices() async {
    _loading = true;
    notifyListeners();

    try {
      final codes = _indexMap.keys.toList();
      final quotes = await _sinaApi.getStockQuotes(codes);
      _indices = quotes.map((q) {
        return IndexQuote(
          code: q.code,
          name: _indexMap[q.code] ?? q.name,
          currentPoint: q.currentPrice,
          change: q.change,
          changePercent: q.changePercent,
          volume: q.volume,
          amount: q.amount,
          updateTime: DateTime.now(),
        );
      }).toList();
      _error = null;
    } on Exception {
      _error = '获取指数数据失败';
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> fetchHotStocks() async {
    try {
      const hotCodes = [
        'sh600519',
        'sz000858',
        'sh601318',
        'sz300750',
        'sh600036',
        'sz002594',
      ];
      _hotStocks = await _sinaApi.getStockQuotes(hotCodes);
      _error = null;
    } on Exception {
      _error = '获取热门股票失败';
    }
    notifyListeners();
  }

  Future<void> refreshAll() async {
    _loading = true;
    notifyListeners();
    await Future.wait([fetchIndices(), fetchHotStocks()]);
    _loading = false;
    notifyListeners();
  }
}
