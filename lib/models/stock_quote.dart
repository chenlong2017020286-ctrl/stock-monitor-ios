class StockQuote {
  final String code;
  final String name;
  final double currentPrice;
  final double change;
  final double changePercent;
  final double open;
  final double high;
  final double low;
  final double preClose;
  final double volume;
  final double amount;
  final String market; // 'sh' | 'sz' | 'hk'
  final DateTime updateTime;

  const StockQuote({
    required this.code,
    required this.name,
    required this.currentPrice,
    required this.change,
    required this.changePercent,
    required this.open,
    required this.high,
    required this.low,
    required this.preClose,
    required this.volume,
    required this.amount,
    required this.market,
    required this.updateTime,
  });

  factory StockQuote.fromSina(String code, String raw) {
    final parts = raw.split(',');
    final market = code.startsWith('sh') ? 'sh' : (code.startsWith('sz') ? 'sz' : 'hk');
    final name = parts[0];
    final open = double.tryParse(parts[1]) ?? 0;
    final preClose = double.tryParse(parts[2]) ?? 0;
    final currentPrice = double.tryParse(parts[3]) ?? 0;
    final high = double.tryParse(parts[4]) ?? 0;
    final low = double.tryParse(parts[5]) ?? 0;
    final volume = double.tryParse(parts[8]) ?? 0;
    final amount = double.tryParse(parts[9]) ?? 0;

    return StockQuote(
      code: code,
      name: name,
      currentPrice: currentPrice,
      change: currentPrice - preClose,
      changePercent: preClose != 0 ? ((currentPrice - preClose) / preClose * 100) : 0,
      open: open,
      high: high,
      low: low,
      preClose: preClose,
      volume: volume,
      amount: amount,
      market: market,
      updateTime: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'currentPrice': currentPrice,
        'change': change,
        'changePercent': changePercent,
        'open': open,
        'high': high,
        'low': low,
        'preClose': preClose,
        'volume': volume,
        'amount': amount,
        'market': market,
        'updateTime': updateTime.toIso8601String(),
      };

  factory StockQuote.fromJson(Map<String, dynamic> json) => StockQuote(
        code: json['code'],
        name: json['name'],
        currentPrice: json['currentPrice'],
        change: json['change'],
        changePercent: json['changePercent'],
        open: json['open'],
        high: json['high'],
        low: json['low'],
        preClose: json['preClose'],
        volume: json['volume'],
        amount: json['amount'],
        market: json['market'],
        updateTime: DateTime.parse(json['updateTime']),
      );
}
