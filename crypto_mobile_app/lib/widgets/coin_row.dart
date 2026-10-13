import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/app_constants.dart';
import '../models/coin.dart';

class CoinRow extends StatelessWidget {
  const CoinRow({
    super.key,
    required this.coin,
    this.onTap,
    this.trailing,
    this.changePeriod = '24h',
  });

  final Coin coin;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String changePeriod;

  static final _priceFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );
  static final _smallPriceFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 4,
  );
  static final _marketCapFormat = NumberFormat.compactCurrency(
    symbol: '\$',
    decimalDigits: 1,
  );

  @override
  Widget build(BuildContext context) {
    final change = coin.changeForPeriod(changePeriod);
    final changeColor = change == null
        ? AppColors.secondaryText
        : change >= 0
        ? AppColors.positive
        : AppColors.negative;

    return InkWell(
      onTap: onTap,
      child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            _CoinAvatar(coin: coin),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coin.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:  TextStyle(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${coin.symbol}  ·  MCap ${_marketCapFormat.format(coin.marketCapUsd)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:  TextStyle(
                      fontSize: 11,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  (coin.priceUsd.abs() < 1 ? _smallPriceFormat : _priceFormat)
                      .format(coin.priceUsd),
                  style:  TextStyle(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w700,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  change == null
                      ? '—'
                      : '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: changeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}

class _CoinAvatar extends StatelessWidget {
  const _CoinAvatar({required this.coin});

  final Coin coin;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: 42,
        height: 42,
        child: coin.imageUrl.isEmpty
            ? _fallback()
            : Image.network(
                coin.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _fallback(),
              ),
      ),
    );
  }

  Widget _fallback() => ColoredBox(
    color: AppColors.elevated,
    child: Center(
      child: Text(
        coin.symbol.isEmpty ? '?' : coin.symbol[0],
        style:  TextStyle(
          color: AppColors.accent,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}
