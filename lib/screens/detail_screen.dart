import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/stock_quote.dart';
import '../models/fund_quote.dart';
import '../models/kline_data.dart';
import '../services/sina_api_service.dart';
import '../services/fund_api_service.dart';
import '../services/eastmoney_api_service.dart';

class DetailScreen extends StatefulWidget {
  final String code;
  final String name;
  final String type; // 'stock' | 'fund'

  const DetailScreen({
    super.key,
    required this.code,
    required this.name,
    required this.type,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final SinaApiService _sinaApi = SinaApiService();
  final FundApiService _fundApi = FundApiService();
  final EastMoneyApiService _eastMoneyApi = EastMoneyApiService();

  StockQuote? _stockQuote;
  FundQuote? _fundQuote;
  List<KlineData> _klines = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    if (widget.type == 'stock') {
      final result = await Future.wait([
        _sinaApi.getStockQuote(widget.code),
        _eastMoneyApi.getKlineData(
          code: widget.code.replaceAll(RegExp(r'[a-z]'), ''),
          market: widget.code.startsWith('sh') ? 'sh' : 'sz',
        ),
      ]);
      _stockQuote = result[0] as StockQuote?;
      _klines = result[1] as List<KlineData>;
    } else {
      _fundQuote = await _fundApi.getFundQuote(widget.code);
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (widget.type == 'stock') ...[
                    _buildStockHeader(),
                    const SizedBox(height: 20),
                    _buildKlineChart(),
                    const SizedBox(height: 16),
                    _buildStockInfo(),
                  ] else ...[
                    _buildFundHeader(),
                    const SizedBox(height: 20),
                    _buildFundInfo(),
                  ],
                  const SizedBox(height: 24),
                  // 交易按钮
                  if (widget.type == 'stock' && _stockQuote != null)
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () => Navigator.pushNamed(context, '/trade',
                                arguments: {
                                  'code': widget.code,
                                  'name': widget.name,
                                  'price': _stockQuote!.currentPrice,
                                  'action': 'buy',
                                }),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('模拟买入', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildStockHeader() {
    final q = _stockQuote;
    if (q == null) return const Text('无法获取行情');
    final isUp = q.change >= 0;
    final color = isUp ? Colors.red : Colors.green;

    return Column(
      children: [
        Text(q.currentPrice.toStringAsFixed(2),
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${q.change >= 0 ? '+' : ''}${q.change.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16, color: color)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
              child: Text('${q.changePercent >= 0 ? '+' : ''}${q.changePercent.toStringAsFixed(2)}%',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKlineChart() {
    if (_klines.isEmpty) return const SizedBox(height: 200, child: Center(child: Text('暂无K线数据')));

    final isUp = _klines.last.close >= (_klines.isNotEmpty ? _klines.first.close : _klines.last.close);

    // 取最近60个数据点
    final displayData = _klines.length > 60 ? _klines.sublist(_klines.length - 60) : _klines;
    final maxPrice = displayData.map((k) => k.high).reduce((a, b) => a > b ? a : b);
    final minPrice = displayData.map((k) => k.low).reduce((a, b) => a < b ? a : b);

    return SizedBox(
      height: 240,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(2),
                style: const TextStyle(fontSize: 10),
              ),
            )),
            bottomTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true,
              interval: 15,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < displayData.length) {
                  final date = displayData[idx].date;
                  return Text('${date.month}/${date.day}', style: const TextStyle(fontSize: 9));
                }
                return const Text('');
              },
            )),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minY: minPrice * 0.98,
          maxY: maxPrice * 1.02,
          lineBarsData: [
            LineChartBarData(
              spots: displayData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.close)).toList(),
              color: isUp ? Colors.red : Colors.green,
              barWidth: 1.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: (isUp ? Colors.red : Colors.green).withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockInfo() {
    final q = _stockQuote;
    if (q == null) return const SizedBox.shrink();

    final items = [
      ['开盘', q.open.toStringAsFixed(2)],
      ['最高', q.high.toStringAsFixed(2)],
      ['最低', q.low.toStringAsFixed(2)],
      ['昨收', q.preClose.toStringAsFixed(2)],
      ['成交量', '${(q.volume / 10000).toStringAsFixed(1)}万手'],
      ['成交额', '${(q.amount / 100000000).toStringAsFixed(2)}亿'],
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item[0], style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              const SizedBox(height: 4),
              Text(item[1], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFundHeader() {
    final q = _fundQuote;
    if (q == null) return const Text('无法获取基金数据');
    final isUp = q.estimatedChange >= 0;
    final color = isUp ? Colors.red : Colors.green;

    return Column(
      children: [
        Text(q.estimatedNav.toStringAsFixed(4),
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 8),
        Text('${q.estimatedChange >= 0 ? '+' : ''}${q.estimatedChangePercent.toStringAsFixed(2)}%',
            style: TextStyle(fontSize: 16, color: color)),
        const SizedBox(height: 4),
        Text('估值时间: ${q.estimateTime}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      ],
    );
  }

  Widget _buildFundInfo() {
    final q = _fundQuote;
    if (q == null) return const SizedBox.shrink();

    final items = [
      ['单位净值', q.nav.toStringAsFixed(4)],
      ['累计净值', q.accNav.toStringAsFixed(4)],
      ['净值日期', q.navDate],
      ['估算涨幅', '${q.estimatedChangePercent >= 0 ? '+' : ''}${q.estimatedChangePercent.toStringAsFixed(2)}%'],
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item[0], style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              const SizedBox(height: 4),
              Text(item[1], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        );
      },
    );
  }
}
