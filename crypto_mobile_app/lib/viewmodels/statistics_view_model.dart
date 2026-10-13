import 'package:flutter/foundation.dart';

import '../models/coin.dart';
import '../models/global_market_stats.dart';
import '../models/market_sentiment.dart';
import '../repositories/coin_repository.dart';

class StatisticsViewModel extends ChangeNotifier {
  StatisticsViewModel(this._repository);

  final CoinRepository _repository;
  GlobalMarketStats? _stats;
  MarketSentiment? _sentiment;
  List<Coin> _topGainers = [];
  String? _errorMessage;
  String? _sentimentError;
  String? _gainersError;
  bool _isLoading = false;

  GlobalMarketStats? get stats => _stats;
  MarketSentiment? get sentiment => _sentiment;
  List<Coin> get topGainers => List.unmodifiable(_topGainers);
  String? get errorMessage => _errorMessage;
  String? get sentimentError => _sentimentError;
  String? get gainersError => _gainersError;
  bool get isLoading => _isLoading;

  Future<void> loadStats() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    await Future.wait([
      _loadGlobalStats(),
      _loadSentiment(),
      _loadTopGainers(),
    ]);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadGlobalStats() async {
    try {
      _stats = await _repository.getGlobalStats();
      _errorMessage = null;
    } catch (error) {
      debugPrint('Could not load global market statistics: $error');
      _errorMessage = 'Could not load global market statistics.';
    }
  }

  Future<void> _loadSentiment() async {
    try {
      final response = await _repository.getSentiment();
      final rows = response['data'] as List<dynamic>?;
      if (rows == null || rows.isEmpty || rows.first is! Map<String, dynamic>) {
        throw const FormatException('No market sentiment data returned');
      }
      _sentiment = MarketSentiment.fromJson(
        rows.first as Map<String, dynamic>,
      );
      _sentimentError = null;
    } catch (error) {
      debugPrint('Could not load market sentiment: $error');
      _sentimentError = 'Sentiment data is unavailable.';
    }
  }

  Future<void> _loadTopGainers() async {
    try {
      _topGainers = await _repository.getTopGainers();
      _gainersError = null;
    } catch (error) {
      debugPrint('Could not load top gainers: $error');
      _gainersError = 'Top gainers are unavailable.';
    }
  }
}
