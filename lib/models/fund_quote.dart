class FundQuote {
  final String code;
  final String name;
  final double nav; // 单位净值
  final double accNav; // 累计净值
  final double estimatedNav; // 估算净值
  final double estimatedChange; // 估算涨跌
  final double estimatedChangePercent; // 估算涨跌幅
  final String navDate; // 净值日期
  final String estimateTime; // 估算时间
  final DateTime updateTime;

  const FundQuote({
    required this.code,
    required this.name,
    required this.nav,
    required this.accNav,
    required this.estimatedNav,
    required this.estimatedChange,
    required this.estimatedChangePercent,
    required this.navDate,
    required this.estimateTime,
    required this.updateTime,
  });

  factory FundQuote.fromTianTian(Map<String, dynamic> json) {
    final nav = double.tryParse(json['dwjz'] ?? '') ?? 0;
    final estimatedNav = double.tryParse(json['gsz'] ?? '') ?? 0;
    final change = estimatedNav - nav;

    return FundQuote(
      code: json['fundcode'] ?? '',
      name: json['name'] ?? '',
      nav: nav,
      accNav: double.tryParse(json['ljjz'] ?? '') ?? 0,
      estimatedNav: estimatedNav,
      estimatedChange: change,
      estimatedChangePercent: nav != 0 ? (change / nav * 100) : 0,
      navDate: json['jzrq'] ?? '',
      estimateTime: json['gztime'] ?? '',
      updateTime: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'nav': nav,
        'accNav': accNav,
        'estimatedNav': estimatedNav,
        'estimatedChange': estimatedChange,
        'estimatedChangePercent': estimatedChangePercent,
        'navDate': navDate,
        'estimateTime': estimateTime,
        'updateTime': updateTime.toIso8601String(),
      };

  factory FundQuote.fromJson(Map<String, dynamic> json) => FundQuote(
        code: json['code'],
        name: json['name'],
        nav: json['nav'],
        accNav: json['accNav'],
        estimatedNav: json['estimatedNav'],
        estimatedChange: json['estimatedChange'],
        estimatedChangePercent: json['estimatedChangePercent'],
        navDate: json['navDate'],
        estimateTime: json['estimateTime'],
        updateTime: DateTime.parse(json['updateTime']),
      );
}
