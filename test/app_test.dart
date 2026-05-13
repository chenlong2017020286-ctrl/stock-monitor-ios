import 'package:flutter_test/flutter_test.dart';
import 'package:stock_app/models/stock_quote.dart';
import 'package:stock_app/models/position.dart';
import 'package:stock_app/models/order.dart';
import 'package:stock_app/models/fund_quote.dart';
import 'package:stock_app/providers/watchlist_provider.dart';
import 'package:stock_app/providers/trade_provider.dart';

void main() {
  group('StockQuote Model', () {
    test('fromSina parses real data correctly', () {
      const rawData = '贵州茅台,1880.00,1870.00,1890.50,1900.00,1860.00,'
          '1890.50,1890.50,1234567.00,2330000000.00';
      final quote = StockQuote.fromSina('sh600519', rawData);

      expect(quote.code, 'sh600519');
      expect(quote.name, '贵州茅台');
      expect(quote.currentPrice, 1890.50);
      expect(quote.open, 1880.00);
      expect(quote.high, 1900.00);
      expect(quote.low, 1860.00);
      expect(quote.preClose, 1870.00);
      expect(quote.change, 20.50);
    });

    test('serializes to and from JSON', () {
      final quote = StockQuote(
        code: 'sh600519',
        name: '贵州茅台',
        currentPrice: 1890.50,
        change: 20.50,
        changePercent: 1.10,
        open: 1880.00,
        high: 1900.00,
        low: 1860.00,
        preClose: 1870.00,
        volume: 1234567,
        amount: 2330000000,
        market: 'sh',
        updateTime: DateTime(2025, 5, 13),
      );

      final json = quote.toJson();
      final restored = StockQuote.fromJson(json);

      expect(restored.code, quote.code);
      expect(restored.name, quote.name);
      expect(restored.currentPrice, quote.currentPrice);
    });
  });

  group('FundQuote Model', () {
    test('fromTianTian parses JSON correctly', () {
      final json = {
        'fundcode': '000001',
        'name': '华夏成长混合',
        'jzrq': '2025-05-12',
        'dwjz': '1.2345',
        'ljjz': '3.5678',
        'gsz': '1.2400',
        'gszzl': '0.45',
        'gztime': '2025-05-13 14:30:00',
      };

      final quote = FundQuote.fromTianTian(json);

      expect(quote.code, '000001');
      expect(quote.name, '华夏成长混合');
      expect(quote.nav, 1.2345);
      expect(quote.estimatedNav, 1.2400);
    });
  });

  group('Stock Code Validation', () {
    test('accepts valid stock codes', () {
      expect(WatchlistProvider.isValidCode('sh600519'), true);
      expect(WatchlistProvider.isValidCode('sz000001'), true);
      expect(WatchlistProvider.isValidCode('hk00700'), true);
    });

    test('rejects invalid stock codes', () {
      expect(WatchlistProvider.isValidCode(''), false);
      expect(WatchlistProvider.isValidCode('abc'), false);
      expect(WatchlistProvider.isValidCode('sh123'), false);
    });
  });

  group('TradeProvider', () {
    late TradeProvider provider;

    setUp(() {
      provider = TradeProvider();
      provider.resetAccount(100000);
    });

    test('buy() decreases available cash', () async {
      final cashBefore = provider.availableCash;
      final result = await provider.buy(
        code: 'sh600519',
        name: '贵州茅台',
        price: 1800,
        quantity: 10,
        market: 'sh',
      );

      expect(result, true);
      expect(provider.availableCash, lessThan(cashBefore));
      expect(provider.availableCash, cashBefore - 18000);
    });

    test('buy() fails when insufficient cash', () async {
      final result = await provider.buy(
        code: 'sh600519',
        name: '贵州茅台',
        price: 180000,
        quantity: 100,
        market: 'sh',
      );

      expect(result, false);
    });

    test('sell() increases available cash', () async {
      await provider.buy(
        code: 'sh600519',
        name: '贵州茅台',
        price: 1800,
        quantity: 10,
        market: 'sh',
      );

      final cashBefore = provider.availableCash;
      final result = await provider.sell(
        code: 'sh600519',
        price: 1900,
        quantity: 5,
      );

      expect(result, true);
      expect(provider.availableCash, cashBefore + 9500);
    });

    test('partial sell preserves cost basis', () async {
      await provider.buy(
        code: 'sh600519',
        name: '贵州茅台',
        price: 1800,
        quantity: 10,
        market: 'sh',
      );

      await provider.sell(
        code: 'sh600519',
        price: 1900,
        quantity: 3,
      );

      expect(provider.positions.length, 1);
      expect(provider.positions.first.quantity, 7);
      expect(provider.positions.first.avgCost, 1800);
    });
  });
}
