import 'package:crypto_mobile_app/models/coin_details.dart';
import 'package:crypto_mobile_app/widgets/coin_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('market statistic cards fit a narrow phone layout', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: CoinInfoGrid(
              details: const CoinDetails(
                name: 'Bitcoin',
                symbol: 'BTC',
                imageUrl: '',
                priceUsd: 68000,
                change24h: 1.2,
                marketCapUsd: 1300000000000,
                volume24hUsd: 25000000000,
                high24hUsd: 69000,
                low24hUsd: 67000,
                marketCapRank: 1,
                circulatingSupply: 19700000,
                totalSupply: 19700000,
                maxSupply: 21000000,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('MARKET CAP'), findsOneWidget);
    expect(find.text('24H VOLUME'), findsOneWidget);
    expect(find.text('TOTAL SUPPLY'), findsOneWidget);
    expect(find.text('MAXIMUM SUPPLY'), findsOneWidget);
    expect(find.text('#1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
