import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/trade_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('模拟交易', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
            ),
            Card(
              child: ListTile(
                title: const Text('初始资金'),
                subtitle: Text('¥${settings.initialCapital.toStringAsFixed(0)}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showCapitalDialog(context, settings),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                title: const Text('重置模拟账户'),
                subtitle: const Text('清空所有持仓和交易记录'),
                trailing: const Icon(Icons.refresh),
                onTap: () => _showResetDialog(context),
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('行情设置', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
            ),
            Card(
              child: ListTile(
                title: const Text('刷新间隔'),
                subtitle: Text('${settings.refreshInterval}秒'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showRefreshDialog(context, settings),
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('关于', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
            ),
            Card(
              child: ListTile(
                title: const Text('股票行情App'),
                subtitle: const Text('v1.0.0 • 数据来源: 新浪财经/天天基金'),
                onTap: null,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCapitalDialog(BuildContext context, SettingsProvider settings) {
    final controller = TextEditingController(text: settings.initialCapital.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('设置初始资金'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '金额（元）',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value > 0) {
                settings.setInitialCapital(value);
                Navigator.pop(ctx);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showRefreshDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('选择刷新间隔'),
        children: [3, 5, 10, 15, 30].map((s) {
          return SimpleDialogOption(
            onPressed: () {
              settings.setRefreshInterval(s);
              Navigator.pop(ctx);
            },
            child: Text('${s}秒${s == 5 ? '（推荐）' : ''}'),
          );
        }).toList(),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('重置模拟账户'),
        content: const Text('确定要重置吗？将清空所有持仓和交易记录，可用资金恢复为初始值。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              final settings = context.read<SettingsProvider>();
              context.read<TradeProvider>().resetAccount(settings.initialCapital);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('账户已重置')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('确认重置'),
          ),
        ],
      ),
    );
  }
}
