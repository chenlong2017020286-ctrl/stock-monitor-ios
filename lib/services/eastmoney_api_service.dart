import 'package:dio/dio.dart';
import '../models/kline_data.dart';
import 'package:flutter/foundation.dart';

class EastMoneyApiService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  static const _baseUrl = 'https://push2his.eastmoney.com';

  Future<List<KlineData>> getKlineData({
    required String code,
    required String market,
    int period = 101,
    int count = 120,
  }) async {
    final secid = market == 'sh' ? '1.$code' : '0.$code';
    try {
      final response = await _dio.get(
        '$_baseUrl/api/qt/stock/kline/get',
        queryParameters: {
          'secid': secid,
          'fields1': 'f1,f2,f3,f4,f5,f6',
          'fields2': 'f51,f52,f53,f54,f55,f56,f57,f58,f59,f60,f61',
          'klt': period,
          'fqt': 1,
          'end': '20500101',
          'lmt': count,
        },
        options: Options(
          headers: {'Referer': 'https://quote.eastmoney.com/'},
        ),
      );

      final data = response.data as Map<String, dynamic>;
      final klines = data['data']?['klines'] as List<dynamic>?;
      if (klines == null) return [];

      return klines.map((item) {
        final parts = (item as String).split(',');
        return KlineData(
          date: DateTime.parse(parts[0]),
          open: double.tryParse(parts[1]) ?? 0,
          close: double.tryParse(parts[2]) ?? 0,
          high: double.tryParse(parts[3]) ?? 0,
          low: double.tryParse(parts[4]) ?? 0,
          volume: double.tryParse(parts[5]) ?? 0,
          amount: double.tryParse(parts[6]) ?? 0,
        );
      }).toList();
    } on DioException catch (e) {
      debugPrint('东方财富K线API请求失败: ${e.message}');
      return [];
    }
  }
}
