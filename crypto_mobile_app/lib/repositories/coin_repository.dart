import '../models/coin.dart';
import '../models/global_market_stats.dart';
import '../services/api_service.dart';

class CoinRepository {
  const CoinRepository(this._apiService);

  final ApiService _apiService;

  Future<List<Coin>> getMarketCoins({
    int perPage = 100,
    List<String>? ids,
    bool includeSparkline = false,
  }) async {
    final rows = await _apiService.getMarkets(
      perPage: perPage,
      ids: ids,
      includeSparkline: includeSparkline,
    );
    return rows.whereType<Map<String, dynamic>>().map(Coin.fromJson).toList();
  }

  Future<Map<String, dynamic>> getCoinDetails(String id) =>
      _apiService.getCoinDetails(id);

  Future<Map<String, dynamic>> getMarketChart(
    String id, {
    required String days,
  }) => _apiService.getMarketChart(id, days: days);

  Future<GlobalMarketStats> getGlobalStats() async =>
      GlobalMarketStats.fromJson(await _apiService.getGlobal());

  Future<List<Coin>> getTopGainers({int count = 3}) async {
    final coins = await getMarketCoins(perPage: 100, includeSparkline: true);
    final gainers = coins.where((coin) => (coin.change24h ?? 0) > 0).toList()
      ..sort(
        (first, second) =>
            (second.change24h ?? 0).compareTo(first.change24h ?? 0),
      );
    return gainers.take(count).toList();
  }

  Future<Map<String, dynamic>> getSentiment() => _apiService.getSentiment();
}
