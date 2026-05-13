import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/trade_provider.dart';
import '../widgets/position_card.dart';

class TradeScreen extends StatefulWidget {
  const TradeScreen({super.key});

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() => context.read<TradeProvider>().loadData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TradeProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            // 账户概览
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A237E), Color(0xFF283593)],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '总资产: ¥${provider.totalAsset.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _accountItem('持仓市值', '¥${(provider.totalAsset - provider.availableCash).toStringAsFixed(2)}'),
                      _accountItem('可用资金', '¥${provider.availableCash.toStringAsFixed(2)}'),
                      _accountItem('累计盈亏', '${provider.totalProfitLoss >= 0 ? '+' : ''}¥${provider.totalProfitLoss.toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '收益率: ${provider.totalProfitLossPercent >= 0 ? '+' : ''}${provider.totalProfitLossPercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: provider.totalProfitLoss >= 0 ? Colors.red.shade200 : Colors.green.shade200,
                    ),
                  ),
                ],
              ),
            ),

            // Tab 栏
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: '持仓'),
                Tab(text: '买入'),
                Tab(text: '记录'),
              ],
            ),

            // Tab 内容
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPositionsTab(provider),
                  _buildBuyTab(provider),
                  _buildOrdersTab(provider),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _accountItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
      ],
    );
  }

  Widget _buildPositionsTab(TradeProvider provider) {
    if (provider.positions.isEmpty) {
      return const Center(child: Text('暂无持仓', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      itemCount: provider.positions.length,
      itemBuilder: (context, index) {
        final pos = provider.positions[index];
        return PositionCard(
          position: pos,
          onSell: () => _showSellDialog(pos.code, pos.name, pos.currentPrice, pos.quantity),
        );
      },
    );
  }

  Widget _buildBuyTab(TradeProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 快速买入
        Center(
          child: Text(
            '可用资金: ¥${provider.availableCash.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '输入股票代码和买入信息来进行模拟交易',
          style: TextStyle(color: Colors.grey, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        _buildQuickBuyForm(provider),
      ],
    );
  }

  final _codeCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();

  Widget _buildQuickBuyForm(TradeProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _codeCtrl,
              decoration: const InputDecoration(
                labelText: '股票代码',
                hintText: '如 sh600519',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '买入价格',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '买入数量（股）',
                hintText: '100的整数倍',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final code = _codeCtrl.text.trim();
                  final price = double.tryParse(_priceCtrl.text);
                  final qty = int.tryParse(_qtyCtrl.text);
                  if (code.isEmpty || price == null || qty == null) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('请填写完整信息')),
                      );
                    }
                    return;
                  }
                  final success = await provider.buy(
                    code: code,
                    name: code, // 实际应用需要从行情获取名称
                    price: price,
                    quantity: qty,
                    market: code.startsWith('sh') ? 'sh' : 'sz',
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(success ? '买入成功' : '资金不足')),
                    );
                    if (success) {
                      _codeCtrl.clear();
                      _priceCtrl.clear();
                      _qtyCtrl.clear();
                    }
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('模拟买入', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab(TradeProvider provider) {
    if (provider.orders.isEmpty) {
      return const Center(child: Text('暂无交易记录', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      itemCount: provider.orders.length,
      itemBuilder: (context, index) {
        final order = provider.orders[index];
        final isBuy = order.type == OrderType.buy;
        return ListTile(
          title: Text('${isBuy ? '买入' : '卖出'} ${order.name}'),
          subtitle: Text('${order.quantity}股 × ¥${order.price.toStringAsFixed(2)}'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '¥${order.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isBuy ? Colors.red : Colors.green,
                ),
              ),
              Text(
                '${order.createTime.month}/${order.createTime.day} ${order.createTime.hour}:${order.createTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSellDialog(String code, String name, double price, int maxQty) {
    final qtyCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('卖出 $name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('当前价: ¥${price.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '卖出数量',
                hintText: '最多 $maxQty 股',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () async {
              final qty = int.tryParse(qtyCtrl.text);
              if (qty == null || qty <= 0) return;
              if (qty > maxQty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('持仓不足')),
                );
                return;
              }
              Navigator.pop(ctx);
              await context.read<TradeProvider>().sell(
                    code: code,
                    price: price,
                    quantity: qty,
                  );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('确认卖出'),
          ),
        ],
      ),
    );
  }
}
