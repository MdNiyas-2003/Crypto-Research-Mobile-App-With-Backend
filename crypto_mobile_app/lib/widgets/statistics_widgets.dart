import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/app_constants.dart';
import '../models/coin.dart';
import '../models/global_market_stats.dart';
import '../models/market_sentiment.dart';

class MarketCapHero extends StatelessWidget {
  const MarketCapHero({
    super.key,
    required this.stats,
    required this.marketCap,
    required this.change,
  });

  final GlobalMarketStats? stats;
  final String marketCap;
  final String change;

  @override
  Widget build(BuildContext context) {
    final percentChange = stats?.marketCapChange24h;
    final changeColor = percentChange == null
        ? AppColors.secondaryText
        : percentChange >= 0
        ? AppColors.positive
        : AppColors.negative;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3435C9), Color(0xFF2859D9), Color(0xFF302A9D)],
        ),
        border: Border.all(
          color: const Color(0xFF5854F0).withValues(alpha: .6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total Market Cap',
                  style: TextStyle(color: Color(0xFFD8DCFF), fontSize: 12),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF192C8D).withValues(alpha: .75),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  '24H',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            marketCap,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 29,
              height: 1.1,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Icon(
                percentChange == null
                    ? Icons.remove
                    : percentChange >= 0
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 14,
                color: changeColor,
              ),
              const SizedBox(width: 3),
              Text(
                change,
                style: TextStyle(
                  color: changeColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 7),
              const Text(
                '(24h)',
                style: TextStyle(color: Color(0xFFD8DCFF), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MarketMetricTile extends StatelessWidget {
  const MarketMetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.change,
    this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? change;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 78),
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
    decoration: BoxDecoration(
      color: AppColors.card,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.secondaryText, fontSize: 10),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (change != null) ...[
                const SizedBox(height: 2),
                Text(
                  change!,
                  style: TextStyle(
                    color: AppColors.positive,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 6),
        Icon(icon, color: iconColor ?? AppColors.accent, size: 25),
      ],
    ),
  );
}

class MarketSentimentCard extends StatelessWidget {
  const MarketSentimentCard({super.key, required this.sentiment});

  final MarketSentiment? sentiment;

  @override
  Widget build(BuildContext context) {
    final score = sentiment?.value;
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 11, 13, 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Market Sentiment',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 6),
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.secondaryText,
                size: 15,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 82,
                  child: score == null
                      ? Center(
                          child: Text(
                            'Unavailable',
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 11,
                            ),
                          ),
                        )
                      : _SentimentGauge(
                          score: score,
                          classification: sentiment!.classification,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(flex: 6, child: _SentimentLegend()),
            ],
          ),
        ],
      ),
    );
  }
}

class _SentimentGauge extends StatelessWidget {
  const _SentimentGauge({required this.score, required this.classification});

  final int score;
  final String classification;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final height = constraints.maxHeight;
      final sentimentColor = score <= 24
          ? AppColors.negative
          : score <= 49
          ? const Color(0xFFFFC928)
          : AppColors.positive;
      return Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 4,
            child: CustomPaint(
              painter: _GaugePainter(score: score),
              size: Size(width, height),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$score',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 20,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  classification,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ).copyWith(color: sentimentColor),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({required this.score});

  final int score;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(5, 3, size.width - 10, (size.height - 3) * 2);
    const colors = [
      Color(0xFFFF354D),
      Color(0xFFFF8B16),
      Color(0xFFFFD21F),
      Color(0xFF9BE229),
      Color(0xFF08B978),
    ];
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    for (var index = 0; index < colors.length; index++) {
      track.color = colors[index];
      canvas.drawArc(
        rect,
        math.pi + math.pi * index / colors.length,
        math.pi / colors.length + .025,
        false,
        track,
      );
    }

    final angle = math.pi + math.pi * score.clamp(0, 100) / 100;
    final center = Offset(size.width / 2, rect.bottom);
    final radius = rect.width / 2;
    final marker = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
    canvas.drawCircle(marker, 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) => oldDelegate.score != score;
}

class _SentimentLegend extends StatelessWidget {
  const _SentimentLegend();

