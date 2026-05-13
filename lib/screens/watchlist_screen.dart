import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/watchlist_provider.dart';
import '../widgets/quote_card.dart';
import '../widgets/fund_quote_card.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = context.read<WatchlistProvider>();
      provider.loadWatchlist();
      if (provider.stockCodes.isNotEmpty || provider.fundCodes.isNotEmpty) {
        provider.refreshQuotes();
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _showAddDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('添加自选'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                decoration: const InputDecoration(
                  hintText: '股票: sh600519  基金: 000001',
                  border: OutlineInputBorder(),
                  helperText: '股票代码格式: sh/sz/hk + 数字',
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('添加'),
            ),
          ],
        );
      },
    );

    if (result == null || result.isEmpty || !mounted) return;

    final code = result;
    if (!WatchlistProvider.isValidCode(code)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('代码格式不正确，示例: sh600519 或 000001')),
        );
      }
      return;
    }

    final provider = context.read<WatchlistProvider>();
    final normalized = code.toLowerCase();
    if (normalized.startsWith('sh') || normalized.startsWith('sz') || normalized.startsWith('hk')) {
      await provider.addStock(normalized);
    } else {
      await provider.addFund(normalized);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WatchlistProvider>(
      builder: (context, provider, _) {
        final hasData = provider.stockCodes.isNotEmpty || provider.fundCodes.isNotEmpty;

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: provider.refreshQuotes,
            child: !hasData
                ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.star_border, size: 48, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('暂无自选', style: TextStyle(color: Colors.grey, fontSize: 15)),
                            SizedBox(height: 4),
                            Text('点击右上角 + 添加', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView(
                    children: [
                      if (provider.loading) const LinearProgressIndicator(),
                      if (provider.error != null)
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(provider.error!, style: const TextStyle(color: Colors.red)),
                        ),
                      // 股票
                      ...provider.stockQuotes.map((q) => QuoteCard(
                            quote: q,
                            onTap: () => Navigator.pushNamed(context, '/detail',
                                arguments: {'code': q.code, 'name': q.name, 'type': 'stock'}),
                          )),
                      // 基金
                      ...provider.fundQuotes.map((q) => FundQuoteCard(
                            quote: q,
                            onTap: () => Navigator.pushNamed(context, '/detail',
                                arguments: {'code': q.code, 'name': q.name, 'type': 'fund'}),
                          )),
                      const SizedBox(height: 20),
                    ],
                  ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddDialog,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
