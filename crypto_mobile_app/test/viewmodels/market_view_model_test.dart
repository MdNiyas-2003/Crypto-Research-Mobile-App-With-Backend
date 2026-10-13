import 'package:crypto_mobile_app/models/coin.dart';
import 'package:crypto_mobile_app/models/global_market_stats.dart';
import 'package:crypto_mobile_app/repositories/coin_repository.dart';
import 'package:crypto_mobile_app/viewmodels/market_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MarketViewModel viewModel;
  late _FakeCoinRepository repository;

  setUp(() {
    repository = _FakeCoinRepository([
      _coin(
        id: 'bitcoin',
        name: 'Bitcoin',
        symbol: 'BTC',
        price: 100,
        marketCap: 1000,
        volume: 250,
        change24h: 1,
        change7d: 4,
      ),
      _coin(
        id: 'ethereum',
        name: 'Ethereum',
        symbol: 'ETH',
        price: 50,
        marketCap: 500,
        volume: 600,
        change24h: -1,
        change7d: -2,
      ),
      _coin(
        id: 'solana',
        name: 'Solana',
        symbol: 'SOL',
        price: 10,
        marketCap: 100,
        volume: 100,
        change24h: 3,
        change30d: 8,
      ),
    ]);
    viewModel = MarketViewModel(repository);
  });

  test(
    'filters and search update the current list without reloading',
    () async {
      await viewModel.loadCoins();

      viewModel.setFilter(MarketFilter.bitcoin);
      expect(viewModel.coins.map((coin) => coin.id), ['bitcoin']);

      viewModel.setFilter(MarketFilter.ethereum);
      expect(viewModel.coins.map((coin) => coin.id), ['ethereum']);

      viewModel.setFilter(MarketFilter.all);
      viewModel.setSearchQuery('sol');
      expect(viewModel.coins.map((coin) => coin.id), ['solana']);
      expect(repository.requestCount, 1);
    },
  );

  test('sorts the filtered list by volume and toggles direction', () async {
    await viewModel.loadCoins();
    viewModel.setFilter(MarketFilter.all);
    viewModel.setSort(MarketSort.volume);

    expect(viewModel.coins.map((coin) => coin.id), [
      'ethereum',
      'bitcoin',
      'solana',
    ]);

    viewModel.toggleSortDirection();
    expect(viewModel.coins.map((coin) => coin.id), [
      'solana',
      'bitcoin',
      'ethereum',
    ]);
  });

  test('sorts by price and market capitalization', () async {
    await viewModel.loadCoins();

    viewModel.setSort(MarketSort.price);
    expect(viewModel.coins.map((coin) => coin.id), [
      'bitcoin',
      'ethereum',
      'solana',
    ]);

    viewModel.setSort(MarketSort.marketCap);
    viewModel.toggleSortDirection();
    expect(viewModel.coins.map((coin) => coin.id), [
      'solana',
      'ethereum',
      'bitcoin',
    ]);
  });

  test('missing period changes remain last in either sort direction', () async {
    await viewModel.loadCoins();
    viewModel.setSort(MarketSort.change);
    viewModel.setPeriod(MarketPeriod.week);

    expect(viewModel.coins.last.id, 'solana');

    viewModel.toggleSortDirection();
    expect(viewModel.coins.last.id, 'solana');
  });
}

Coin _coin({
  required String id,
  required String name,
  required String symbol,
  required double price,
  required double marketCap,
  required double volume,
  required double? change24h,
  double? change7d,
  double? change30d,
}) => Coin(
  id: id,
  name: name,
  symbol: symbol,
  imageUrl: '',
  priceUsd: price,
  marketCapUsd: marketCap,
  volumeUsd: volume,
  change24h: change24h,
  change7d: change7d,
  change30d: change30d,
  rank: null,
);

class _FakeCoinRepository implements CoinRepository {
  _FakeCoinRepository(this.coins);

  final List<Coin> coins;
  int requestCount = 0;

  @override
  Future<List<Coin>> getMarketCoins({
    int perPage = 100,
    List<String>? ids,
    bool includeSparkline = false,
  }) async {
    requestCount++;
    return coins;
  }

  @override
  Future<Map<String, dynamic>> getCoinDetails(String id) =>
      throw UnimplementedError();

  @override
  Future<Map<String, dynamic>> getMarketChart(
    String id, {
    required String days,
  }) => throw UnimplementedError();

  @override
  Future<GlobalMarketStats> getGlobalStats() => throw UnimplementedError();

  @override
  Future<List<Coin>> getTopGainers({int count = 3}) =>
      throw UnimplementedError();

  @override
  Future<Map<String, dynamic>> getSentiment() => throw UnimplementedError();
}
