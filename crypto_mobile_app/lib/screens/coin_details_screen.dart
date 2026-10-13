import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../models/coin.dart';
import '../models/coin_details.dart';
import '../viewmodels/coin_details_view_model.dart';
import '../viewmodels/theme_view_model.dart';
import '../viewmodels/watchlist_view_model.dart';
import '../widgets/coin_widgets.dart';
import '../widgets/state_widgets.dart';

class CoinDetailsScreen extends StatelessWidget {
  const CoinDetailsScreen({super.key, required this.coin});

  final Coin coin;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CoinDetailsViewModel(context.read(), coin)..load(),
      child: _CoinDetailsContent(coin: coin),
    );
  }
}

class _CoinDetailsContent extends StatefulWidget {
  const _CoinDetailsContent({required this.coin});

  final Coin coin;

  @override
  State<_CoinDetailsContent> createState() => _CoinDetailsContentState();
}

class _CoinDetailsContentState extends State<_CoinDetailsContent> {
  static const _refreshInterval = Duration(seconds: 60);
  late final Timer _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      if (!mounted ||
          WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed ||
          ModalRoute.of(context)?.isCurrent != true) {
        return;
      }
      final viewModel = context.read<CoinDetailsViewModel>();
      if (viewModel.isLoadingDetails || viewModel.isLoadingChart) return;
      viewModel.load();
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeViewModel>();
    final viewModel = context.watch<CoinDetailsViewModel>();
    final watchlist = context.watch<WatchlistViewModel>();
    final details = viewModel.details;
    final coin = widget.coin;
    final marketRank = details?.marketCapRank ?? coin.rank;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          '${coin.name} overview',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        actions: [
          IconButton(
            tooltip: watchlist.contains(coin.id)
                ? 'Remove from watchlist'
                : 'Add to watchlist',
            onPressed: () => watchlist.toggleCoin(coin),
            icon: Icon(
              watchlist.contains(coin.id)
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: watchlist.contains(coin.id)
                  ? AppColors.accent
                  : AppColors.secondaryText,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: viewModel.isLoadingDetails && details == null
            ? const LoadingState(label: 'Loading coin details')
            : viewModel.detailsError != null && details == null
            ? ErrorState(
                message: viewModel.detailsError!,
                onRetry: viewModel.loadDetails,
              )
            : Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
                    children: [
                      _CoinHeroCard(
                        coin: coin,
                        details: details,
                        marketRank: marketRank,
                      ),
                      const SizedBox(height: 18),
                      PriceChartCard(
                        points: viewModel.chartPoints,
                        range: viewModel.range,
                        isLoading: viewModel.isLoadingChart,
                        errorMessage: viewModel.chartError,
                        onRangeSelected: viewModel.loadChart,
                        onRetry: () => viewModel.loadChart(viewModel.range),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: .14),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(
                              Icons.insights_rounded,
                              color: AppColors.accent,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Market statistics',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Live market data  ·  USD',
                                  style: TextStyle(
                                    color: AppColors.secondaryText,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 11),
                      if (details != null)
                        CoinInfoGrid(details: details)
                      else
                        const LoadingState(label: 'Loading market information'),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _CoinHeroCard extends StatelessWidget {
  const _CoinHeroCard({
    required this.coin,
    required this.details,
    required this.marketRank,
  });

  final Coin coin;
  final CoinDetails? details;
  final int? marketRank;

  @override
  Widget build(BuildContext context) {
    final imageUrl = details?.imageUrl ?? coin.imageUrl;
    final symbol = details?.symbol ?? coin.symbol;
    final name = details?.name ?? coin.name;
    final price = details?.priceUsd ?? coin.priceUsd;
    final change = details?.change24h ?? coin.change24h;
    final changeColor = change == null
        ? AppColors.secondaryText
        : change >= 0
        ? AppColors.positive
        : AppColors.negative;
    final priceFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: price.abs() < 1 ? 4 : 2,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.isLightMode
              ? [
                  const Color(0xFFE9E4FF),
                  AppColors.card,
                  const Color(0xFFF8F7FF),
                ]
              : [
                  const Color(0xFF222F52),
                  AppColors.card,
                  const Color(0xFF171E32),
                ],
        ),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: .08),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CoinIdentity(
                  imageUrl: imageUrl,
                  symbol: symbol,
                  name: name,
                ),
              ),
              if (marketRank != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.canvas.withValues(alpha: .6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'RANK #$marketRank',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .4,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'CURRENT PRICE',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            priceFormat.format(price),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -.8,
            ),
          ),
          const SizedBox(height: 10),
          if (change != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: changeColor.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: changeColor.withValues(alpha: .24)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    change >= 0
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    size: 16,
                    color: changeColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}% today',
                    style: TextStyle(
                      color: changeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          if (details?.high24hUsd != null || details?.low24hUsd != null) ...[
            const SizedBox(height: 18),
            _DailyRange(
              low: details?.low24hUsd,
              high: details?.high24hUsd,
              current: price,
            ),
          ],
        ],
      ),
    );
  }
}

class _DailyRange extends StatelessWidget {
  const _DailyRange({
    required this.low,
    required this.high,
    required this.current,
  });

  final double? low;
  final double? high;
  final double current;

  @override
  Widget build(BuildContext context) {
    final range = (high ?? 0) - (low ?? 0);
    final progress = low == null || high == null || range <= 0
        ? .5
        : ((current - low!) / range).clamp(0.0, 1.0);
    final money = NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 2);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '24H LOW',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .6,
                ),
              ),
            ),
            Text(
              '24H RANGE',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: .6,
              ),
            ),
            Expanded(
              child: Text(
                '24H HIGH',
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .6,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: AppColors.canvas,
            valueColor: AlwaysStoppedAnimation(AppColors.accent),
          ),
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Expanded(
              child: Text(
                low == null ? '—' : money.format(low),
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: Text(
                high == null ? '—' : money.format(high),
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
