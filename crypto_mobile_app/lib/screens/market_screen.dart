import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../viewmodels/market_view_model.dart';
import '../viewmodels/statistics_view_model.dart';
import '../viewmodels/theme_view_model.dart';
import '../viewmodels/watchlist_view_model.dart';
import '../widgets/coin_row.dart';
import '../widgets/market_widgets.dart';
import '../widgets/state_widgets.dart';
import 'coin_details_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _filterPanelOpen = false;
  bool _sortPanelOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MarketViewModel>().loadCoins();
      context.read<StatisticsViewModel>().loadStats();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final market = context.watch<MarketViewModel>();
    final stats = context.watch<StatisticsViewModel>();
    final themeMode = context.watch<ThemeViewModel>();
    final watchlist = context.watch<WatchlistViewModel>();
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
             Icon(
              Icons.currency_bitcoin_rounded,
              color: AppColors.accent,
              size: 25,
            ),
            const SizedBox(width: 8),
            Text(
              'Mini Crypto',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: themeMode.isLightMode
                ? 'Switch to dark mode'
                : 'Switch to light mode',
            onPressed: context.read<ThemeViewModel>().toggleTheme,
            icon: Icon(
              themeMode.isLightMode
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
            ),
          ),
          IconButton(
            tooltip: 'Refresh market data',
            onPressed: market.isLoading ? null : market.loadCoins,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compactHeader =
                    keyboardVisible || constraints.maxHeight < 460;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 2, 20, 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedSize(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeInOut,
                            alignment: Alignment.topCenter,
                            child: compactHeader
                                ? const SizedBox.shrink()
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Market overview',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.headlineSmall,
                                      ),
                                      const SizedBox(height: 10),
                                      MarketOverviewCard(stats: stats.stats),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                          ),
                          TextField(
                            key: const ValueKey('market-search-field'),
                            focusNode: _searchFocusNode,
                            controller: _searchController,
                            onChanged: market.setSearchQuery,
                            onTapOutside: (_) => _searchFocusNode.unfocus(),
                            onSubmitted: (_) => _searchFocusNode.unfocus(),
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: 'Search by coin or ticker',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _searchController.text.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: 'Clear search',
                                      onPressed: () {
                                        _searchController.clear();
                                        market.setSearchQuery('');
                                      },
                                      icon: const Icon(Icons.close_rounded),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          MarketFilterSortToolbar(
                            selectedFilter: market.filter,
                            filterPanelOpen: _filterPanelOpen,
                            sortPanelOpen: _sortPanelOpen,
                            onFilterSelected: (filter) {
                              _searchFocusNode.unfocus();
                              market.setFilter(filter);
                            },
                            onFilterPanelToggle: () {
                              _searchFocusNode.unfocus();
                              setState(
                                () => _filterPanelOpen = !_filterPanelOpen,
                              );
                            },
                            onSortPanelToggle: () {
                              _searchFocusNode.unfocus();
                              setState(() => _sortPanelOpen = !_sortPanelOpen);
                            },
                          ),
                          if (!compactHeader) ...[
                            const SizedBox(height: 7),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeInOut,
                              alignment: Alignment.topCenter,
                              child: Column(
                                children: [
                                  if (_filterPanelOpen)
                                    FilterOptionsPanel(
                                      period: market.period,
                                      onPeriodSelected: market.setPeriod,
                                      onCollapse: () => setState(
                                        () => _filterPanelOpen = false,
                                      ),
                                    ),
                                  if (_filterPanelOpen && _sortPanelOpen)
                                    const SizedBox(height: 7),
                                  if (_sortPanelOpen)
                                    SortOptionsPanel(
                                      sort: market.sort,
                                      ascending: market.sortAscending,
                                      onSortSelected: market.setSort,
                                      onDirectionSelected:
                                          market.setSortAscending,
                                      onCollapse: () => setState(
                                        () => _sortPanelOpen = false,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Expanded(child: _buildMarketList(market, watchlist)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarketList(
    MarketViewModel market,
    WatchlistViewModel watchlist,
  ) {
    final coins = market.coins;
    return RefreshIndicator(
      onRefresh: market.loadCoins,
      color: AppColors.accent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (market.isLoading && !market.hasLoaded) {
            return ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: const [MarketCoinShimmer()],
            );
          }

          if (market.errorMessage != null && !market.hasLoaded) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: ErrorState(
                    message: market.errorMessage!,
                    onRetry: market.loadCoins,
                    compact: MediaQuery.viewInsetsOf(context).bottom > 0,
                  ),
                ),
              ],
            );
          }

          if (coins.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: EmptyState(
                    title: 'No coins found',
                    message: 'Try another search or market filter.',
                    compact: MediaQuery.viewInsetsOf(context).bottom > 0,
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            itemCount: coins.length + (market.errorMessage == null ? 0 : 1),
            itemBuilder: (context, index) {
              if (market.errorMessage != null && index == 0) {
                return Material(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                         Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.negative,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            market.errorMessage!,
                            style:  TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: market.isLoading ? null : market.loadCoins,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final coinIndex = index - (market.errorMessage == null ? 0 : 1);
              final coin = coins[coinIndex];
              return Column(
                children: [
                  CoinRow(
                    coin: coin,
                    changePeriod: market.period.apiValue,
                    onTap: () {
                      _searchFocusNode.unfocus();
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => CoinDetailsScreen(coin: coin),
                        ),
                      );
                    },
                    trailing: IconButton(
                      tooltip: watchlist.contains(coin.id)
                          ? 'Remove from watchlist'
                          : 'Add to watchlist',
                      onPressed: () {
                        _searchFocusNode.unfocus();
                        watchlist.toggleCoin(coin);
                      },
                      icon: Icon(
                        watchlist.contains(coin.id)
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: watchlist.contains(coin.id)
                            ? AppColors.accent
                            : AppColors.secondaryText,
                        size: 20,
                      ),
                    ),
                  ),
                  if (coinIndex != coins.length - 1)
                    const Divider(height: 1, indent: 54),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
