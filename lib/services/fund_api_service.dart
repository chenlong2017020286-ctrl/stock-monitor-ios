import 'package:dio/dio.dart';
import '../models/fund_quote.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class FundApiService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));

  static const _baseUrl = 'https://fundgz.1234567.com.cn';

  Future<FundQuote?> getFundQuote(String code) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/js/$code.js',
        options: Options(
          headers: {'Referer': 'https://fund.eastmoney.com/'},
          responseType: ResponseType.plain,
        ),
      );

      final text = response.data as String;
      return _parseFundQuote(text);
    } on DioException catch (e) {
      debugPrint('天天基金API请求失败: ${e.message}');
      return null;
    }
  }

  FundQuote? _parseFundQuote(String raw) {
    try {
      final start = raw.indexOf('(');
      final end = raw.lastIndexOf(')');
      if (start == -1 || end == -1) return null;

      final jsonStr = raw.substring(start + 1, end);
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return FundQuote.fromTianTian(json);
    } on Exception catch (e) {
      debugPrint('解析基金数据失败: $e');
      return null;
    }
  }

  Future<List<FundQuote>> getFundQuotes(List<String> codes) async {
    final results = <FundQuote>[];
    for (final code in codes) {
      final quote = await getFundQuote(code);
      if (quote != null) results.add(quote);
      await Future.delayed(const Duration(milliseconds: 200));
    }
    return results;
  }
}
