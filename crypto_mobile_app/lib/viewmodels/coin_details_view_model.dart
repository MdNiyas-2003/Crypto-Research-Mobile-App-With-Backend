import 'package:flutter/foundation.dart';

import '../models/chart_point.dart';
import '../models/coin.dart';
import '../models/coin_details.dart';
import '../repositories/coin_repository.dart';

enum ChartRange {
  day('24H', '1'),
  week('7D', '7'),
  month('30D', '30'),
  year('1Y', '365');

  const ChartRange(this.label, this.days);
  final String label;
  final String days;
}

class CoinDetailsViewModel extends ChangeNotifier {
  CoinDetailsViewModel(this._repository, this.coin);

  final CoinRepository _repository;
  final Coin coin;
  CoinDetails? _details;
  List<ChartPoint> _chartPoints = [];
  ChartRange _range = ChartRange.week;
  bool _isLoadingDetails = false;
  bool _isLoadingChart = false;
  String? _detailsError;
  String? _chartError;

  CoinDetails? get details => _details;
  List<ChartPoint> get chartPoints => List.unmodifiable(_chartPoints);
  ChartRange get range => _range;
  bool get isLoadingDetails => _isLoadingDetails;
  bool get isLoadingChart => _isLoadingChart;
  String? get detailsError => _detailsError;
  String? get chartError => _chartError;

  Future<void> load() async {
    await Future.wait([loadDetails(), loadChart(_range)]);
  }

  Future<void> loadDetails() async {
    if (_isLoadingDetails) return;
    _isLoadingDetails = true;
    _detailsError = null;
    notifyListeners();
    try {
      _details = CoinDetails.fromJson(
        await _repository.getCoinDetails(coin.id),
      );
    } catch (_) {
      _detailsError = 'Could not load coin details. Try again.';
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  Future<void> loadChart(ChartRange range) async {
    if (_isLoadingChart) return;
    _range = range;
    _isLoadingChart = true;
    _chartError = null;
    notifyListeners();
    try {
      final response = await _repository.getMarketChart(
        coin.id,
        days: range.days,
      );
      final rows = response['prices'] as List<dynamic>? ?? [];
      _chartPoints = rows
          .whereType<List<dynamic>>()
          .where((row) => row.length >= 2)
          .map(ChartPoint.fromJson)
          .toList();
      if (_chartPoints.isEmpty) {
        _chartError = 'No price history is available for this range.';
      }
    } catch (_) {
      _chartError = 'Could not load chart data. Try another range.';
    } finally {
      _isLoadingChart = false;
      notifyListeners();
    }
  }
}
