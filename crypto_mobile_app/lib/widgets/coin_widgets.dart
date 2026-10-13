import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/app_constants.dart';
import '../models/chart_point.dart';
import '../models/coin.dart';
import '../models/coin_details.dart';
import '../viewmodels/coin_details_view_model.dart';

class CoinIdentity extends StatelessWidget {
  const CoinIdentity({
    super.key,
    required this.imageUrl,
    required this.symbol,
    required this.name,
  });

  final String imageUrl;
  final String symbol;
  final String name;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      ClipOval(
        child: SizedBox(
          width: 48,
          height: 48,
          child: imageUrl.isEmpty
              ? _fallback()
              : Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _fallback(),
                ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(symbol, style: TextStyle(color: AppColors.secondaryText)),
          ],
        ),
      ),
    ],
  );

  Widget _fallback() => ColoredBox(
    color: AppColors.elevated,
    child: Center(
      child: Text(
        symbol.isEmpty ? '?' : symbol[0],
        style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w800),
      ),
    ),
  );
}

class CoinPriceHeader extends StatelessWidget {
  const CoinPriceHeader({super.key, required this.coin, required this.details});

  final Coin coin;
  final CoinDetails? details;

  @override
  Widget build(BuildContext context) {
    final price = details?.priceUsd ?? coin.priceUsd;
    final change = details?.change24h ?? coin.change24h;
    final color = change == null
        ? AppColors.secondaryText
        : change >= 0
        ? AppColors.positive
        : AppColors.negative;
    final priceFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: price.abs() < 1 ? 4 : 2,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          priceFormat.format(price),
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 32,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        if (change != null)
          Row(
            children: [
              Icon(
                change >= 0
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: color,
                size: 19,
              ),
              const SizedBox(width: 5),
              Text(
                '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}% today',
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              ),
            ],
          ),
      ],
    );
  }
}

class CoinInfoGrid extends StatelessWidget {
  const CoinInfoGrid({super.key, required this.details});

  final CoinDetails details;

  @override
  Widget build(BuildContext context) {
    final number = NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 2);
    final supplyFormat = NumberFormat.compact();
    final values = [
      (
        'Market cap',
        _money(number, details.marketCapUsd),
        Icons.account_balance_rounded,
        AppColors.accent,
      ),
      (
        '24h volume',
        _money(number, details.volume24hUsd),
        Icons.swap_vert_rounded,
        const Color(0xFF53B7FF),
      ),
      (
        '24h high',
        _money(number, details.high24hUsd),
        Icons.north_east_rounded,
        AppColors.positive,
      ),
      (
        '24h low',
        _money(number, details.low24hUsd),
        Icons.south_east_rounded,
        AppColors.negative,
      ),
      (
        'Market rank',
        details.marketCapRank == null ? '—' : '#${details.marketCapRank}',
        Icons.military_tech_rounded,
        const Color(0xFFFFC66D),
      ),
      (
        'Circulating supply',
        details.circulatingSupply == null
            ? '—'
            : '${supplyFormat.format(details.circulatingSupply)} ${details.symbol}',
        Icons.toll_rounded,
        const Color(0xFF55D6C2),
      ),
      (
        'Total supply',
        _supply(supplyFormat, details.totalSupply, details.symbol),
        Icons.inventory_2_rounded,
        const Color(0xFF53B7FF),
      ),
      (
        'Maximum supply',
        _supply(supplyFormat, details.maxSupply, details.symbol),
        Icons.lock_rounded,
        const Color(0xFFFFC66D),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 560 ? 3 : 2;
        final cardWidth = (constraints.maxWidth - (columns - 1) * 11) / columns;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: values.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 11,
            mainAxisSpacing: 11,
            childAspectRatio: cardWidth / 122,
          ),
          itemBuilder: (context, index) => CoinInfoCard(
            label: values[index].$1,
            value: values[index].$2,
            icon: values[index].$3,
            accent: values[index].$4,
          ),
        );
      },
    );
  }

  String _money(NumberFormat format, double? value) =>
      value == null ? '—' : format.format(value);

  String _supply(NumberFormat format, double? value, String symbol) =>
      value == null ? '—' : '${format.format(value)} $symbol';
}

