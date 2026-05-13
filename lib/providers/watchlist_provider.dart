import 'package:flutter/foundation.dart';
import '../models/stock_quote.dart';
import '../models/fund_quote.dart';
import '../services/sina_api_service.dart';
import '../services/fund_api_service.dart';
import '../services/storage_service.dart';

class WatchlistProvider extends ChangeNotifier {
  final SinaApiService _sinaApi = SinaApiService();
  final FundApiService _fundApi = FundApiService();
  final StorageService _storage = StorageService();

  List<String> _stockCodes = [];
  List<String> _fundCodes = [];
  List<StockQuote> _stockQuotes = [];
  List<FundQuote> _fundQuotes = [];
  bool _loading = false;
  String? _error;

  List<String> get stockCodes => _stockCodes;
  List<String> get fundCodes => _fundCodes;
  List<StockQuote> get stockQuotes => _stockQuotes;
  List<FundQuote> get fundQuotes => _fundQuotes;
  bool get loading => _loading;
  String? get error => _error;

  void loadWatchlist() {
    _stockCodes = _storage.getStockWatchlist();
    _fundCodes = _storage.getFundWatchlist();
    notifyListeners();
  }

  Future<void> addStock(String code) async {
    final normalized = _normalizeCode(code);
    if (_stockCodes.contains(normalized)) return;
    _stockCodes.add(normalized);
    await _storage.saveStockWatchlist(_stockCodes);
    notifyListeners();
    await refreshQuotes();
  }

  Future<void> addFund(String code) async {
    if (_fundCodes.contains(code)) return;
    _fundCodes.add(code);
    await _storage.saveFundWatchlist(_fundCodes);
    notifyListeners();
    await refreshQuotes();
  }

  Future<void> removeStock(String code) async {
    _stockCodes.remove(code);
    await _storage.saveStockWatchlist(_stockCodes);
    notifyListeners();
  }

  Future<void> removeFund(String code) async {
    _fundCodes.remove(code);
    await _storage.saveFundWatchlist(_fundCodes);
    notifyListeners();
  }

  static final _stockCodePattern = RegExp(r'^(sh|sz|hk)[a-z]?\d{5,6}$', caseSensitive: false);

  static bool isValidCode(String code) {
    return _stockCodePattern.hasMatch(code.trim());
  }

  String _normalizeCode(String code) {
    return code.trim().toLowerCase();
  }

  Future<void> refreshQuotes() async {
    _loading = true;
    notifyListeners();

    try {
      if (_stockCodes.isNotEmpty) {
        final stockFutures = <Future<List<StockQuote>>>[];
        for (var i = 0; i < _stockCodes.length; i += 10) {
          final batch = _stockCodes.skip(i).take(10).toList();
          stockFutures.add(_sinaApi.getStockQuotes(batch));
        }
        final stockResults = await Future.wait(stockFutures);
        _stockQuotes = stockResults.expand((e) => e).toList();
      }

      if (_fundCodes.isNotEmpty) {
        _fundQuotes = await _fundApi.getFundQuotes(_fundCodes);
      }
      _error = null;
    } on Exception {
      _error = '获取行情失败';
    }

    _loading = false;
    notifyListeners();
  }
}
