class Position {
  final String code;
  final String name;
  final int quantity;
  final double avgCost;
  final double totalCost;
  final double currentPrice;
  final double marketValue;
  final double profitLoss;
  final double profitLossPercent;
  final String market;

  const Position({
    required this.code,
    required this.name,
    required this.quantity,
    required this.avgCost,
    required this.totalCost,
    required this.currentPrice,
    required this.marketValue,
    required this.profitLoss,
    required this.profitLossPercent,
    required this.market,
  });

  Position copyWith({
    double? currentPrice,
    double? marketValue,
    double? profitLoss,
    double? profitLossPercent,
  }) {
    return Position(
      code: code,
      name: name,
      quantity: quantity,
      avgCost: avgCost,
      totalCost: totalCost,
      currentPrice: currentPrice ?? this.currentPrice,
      marketValue: marketValue ?? this.marketValue,
      profitLoss: profitLoss ?? this.profitLoss,
      profitLossPercent: profitLossPercent ?? this.profitLossPercent,
      market: market,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'quantity': quantity,
        'avgCost': avgCost,
        'totalCost': totalCost,
        'currentPrice': currentPrice,
        'marketValue': marketValue,
        'profitLoss': profitLoss,
        'profitLossPercent': profitLossPercent,
        'market': market,
      };

  factory Position.fromJson(Map<String, dynamic> json) => Position(
        code: json['code'],
        name: json['name'],
        quantity: json['quantity'],
        avgCost: json['avgCost'],
        totalCost: json['totalCost'],
        currentPrice: json['currentPrice'],
        marketValue: json['marketValue'],
        profitLoss: json['profitLoss'],
        profitLossPercent: json['profitLossPercent'],
        market: json['market'],
      );
}
