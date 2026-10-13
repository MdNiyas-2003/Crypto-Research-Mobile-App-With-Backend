class GlobalMarketStats {
  const GlobalMarketStats({
    required this.marketCapUsd,
    required this.volumeUsd,
    required this.bitcoinDominance,
    required this.activeCryptocurrencies,
    required this.marketCapChange24h,
    this.activeMarkets,
  });

  final double? marketCapUsd;
  final double? volumeUsd;
  final double? bitcoinDominance;
  final int? activeCryptocurrencies;
  final double? marketCapChange24h;
  final int? activeMarkets;

  factory GlobalMarketStats.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final marketCap = data['total_market_cap'] as Map<String, dynamic>? ?? {};
    final volume = data['total_volume'] as Map<String, dynamic>? ?? {};
    final dominance =
        data['market_cap_percentage'] as Map<String, dynamic>? ?? {};

    return GlobalMarketStats(
      marketCapUsd: (marketCap['usd'] as num?)?.toDouble(),
      volumeUsd: (volume['usd'] as num?)?.toDouble(),
      bitcoinDominance: (dominance['btc'] as num?)?.toDouble(),
      activeCryptocurrencies: (data['active_cryptocurrencies'] as num?)
          ?.toInt(),
      marketCapChange24h: (data['market_cap_change_percentage_24h_usd'] as num?)
          ?.toDouble(),
      activeMarkets: (data['markets'] as num?)?.toInt(),
    );
  }
}
