class ChartPoint {
  const ChartPoint({required this.timestamp, required this.price});

  final DateTime timestamp;
  final double price;

  factory ChartPoint.fromJson(List<dynamic> json) {
    return ChartPoint(
      timestamp: DateTime.fromMillisecondsSinceEpoch((json[0] as num).toInt()),
      price: (json[1] as num).toDouble(),
    );
  }
}
