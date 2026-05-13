import 'package:dio/dio.dart';
import '../models/stock_quote.dart';
import 'package:flutter/foundation.dart';

class SinaApiService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));

  static const _baseUrl = 'https://hq.sinajs.cn';

  Future<List<StockQuote>> getStockQuotes(List<String> codes) async {
    if (codes.isEmpty) return [];

    final codeStr = codes.join(',');
    try {
      final response = await _dio.get(
        '$_baseUrl/list=$codeStr',
        options: Options(
          headers: {'Referer': 'https://finance.sina.com.cn'},
          responseType: ResponseType.plain,
        ),
      );

      final text = response.data as String;
      return _parseQuotes(text, codes);
    } on DioException catch (e) {
      debugPrint('新浪API请求失败: ${e.message}');
      return [];
    }
  }

  List<StockQuote> _parseQuotes(String raw, List<String> codes) {
    final results = <StockQuote>[];
    final lines = raw.split('\n');

    for (final line in lines) {
      if (line.isEmpty || !line.contains('=')) continue;
      try {
        final start = line.indexOf('"');
        final end = line.lastIndexOf('"');
        if (start == -1 || end == -1) continue;
        final data = line.substring(start + 1, end);
        if (data.isEmpty) continue;

        final codeMatch = RegExp(r'hq_str_(\w+)').firstMatch(line);
        if (codeMatch == null) continue;

        results.add(StockQuote.fromSina(codeMatch.group(1)!, data));
      } on Exception catch (e) {
        debugPrint('解析股票数据失败: $e');
      }
    }
    return results;
  }

  Future<StockQuote?> getStockQuote(String code) async {
    final results = await getStockQuotes([code]);
    return results.isNotEmpty ? results.first : null;
  }
}
