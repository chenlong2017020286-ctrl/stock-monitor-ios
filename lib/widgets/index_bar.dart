import 'package:flutter/material.dart';
import '../models/index_quote.dart';

class IndexBar extends StatelessWidget {
  final List<IndexQuote> indices;

  const IndexBar({super.key, required this.indices});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: indices.length,
        separatorBuilder: (_, __) => const SizedBox(width: 24),
        itemBuilder: (context, index) {
          final idx = indices[index];
          final isUp = idx.change >= 0;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                idx.name,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 6),
              Text(
                idx.currentPoint.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isUp ? Colors.red : Colors.green,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${idx.changePercent >= 0 ? '+' : ''}${idx.changePercent.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 11,
                  color: isUp ? Colors.red : Colors.green,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
