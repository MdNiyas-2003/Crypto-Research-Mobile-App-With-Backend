import 'package:shared_preferences/shared_preferences.dart';

class WatchlistRepository {
  static const _storageKey = 'watchlist_coin_ids';

  Future<List<String>> getCoinIds() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(_storageKey) ?? [];
  }

  Future<void> saveCoinIds(List<String> ids) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_storageKey, ids);
  }
}
