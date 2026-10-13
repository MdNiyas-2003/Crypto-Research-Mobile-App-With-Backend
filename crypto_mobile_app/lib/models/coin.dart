class Coin {
  const Coin({
    required this.id,
    required this.name,
    required this.symbol,
    required this.imageUrl,
    required this.priceUsd,
    required this.marketCapUsd,
    required this.change24h,
    required this.rank,
    this.volumeUsd = 0,
    this.sparkline = const [],
    this.change7d,
    this.change30d,
  });

  final String id;
  final String name;
  final String symbol;
  final String imageUrl;
  final double priceUsd;
  final double marketCapUsd;
  final double? change24h;
  final int? rank;
  final double volumeUsd;
  final List<double> sparkline;
  final double? change7d;
  final double? change30d;

  double? changeForPeriod(String period) => switch (period) {
    '7d' => change7d,
    '30d' => change30d,
    _ => change24h,
  };

  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown coin',
      symbol: (json['symbol'] as String? ?? '').toUpperCase(),
      imageUrl: json['image'] as String? ?? '',
      priceUsd: (json['current_price'] as num?)?.toDouble() ?? 0,
      marketCapUsd: (json['market_cap'] as num?)?.toDouble() ?? 0,
      volumeUsd: (json['total_volume'] as num?)?.toDouble() ?? 0,
      change24h:
          ((json['price_change_percentage_24h'] ??
                      json['price_change_percentage_24h_in_currency'])
                  as num?)
              ?.toDouble(),
      change7d:
          (json['price_change_percentage_7d_in_currency'] as num?)?.toDouble(),
      change30d:
          (json['price_change_percentage_30d_in_currency'] as num?)?.toDouble(),
      rank: (json['market_cap_rank'] as num?)?.toInt(),
      sparkline:
          ((json['sparkline_in_7d'] as Map<String, dynamic>?)?['price']
                  as List<dynamic>? ??
              const [])
              .whereType<num>()
              .map((price) => price.toDouble())
              .toList(),
    );
  }
}
