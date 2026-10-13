class CoinDetails {
  const CoinDetails({
    required this.name,
    required this.symbol,
    required this.imageUrl,
    required this.priceUsd,
    required this.change24h,
    required this.marketCapUsd,
    required this.volume24hUsd,
    required this.high24hUsd,
    required this.low24hUsd,
    required this.marketCapRank,
    required this.circulatingSupply,
    this.totalSupply,
    this.maxSupply,
  });

  final String name;
  final String symbol;
  final String imageUrl;
  final double? priceUsd;
  final double? change24h;
  final double? marketCapUsd;
  final double? volume24hUsd;
  final double? high24hUsd;
  final double? low24hUsd;
  final int? marketCapRank;
  final double? circulatingSupply;
  final double? totalSupply;
  final double? maxSupply;

  factory CoinDetails.fromJson(Map<String, dynamic> json) {
    final market = json['market_data'] as Map<String, dynamic>? ?? {};
    final usd = (market['current_price'] as Map<String, dynamic>? ?? {})['usd'];
    final marketCap =
        (market['market_cap'] as Map<String, dynamic>? ?? {})['usd'];
    final volume =
        (market['total_volume'] as Map<String, dynamic>? ?? {})['usd'];
    final high = (market['high_24h'] as Map<String, dynamic>? ?? {})['usd'];
    final low = (market['low_24h'] as Map<String, dynamic>? ?? {})['usd'];
    final image = json['image'] as Map<String, dynamic>? ?? {};

    return CoinDetails(
      name: json['name'] as String? ?? 'Unknown coin',
      symbol: (json['symbol'] as String? ?? '').toUpperCase(),
      imageUrl: image['large'] as String? ?? image['small'] as String? ?? '',
      priceUsd: (usd as num?)?.toDouble(),
      change24h: (market['price_change_percentage_24h'] as num?)?.toDouble(),
      marketCapUsd: (marketCap as num?)?.toDouble(),
      volume24hUsd: (volume as num?)?.toDouble(),
      high24hUsd: (high as num?)?.toDouble(),
      low24hUsd: (low as num?)?.toDouble(),
      marketCapRank: (json['market_cap_rank'] as num?)?.toInt(),
      circulatingSupply: (market['circulating_supply'] as num?)?.toDouble(),
      totalSupply: (market['total_supply'] as num?)?.toDouble(),
      maxSupply: (market['max_supply'] as num?)?.toDouble(),
    );
  }
}
