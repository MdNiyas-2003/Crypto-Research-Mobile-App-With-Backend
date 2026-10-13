import 'package:dio/dio.dart';

class ApiService {
  const ApiService(this._dio);

  final Dio _dio;

  Future<List<dynamic>> getMarkets({
    String currency = 'usd',
    int perPage = 100,
    List<String>? ids,
    bool includeSparkline = false,
  }) async {
    final queryParameters = <String, dynamic>{
      'vs_currency': currency,
      'order': 'market_cap_desc',
      'per_page': perPage,
      'page': 1,
      'sparkline': includeSparkline,
      'price_change_percentage': '24h,7d,30d',
    };
    if (ids != null && ids.isNotEmpty) {
      queryParameters['ids'] = ids.join(',');
    }

    final response = await _dio.get<List<dynamic>>(
      '/coins/markets',
      queryParameters: queryParameters,
    );
    return response.data ?? const [];
  }

  Future<Map<String, dynamic>> getCoinDetails(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/coins/$id');
    return response.data ?? const {};
  }

  Future<Map<String, dynamic>> getMarketChart(
    String id, {
    required String days,
    String currency = 'usd',
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/coins/$id/market-chart',
      queryParameters: {'vs_currency': currency, 'days': days},
    );
    return response.data ?? const {};
  }

  Future<Map<String, dynamic>> getGlobal() async {
    final response = await _dio.get<Map<String, dynamic>>('/global');
    return response.data ?? const {};
  }

  Future<Map<String, dynamic>> getSentiment() async {
    final response = await _dio.get<Map<String, dynamic>>('/sentiment');
    return response.data ?? const {};
  }
}
