class IndexQuote {
  final String code;
  final String name;
  final double currentPoint;
  final double change;
  final double changePercent;
  final double volume;
  final double amount;
  final DateTime updateTime;

  const IndexQuote({
    required this.code,
    required this.name,
    required this.currentPoint,
    required this.change,
    required this.changePercent,
    required this.volume,
    required this.amount,
    required this.updateTime,
  });

  factory IndexQuote.fromSina(String code, String name, String raw) {
    final parts = raw.split(',');
    final currentPoint = double.tryParse(parts[3]) ?? 0;
    final preClose = double.tryParse(parts[2]) ?? 0;
    final volume = double.tryParse(parts[8]) ?? 0;
    final amount = double.tryParse(parts[9]) ?? 0;

    return IndexQuote(
      code: code,
      name: name,
      currentPoint: currentPoint,
      change: currentPoint - preClose,
      changePercent: preClose != 0 ? ((currentPoint - preClose) / preClose * 100) : 0,
      volume: volume,
      amount: amount,
      updateTime: DateTime.now(),
    );
  }
}