  static const entries = [
    ('Extreme Greed', '75 – 100', Color(0xFF08B978)),
    ('Greed', '50 – 74', Color(0xFF9BE229)),
    ('Neutral', '25 – 49', Color(0xFFFFC928)),
    ('Fear', '0 – 24', Color(0xFFFF4A45)),
  ];

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (final (label, range, color) in entries)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: AppColors.secondaryText, fontSize: 9),
                ),
              ),
              Text(
                range,
                style: TextStyle(color: AppColors.secondaryText, fontSize: 9),
              ),
            ],
          ),
        ),
    ],
  );
}

class TopGainersList extends StatelessWidget {
  const TopGainersList({
    super.key,
    required this.coins,
    required this.error,
    required this.onCoinTap,
  });

  final List<Coin> coins;
  final String? error;
  final ValueChanged<Coin> onCoinTap;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              'Top Gainers (24h)',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (coins.isNotEmpty)
            Text(
              'Top 3',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
      const SizedBox(height: 8),
      if (error != null)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(error!, style: TextStyle(color: AppColors.secondaryText)),
        )
      else if (coins.isEmpty)
        Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Text(
            'No positive 24h changes found.',
            style: TextStyle(color: AppColors.secondaryText),
          ),
        )
      else
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              for (var index = 0; index < coins.length; index++)
                _GainerRow(
                  rank: index + 1,
                  coin: coins[index],
                  onTap: () => onCoinTap(coins[index]),
                ),
            ],
          ),
        ),
    ],
  );
}

class _GainerRow extends StatelessWidget {
  const _GainerRow({
    required this.rank,
    required this.coin,
    required this.onTap,
  });

  final int rank;
  final Coin coin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final change = coin.change24h;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            border: rank == 1
                ? null
                : Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 17,
                child: Text(
                  '$rank',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 11,
                  ),
                ),
              ),
              _CoinAvatar(coin: coin),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      coin.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      coin.symbol,
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      NumberFormatters.price(coin.priceUsd),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      change == null ? '—' : '+${change.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: AppColors.positive,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 48,
                height: 24,
                child: CustomPaint(painter: _SparklinePainter(coin.sparkline)),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoinAvatar extends StatelessWidget {
  const _CoinAvatar({required this.coin});

  final Coin coin;

  @override
  Widget build(BuildContext context) => ClipOval(
    child: SizedBox(
      width: 25,
      height: 25,
      child: coin.imageUrl.isEmpty
          ? ColoredBox(
              color: AppColors.elevated,
              child: Center(
                child: Text(
                  coin.symbol.isEmpty ? '?' : coin.symbol[0],
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
          : Image.network(
              coin.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, error, stackTrace) => ColoredBox(
                color: AppColors.elevated,
                child: Icon(
                  Icons.currency_bitcoin_rounded,
                  size: 17,
                  color: AppColors.accent,
                ),
              ),
            ),
    ),
  );
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minimum = values.reduce(math.min);
    final maximum = values.reduce(math.max);
    final span = maximum - minimum;
    final path = Path();
    for (var index = 0; index < values.length; index++) {
      final x = size.width * index / (values.length - 1);
      final y = span == 0
          ? size.height / 2
          : size.height - (values[index] - minimum) / span * size.height;
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.positive
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) =>
      !identical(oldDelegate.values, values);
}

class NumberFormatters {
  static String price(double price) {
    final decimalDigits = price >= 1
        ? 2
        : price >= .01
        ? 4
        : price > 0
        ? ((-math.log(price) / math.ln10).floor() + 4).clamp(6, 12)
        : 2;
    return NumberFormat.currency(
      symbol: '\$',
      decimalDigits: decimalDigits,
    ).format(price);
  }
}
