import 'package:crypto_mobile_app/models/chart_point.dart';
import 'package:crypto_mobile_app/viewmodels/coin_details_view_model.dart';
import 'package:crypto_mobile_app/widgets/coin_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('price chart timelines stay readable across all ranges', (
    tester,
  ) async {
    final end = DateTime(2026, 10, 13);

    for (final range in ChartRange.values) {
      final duration = switch (range) {
        ChartRange.day => const Duration(days: 1),
        ChartRange.week => const Duration(days: 7),
        ChartRange.month => const Duration(days: 30),
        ChartRange.year => const Duration(days: 365),
      };
      final step = switch (range) {
        ChartRange.day => const Duration(hours: 1),
        ChartRange.week => const Duration(hours: 3),
        ChartRange.month => const Duration(hours: 12),
        ChartRange.year => const Duration(days: 1),
      };
      final start = end.subtract(duration);
      final points = <ChartPoint>[
        for (
          var timestamp = start;
          !timestamp.isAfter(end);
          timestamp = timestamp.add(step)
        )
          ChartPoint(
            timestamp: timestamp,
            price: 100 + timestamp.millisecondsSinceEpoch % 1000 / 100,
          ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                child: PriceChartCard(
                  points: points,
                  range: range,
                  isLoading: false,
                  errorMessage: null,
                  onRangeSelected: (_) {},
                  onRetry: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: range.label);
      final horizontalChart = find.byWidgetPredicate(
        (widget) =>
            widget is SingleChildScrollView &&
            widget.scrollDirection == Axis.horizontal,
      );
      final chartScrollable = find.descendant(
        of: horizontalChart,
        matching: find.byType(Scrollable),
      );
      final position = tester.state<ScrollableState>(chartScrollable).position;
      expect(position.maxScrollExtent, greaterThan(0), reason: range.label);
      final initialOffset = position.pixels;
      await tester.drag(horizontalChart, const Offset(120, 0));
      await tester.pumpAndSettle();
      expect(position.pixels, isNot(initialOffset), reason: range.label);
      expect(tester.takeException(), isNull, reason: range.label);

      final timelineLabels = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data != null &&
            RegExp(
              r'^(?:\d{2}:\d{2}|[A-Z][a-z]{2} \d{1,2}|[A-Z][a-z]{2} \d{2})$',
            ).hasMatch(widget.data!),
      );
      expect(
        timelineLabels.evaluate().length,
        lessThanOrEqualTo(7),
        reason: '${range.label} timeline should not crowd the chart',
      );
    }
  });
}
