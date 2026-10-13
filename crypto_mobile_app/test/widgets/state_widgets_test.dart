import 'package:crypto_mobile_app/widgets/state_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('compact empty state fits a short area above the keyboard', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 100,
            child: EmptyState(
              title: 'No coins found',
              message: 'Try another search or market filter.',
              compact: true,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
