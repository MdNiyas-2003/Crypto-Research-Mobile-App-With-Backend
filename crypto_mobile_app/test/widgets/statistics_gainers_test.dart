import 'package:crypto_mobile_app/models/coin.dart';
import 'package:crypto_mobile_app/widgets/statistics_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tapping a top gainer returns its coin', (tester) async {
    const coin = Coin(
      id: 'bitcoin',
      name: 'Bitcoin',
      symbol: 'BTC',
      imageUrl: '',
      priceUsd: 65000,
      marketCapUsd: 1200000000000,
      change24h: 2.4,
      rank: 1,
    );
    Coin? tappedCoin;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              TopGainersList(
                coins: const [coin],
                error: null,
                onCoinTap: (value) => tappedCoin = value,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Bitcoin'));
    expect(tappedCoin, same(coin));
    expect(tester.takeException(), isNull);
  });
}
