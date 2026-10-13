import 'package:crypto_mobile_app/widgets/state_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../models/coin.dart';
import '../viewmodels/statistics_view_model.dart';
import '../viewmodels/theme_view_model.dart';
import '../widgets/statistics_widgets.dart';
import 'coin_details_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<StatisticsViewModel>().loadStats();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeViewModel>();
    final viewModel = context.watch<StatisticsViewModel>();
    final stats = viewModel.stats;
    final moneyFormat = NumberFormat.compactCurrency(
      symbol: '\$',
      decimalDigits: 2,
    );
    final marketCap = stats?.marketCapUsd == null
        ? '—'
        : moneyFormat.format(stats!.marketCapUsd);
    final marketCapChange = stats?.marketCapChange24h == null
        ? '—'
        : '${stats!.marketCapChange24h! >= 0 ? '+' : ''}${stats.marketCapChange24h!.toStringAsFixed(2)}%';
    final numberFormat = NumberFormat('#,##0');

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 18,
        title: Row(
          children: [
            Icon(Icons.currency_bitcoin_rounded, color: AppColors.accent),
            SizedBox(width: 7),
            Text(
              'Mini Crypto',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh statistics',
            onPressed: viewModel.isLoading ? null : viewModel.loadStats,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        top: false,
        child: viewModel.errorMessage != null && stats == null
            ? ErrorState(
                message: viewModel.errorMessage!,
                onRetry: viewModel.loadStats,
              )
            : RefreshIndicator(
                color: AppColors.accent,
                onRefresh: viewModel.loadStats,
                child: Scrollbar(
                  controller: _scrollController,
                  interactive: true,
                  child: ListView(
                    controller: _scrollController,
                    primary: false,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 5, 16, 20),
                    children: [
                      Text(
                        'Market Statistics',
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Global crypto market overview and key metrics',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 13),
                      MarketCapHero(
                        stats: stats,
                        marketCap: marketCap,
                        change: marketCapChange,
                      ),
                      const SizedBox(height: 10),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final gap = 9.0;
                          final width = (constraints.maxWidth - gap) / 2;
                          return Wrap(
                            spacing: gap,
                            runSpacing: 9,
                            children: [
                              SizedBox(
                                width: width,
                                child: MarketMetricTile(
                                  label: '24h Trading Volume',
                                  value: stats?.volumeUsd == null
                                      ? '—'
                                      : moneyFormat.format(stats!.volumeUsd),
                                  icon: Icons.bar_chart_rounded,
                                  iconColor: AppColors.positive,
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: MarketMetricTile(
                                  label: 'BTC Dominance',
                                  value: stats?.bitcoinDominance == null
                                      ? '—'
                                      : '${stats!.bitcoinDominance!.toStringAsFixed(1)}%',
                                  icon: Icons.currency_bitcoin_rounded,
                                  iconColor: const Color(0xFFFF9D13),
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: MarketMetricTile(
                                  label: 'Active Cryptocurrencies',
                                  value: stats?.activeCryptocurrencies == null
                                      ? '—'
                                      : numberFormat.format(
                                          stats!.activeCryptocurrencies,
                                        ),
                                  icon: Icons.layers_rounded,
                                  iconColor: AppColors.accent,
                                ),
                              ),
                              SizedBox(
                                width: width,
                                child: MarketMetricTile(
                                  label: 'Active Markets',
                                  value: stats?.activeMarkets == null
                                      ? '—'
                                      : numberFormat.format(
                                          stats!.activeMarkets,
                                        ),
                                  icon: Icons.account_balance_rounded,
                                  iconColor: const Color(0xFF3297FF),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      MarketSentimentCard(sentiment: viewModel.sentiment),
                      const SizedBox(height: 11),
                      Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: 9),
                      TopGainersList(
                        coins: viewModel.topGainers,
                        error: viewModel.gainersError,
                        onCoinTap: _openCoinDetails,
                      ),
                      if (viewModel.sentimentError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          viewModel.sentimentError!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  void _openCoinDetails(Coin coin) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => CoinDetailsScreen(coin: coin)),
    );
  }
}
