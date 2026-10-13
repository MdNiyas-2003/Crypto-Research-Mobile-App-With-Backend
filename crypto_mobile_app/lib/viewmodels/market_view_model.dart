import 'package:flutter/foundation.dart';

import '../core/app_constants.dart';
import '../models/coin.dart';
import '../repositories/coin_repository.dart';

enum MarketFilter { all, bitcoin, ethereum, BNB }

enum MarketSort {
  price('Price'),
  marketCap('Market Cap'),
  volume('Volume'),
  change('Change %');

  const MarketSort(this.label);
  final String label;
}

enum MarketPeriod {
  day('24H', '24h'),
  week('7D', '7d'),
  month('30D', '30d');

  const MarketPeriod(this.label, this.apiValue);
  final String label;
  final String apiValue;
}

class MarketViewModel extends ChangeNotifier {
  MarketViewModel(this._repository);

  final CoinRepository _repository;
  List<Coin> _coins = [];
  String _searchQuery = '';
  String? _errorMessage;
  MarketFilter _filter = MarketFilter.all;
  MarketPeriod _period = MarketPeriod.day;
  MarketSort _sort = MarketSort.marketCap;
  bool _sortAscending = false;
  bool _isLoading = false;
  bool _hasLoaded = false;

  List<Coin> get coins {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = _coins.where((coin) {
      final matchesQuery =
          query.isEmpty ||
          coin.name.toLowerCase().contains(query) ||
          coin.symbol.toLowerCase().contains(query);
      final matchesFilter = switch (_filter) {
        MarketFilter.all => true,
        MarketFilter.bitcoin =>
          coin.id.toLowerCase() == 'bitcoin' ||
              coin.symbol.toLowerCase() == 'btc',
        MarketFilter.ethereum =>
          coin.id.toLowerCase() == 'ethereum' ||
              coin.symbol.toLowerCase() == 'eth',
        MarketFilter.BNB =>
          coin.id.toLowerCase() == 'binancecoin' ||
              coin.symbol.toLowerCase() == 'bnb',
      };
      return matchesQuery && matchesFilter;
    }).toList();
    filtered.sort(_compareCoins);
    return List.unmodifiable(filtered);
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasLoaded => _hasLoaded;
  String get searchQuery => _searchQuery;
  MarketFilter get filter => _filter;
  MarketPeriod get period => _period;
  MarketSort get sort => _sort;
  bool get sortAscending => _sortAscending;

  Future<void> loadCoins() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _coins = await _repository.getMarketCoins();
      _hasLoaded = true;
    } catch (error) {
      debugPrint(
        'Could not load market data from ${AppConstants.apiBaseUrl}: $error',
      );
      _errorMessage =
          'Could not load market data. Check your connection and try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(MarketFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void setPeriod(MarketPeriod period) {
    _period = period;
    notifyListeners();
  }

  void setSort(MarketSort sort) {
    _sort = sort;
    notifyListeners();
  }

  void toggleSortDirection() {
    setSortAscending(!_sortAscending);
  }

  void setSortAscending(bool ascending) {
    if (_sortAscending == ascending) return;
    _sortAscending = ascending;
    notifyListeners();
  }

  int _compareCoins(Coin first, Coin second) {
    if (_sort == MarketSort.change) {
      final firstChange = first.changeForPeriod(_period.apiValue);
      final secondChange = second.changeForPeriod(_period.apiValue);
      if (firstChange == null) return secondChange == null ? 0 : 1;
      if (secondChange == null) return -1;
      final comparison = firstChange.compareTo(secondChange);
      return _sortAscending ? comparison : -comparison;
    }

    final comparison = switch (_sort) {
      MarketSort.price => first.priceUsd.compareTo(second.priceUsd),
      MarketSort.marketCap => first.marketCapUsd.compareTo(second.marketCapUsd),
      MarketSort.volume => first.volumeUsd.compareTo(second.volumeUsd),
      MarketSort.change => 0,
    };
    return _sortAscending ? comparison : -comparison;
  }
}
