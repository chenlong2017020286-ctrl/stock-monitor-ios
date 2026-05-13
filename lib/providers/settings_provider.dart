import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage;

  SettingsProvider({required StorageService storage}) : _storage = storage;

  double _initialCapital = 100000;
  int _refreshInterval = 5;

  double get initialCapital => _initialCapital;
  int get refreshInterval => _refreshInterval;

  void loadSettings() {
    _initialCapital = _storage.getInitialCapital();
    _refreshInterval = _storage.getRefreshInterval();
    notifyListeners();
  }

  Future<void> setInitialCapital(double value) async {
    _initialCapital = value;
    await _storage.saveInitialCapital(value);
    notifyListeners();
  }

  Future<void> setRefreshInterval(int seconds) async {
    _refreshInterval = seconds;
    await _storage.saveRefreshInterval(seconds);
    notifyListeners();
  }
}
