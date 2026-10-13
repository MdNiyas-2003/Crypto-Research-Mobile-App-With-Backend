import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'core/app_constants.dart';
import 'repositories/coin_repository.dart';
import 'repositories/watchlist_repository.dart';
import 'screens/main_navigation_screen.dart';
import 'services/api_service.dart';
import 'viewmodels/market_view_model.dart';
import 'viewmodels/statistics_view_model.dart';
import 'viewmodels/theme_view_model.dart';
import 'viewmodels/watchlist_view_model.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService(ApiClient.create())),
        Provider<CoinRepository>(
          create: (context) => CoinRepository(context.read<ApiService>()),
        ),
        ChangeNotifierProvider<MarketViewModel>(
          create: (context) => MarketViewModel(context.read<CoinRepository>()),
        ),
        ChangeNotifierProvider<StatisticsViewModel>(
          create: (context) =>
              StatisticsViewModel(context.read<CoinRepository>()),
        ),
        ChangeNotifierProvider<ThemeViewModel>(create: (_) => ThemeViewModel()),
        Provider<WatchlistRepository>(create: (_) => WatchlistRepository()),
        ChangeNotifierProvider<WatchlistViewModel>(
          create: (context) => WatchlistViewModel(
            context.read<CoinRepository>(),
            context.read<WatchlistRepository>(),
          )..loadWatchlist(),
        ),
      ],
      child: const MiniCryptoApp(),
    ),
  );
}

class MiniCryptoApp extends StatelessWidget {
  const MiniCryptoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeViewModel>();
    final brightness = themeMode.isLightMode
        ? Brightness.light
        : Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: AppColors.canvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        brightness: brightness,
        surface: AppColors.card,
      ),
    );

    return MaterialApp(
      title: 'Mini Crypto',
      debugShowCheckedModeBanner: false,
      themeAnimationDuration: Duration.zero,
      theme: base.copyWith(
        textTheme: GoogleFonts.manropeTextTheme(base.textTheme).copyWith(
          headlineSmall: GoogleFonts.manrope(
            color: AppColors.primaryText,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
          titleMedium: GoogleFonts.manrope(
            color: AppColors.primaryText,
            fontWeight: FontWeight.w700,
          ),
          bodyMedium: GoogleFonts.manrope(color: AppColors.secondaryText),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.canvas,
          foregroundColor: AppColors.primaryText,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        dividerColor: AppColors.border,
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: AppColors.secondaryText),
          filled: true,
          fillColor: AppColors.card,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.accent),
          ),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}
