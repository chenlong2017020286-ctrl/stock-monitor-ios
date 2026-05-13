/// K线数据点
class KlineData {
  final DateTime date;
  final double open;
  final double close;
  final double high;
  final double low;
  final double volume;
  final double amount;

  const KlineData({
    required this.date,
    required this.open,
    required this.close,
    required this.high,
    required this.low,
    required this.volume,
    required this.amount,
  });

  factory KlineData.fromEastMoney(Map<String, dynamic> json) {
    // 东方财富K线格式: ["2025-05-13", "10.00", "10.50", "9.80", "10.20", "100000", "1000000", ...]
    final kline = json['kline'] as List<dynamic>?;
    return KlineData(
      date: DateTime.parse(kline?[0] ?? '1970-01-01'),
      open: double.tryParse(kline?[1]?.toString() ?? '0') ?? 0,
      close: double.tryParse(kline?[2]?.toString() ?? '0') ?? 0,
      high: double.tryParse(kline?[3]?.toString() ?? '0') ?? 0,
      low: double.tryParse(kline?[4]?.toString() ?? '0') ?? 0,
      volume: double.tryParse(kline?[5]?.toString() ?? '0') ?? 0,
      amount: double.tryParse(kline?[6]?.toString() ?? '0') ?? 0,
    );
  }
}
