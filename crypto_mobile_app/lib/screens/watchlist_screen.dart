import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../viewmodels/watchlist_view_model.dart';
import '../viewmodels/theme_view_model.dart';
import '../widgets/coin_row.dart';
import '../widgets/state_widgets.dart';
import 'coin_details_screen.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key, required this.onExploreMarket});

  final VoidCallback onExploreMarket;

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeViewModel>();
    final viewModel = context.watch<WatchlistViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Watchlist',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh watchlist',
            onPressed: viewModel.isLoading ? null : viewModel.refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                '${viewModel.coinIds.length} saved ${viewModel.coinIds.length == 1 ? 'coin' : 'coins'}',
                style:  TextStyle(color: AppColors.secondaryText),
              ),
            ),
            Expanded(child: _watchlistContent(context, viewModel)),
          ],
        ),
      ),
    );
  }

  Widget _watchlistContent(BuildContext context, WatchlistViewModel viewModel) {
    if (viewModel.isLoading && !viewModel.hasLoaded) {
      return const LoadingState(label: 'Loading your watchlist');
    }
    if (viewModel.errorMessage != null && !viewModel.hasLoaded) {
      return ErrorState(
        message: viewModel.errorMessage!,
        onRetry: viewModel.loadWatchlist,
      );
    }
    if (viewModel.coinIds.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                ),
                child:  Icon(
                  Icons.favorite_border_rounded,
                  color: AppColors.accent,
                  size: 32,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Your watchlist is empty',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
               Text(
                'Save coins you want to keep an eye on from the Market screen.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.secondaryText),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onExploreMarket,
                icon: const Icon(Icons.explore_outlined),
                label: const Text('Explore market'),
              ),
            ],
          ),
        ),
      );
    }
    if (viewModel.errorMessage != null && viewModel.coins.isEmpty) {
      return ErrorState(
        message: viewModel.errorMessage!,
        onRetry: viewModel.refresh,
      );
    }

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: viewModel.refresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        itemCount: viewModel.coins.length,
        itemBuilder: (context, index) {
          final coin = viewModel.coins[index];
          return Column(
            children: [
              CoinRow(
                coin: coin,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CoinDetailsScreen(coin: coin),
                  ),
                ),
                trailing: IconButton(
                  tooltip: 'Remove from watchlist',
                  onPressed: () => viewModel.toggleCoin(coin),
                  icon:  Icon(
                    Icons.favorite_rounded,
                    color: AppColors.accent,
                    size: 20,
                  ),
                ),
              ),
              if (index != viewModel.coins.length - 1)
                const Divider(height: 1, indent: 54),
            ],
          );
        },
      ),
    );
  }
}
