import 'package:flutter/material.dart';
import '../models/position.dart';

class PositionCard extends StatelessWidget {
  final Position position;
  final VoidCallback? onSell;

  const PositionCard({super.key, required this.position, this.onSell});

  @override
  Widget build(BuildContext context) {
    final isUp = position.profitLoss >= 0;
    final color = isUp ? Colors.red : Colors.green;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  position.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                position.code.toUpperCase(),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _infoColumn('持仓', '${position.quantity}股'),
              ),
              Expanded(
                child: _infoColumn('成本', position.avgCost.toStringAsFixed(2)),
              ),
              Expanded(
                child: _infoColumn('现价', position.currentPrice.toStringAsFixed(2)),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('盈亏', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 2),
                    Text(
                      '${position.profitLoss >= 0 ? '+' : ''}${position.profitLoss.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
                    ),
                    Text(
                      '${position.profitLossPercent >= 0 ? '+' : ''}${position.profitLossPercent.toStringAsFixed(2)}%',
                      style: TextStyle(fontSize: 11, color: color),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (onSell != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onSell,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: const BorderSide(color: Colors.green),
                ),
                child: const Text('卖出'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
