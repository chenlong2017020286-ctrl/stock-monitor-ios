import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/market_provider.dart';
import '../widgets/index_bar.dart';
import '../widgets/quote_card.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MarketProvider>().refreshAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketProvider>(
      builder: (context, provider, _) {
        return RefreshIndicator(
          onRefresh: provider.refreshAll,
          child: ListView(
            children: [
              // 指数栏
              if (provider.indices.isNotEmpty) ...[
                const SizedBox(height: 8),
                IndexBar(indices: provider.indices),
              ],
              const Divider(height: 1),

              // 加载状态
              if (provider.loading)
                const LinearProgressIndicator(),

              // 热门股票
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  '热门股票',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              if (provider.error != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(provider.error!, style: const TextStyle(color: Colors.grey)),
                )
              else if (provider.hotStocks.isEmpty && !provider.loading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('暂无数据', style: TextStyle(color: Colors.grey))),
                )
              else
                ...provider.hotStocks.map((q) => QuoteCard(
                      quote: q,
                      onTap: () => Navigator.pushNamed(context, '/detail',
                          arguments: {'code': q.code, 'name': q.name, 'type': 'stock'}),
                    )),

              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}
