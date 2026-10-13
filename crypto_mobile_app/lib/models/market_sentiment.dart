class MarketSentiment {
  const MarketSentiment({required this.value, required this.classification});

  final int value;
  final String classification;

  factory MarketSentiment.fromJson(Map<String, dynamic> json) {
    final value = int.tryParse(json['value']?.toString() ?? '');
    final classification = json['value_classification'] as String?;
    if (value == null || classification == null) {
      throw const FormatException('Invalid market sentiment response');
    }
    return MarketSentiment(value: value, classification: classification);
  }
}
