class TradingAccount {
  final double initialCapital;
  final double availableCash;
  final double totalMarketValue;
  final double totalAsset;
  final double totalProfitLoss;
  final double totalProfitLossPercent;

  const TradingAccount({
    required this.initialCapital,
    required this.availableCash,
    required this.totalMarketValue,
    required this.totalAsset,
    required this.totalProfitLoss,
    required this.totalProfitLossPercent,
  });

  Map<String, dynamic> toJson() => {
        'initialCapital': initialCapital,
        'availableCash': availableCash,
        'totalMarketValue': totalMarketValue,
        'totalAsset': totalAsset,
        'totalProfitLoss': totalProfitLoss,
        'totalProfitLossPercent': totalProfitLossPercent,
      };

  factory TradingAccount.fromJson(Map<String, dynamic> json) => TradingAccount(
        initialCapital: json['initialCapital'],
        availableCash: json['availableCash'],
        totalMarketValue: json['totalMarketValue'],
        totalAsset: json['totalAsset'],
        totalProfitLoss: json['totalProfitLoss'],
        totalProfitLossPercent: json['totalProfitLossPercent'],
      );
}
