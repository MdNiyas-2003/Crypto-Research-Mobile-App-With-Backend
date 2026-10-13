import 'package:flutter/foundation.dart';

import '../models/coin.dart';
import '../repositories/coin_repository.dart';
import '../repositories/watchlist_repository.dart';

class WatchlistViewModel extends ChangeNotifier {
  WatchlistViewModel(this._coinRepository, this._watchlistRepository);

  final CoinRepository _coinRepository;
  final WatchlistRepository _watchlistRepository;
  List<String> _coinIds = [];
  List<Coin> _coins = [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;

  List<String> get coinIds => List.unmodifiable(_coinIds);
  List<Coin> get coins => List.unmodifiable(_coins);
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;

  bool contains(String coinId) => _coinIds.contains(coinId);

  Future<void> loadWatchlist() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _coinIds = await _watchlistRepository.getCoinIds();
      _coins = _coinIds.isEmpty
          ? []
          : await _coinRepository.getMarketCoins(ids: _coinIds);
      _hasLoaded = true;
    } catch (_) {
      _errorMessage = 'Could not load your saved coins.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleCoin(Coin coin) async {
    final wasSaved = contains(coin.id);
    if (wasSaved) {
      _coinIds = _coinIds.where((id) => id != coin.id).toList();
      _coins = _coins.where((item) => item.id != coin.id).toList();
    } else {
      _coinIds = [..._coinIds, coin.id];
    }
    notifyListeners();

    try {
      await _watchlistRepository.saveCoinIds(_coinIds);
      if (!wasSaved) {
        final refreshedCoins = await _coinRepository.getMarketCoins(
          ids: _coinIds,
        );
        _coins = refreshedCoins;
        _errorMessage = null;
        notifyListeners();
      }
    } catch (_) {
      _errorMessage = 'Could not update your watchlist. Please retry.';
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_isLoading) return;
    if (_coinIds.isEmpty) {
      _hasLoaded = true;
      notifyListeners();
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _coins = await _coinRepository.getMarketCoins(ids: _coinIds);
    } catch (_) {
      _errorMessage = 'Could not refresh watchlist prices.';
    } finally {
      _isLoading = false;
      _hasLoaded = true;
      notifyListeners();
    }
  }
}