class CoinInfoCard extends StatelessWidget {
  const CoinInfoCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(13, 13, 13, 12),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.alphaBlend(accent.withValues(alpha: .09), AppColors.card),
          AppColors.card,
        ],
      ),
      border: Border.all(color: accent.withValues(alpha: .2)),
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: accent.withValues(alpha: .035),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accent, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .45,
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -.25,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 2,
          width: 34,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: .8),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    ),
  );
}

class PriceChartCard extends StatelessWidget {
  const PriceChartCard({
    super.key,
    required this.points,
    required this.range,
    required this.isLoading,
    required this.errorMessage,
    required this.onRangeSelected,
    required this.onRetry,
  });

  final List<ChartPoint> points;
  final ChartRange range;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<ChartRange> onRangeSelected;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 16, 12, 14),
    decoration: BoxDecoration(
      color: AppColors.card,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Price history',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (final option in ChartRange.values)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: _RangeButton(
                  range: option,
                  selected: range == option,
                  onPressed: () => onRangeSelected(option),
                ),
              ),
          ],
        ),
        const SizedBox(height: 22),
        SizedBox(
          height: 220,
          child: isLoading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : errorMessage != null
              ? _ChartMessage(message: errorMessage!, onRetry: onRetry)
              : points.isEmpty
              ? const Center(child: Text('No chart data available'))
              : _LinePriceChart(points: points, range: range),
        ),
      ],
    ),
  );
}

class _RangeButton extends StatelessWidget {
  const _RangeButton({
    required this.range,
    required this.selected,
    required this.onPressed,
  });

  final ChartRange range;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      minimumSize: const Size(42, 38),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      backgroundColor: selected
          ? AppColors.accent.withValues(alpha: 0.2)
          : Colors.transparent,
      foregroundColor: selected ? AppColors.accent : AppColors.secondaryText,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    child: Text(
      range.label,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
    ),
  );
}

class _LinePriceChart extends StatelessWidget {
  const _LinePriceChart({required this.points, required this.range});

  final List<ChartPoint> points;
  final ChartRange range;

  @override
  Widget build(BuildContext context) {
    final spots = points
        .map(
          (point) => FlSpot(
            point.timestamp.millisecondsSinceEpoch.toDouble(),
            point.price,
          ),
        )
        .toList();
    final minX = spots.first.x;
    final maxX = spots.last.x > minX ? spots.last.x : minX + 1;
    final prices = points.map((point) => point.price);
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);
    final spread = maxPrice - minPrice;
    final padding = spread == 0 ? maxPrice.abs() * 0.02 : spread * 0.12;
    final safePadding = padding == 0 ? 1.0 : padding;
    final (titleInterval, dateFormat) = switch (range) {
      ChartRange.day => (
        const Duration(hours: 6).inMilliseconds.toDouble(),
        DateFormat('HH:mm'),
      ),
      ChartRange.week => (
        const Duration(days: 2).inMilliseconds.toDouble(),
        DateFormat('MMM d'),
      ),
      ChartRange.month => (
        const Duration(days: 7).inMilliseconds.toDouble(),
        DateFormat('MMM d'),
      ),
      ChartRange.year => (
        const Duration(days: 90).inMilliseconds.toDouble(),
        DateFormat('MMM yy'),
      ),
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartWidth = math.max(constraints.maxWidth, switch (range) {
          ChartRange.day => 560.0,
          ChartRange.week => 760.0,
          ChartRange.month => 1020.0,
          ChartRange.year => 1320.0,
        }).toDouble();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: chartWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LineChart(
                LineChartData(
                  minX: minX,
                  maxX: maxX,
                  minY: minPrice - safePadding,
                  maxY: maxPrice + safePadding,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) =>
                        FlLine(color: AppColors.border, strokeWidth: 0.7),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: titleInterval,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) => Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            dateFormat.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                value.toInt(),
                              ),
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) => spots.map((spot) {
                        final format = NumberFormat.currency(
                          symbol: '\$',
                          decimalDigits: spot.y.abs() < 1 ? 4 : 2,
                        );
                        return LineTooltipItem(
                          format.format(spot.y),
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.accent,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.accent.withValues(alpha: 0.24),
                            AppColors.accent.withValues(alpha: 0.01),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                duration: const Duration(milliseconds: 250),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChartMessage extends StatelessWidget {
  const _ChartMessage({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.secondaryText),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Retry'),
        ),
      ],
    ),
  );
}
