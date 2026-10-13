import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../viewmodels/market_view_model.dart';
import '../viewmodels/statistics_view_model.dart';
import '../viewmodels/theme_view_model.dart';
import '../viewmodels/watchlist_view_model.dart';
import 'market_screen.dart';
import 'statistics_screen.dart';
import 'watchlist_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  static const _refreshInterval = Duration(seconds: 60);

  int _selectedIndex = 0;
  late final Timer _refreshTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      if (!mounted ||
          WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed ||
          ModalRoute.of(context)?.isCurrent != true) {
        return;
      }
      _refreshSelectedScreen();
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
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const MarketScreen(),
          const StatisticsScreen(),
          WatchlistScreen(onExploreMarket: () => _selectTab(0)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectTab,
        backgroundColor: AppColors.card,
        indicatorColor: AppColors.accent.withValues(alpha: 0.22),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.show_chart_rounded),
            selectedIcon: Icon(
              Icons.show_chart_rounded,
              color: AppColors.accent,
            ),
            label: 'Market',
          ),
          NavigationDestination(
            icon: Icon(Icons.query_stats_rounded),
            selectedIcon: Icon(
              Icons.query_stats_rounded,
              color: AppColors.accent,
            ),
            label: 'Statistics',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded, color: AppColors.accent),
            label: 'Watchlist',
          ),
        ],
      ),
    );
  }

  void _selectTab(int index) => setState(() => _selectedIndex = index);

  Future<void> _refreshSelectedScreen() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    try {
      switch (_selectedIndex) {
        case 0:
          await Future.wait([
            context.read<MarketViewModel>().loadCoins(),
            context.read<StatisticsViewModel>().loadStats(),
          ]);
          break;
        case 1:
          await context.read<StatisticsViewModel>().loadStats();
          break;
        case 2:
          await context.read<WatchlistViewModel>().refresh();
          break;
      }
    } finally {
      _isRefreshing = false;
    }
  }
}
