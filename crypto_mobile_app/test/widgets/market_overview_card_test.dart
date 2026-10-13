import 'package:crypto_mobile_app/core/app_constants.dart';
import 'package:crypto_mobile_app/models/global_market_stats.dart';
import 'package:crypto_mobile_app/widgets/market_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('market overview card remains legible with live stats', (
    tester,
  ) async {
    AppColors.setLightMode(true);
    addTearDown(() => AppColors.setLightMode(false));
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: MarketOverviewCard(
              stats: const GlobalMarketStats(
                marketCapUsd: 2830000000000,
                volumeUsd: 95500000000,
                bitcoinDominance: 59.3,
                activeCryptocurrencies: 12000,
                marketCapChange24h: -2.91,
                activeMarkets: 900,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('GLOBAL MARKET CAP'), findsOneWidget);
    expect(find.text('24H VOLUME'), findsOneWidget);
    expect(find.text('BTC DOMINANCE'), findsOneWidget);
    expect(find.text('-2.91%'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('market overview card explains when live stats are missing', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(20),
            child: MarketOverviewCard(stats: null),
          ),
        ),
      ),
    );

    expect(find.text('Live data unavailable'), findsOneWidget);
    expect(find.text('—'), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });
}
