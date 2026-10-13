import 'package:flutter/material.dart';

import '../core/app_constants.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.label = 'Loading market data'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          const SizedBox(height: 16),
          Text(label, style:  TextStyle(color: AppColors.secondaryText)),
        ],
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    this.compact = false,
  });

  final String message;
  final VoidCallback onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!compact) ...[
               Icon(
                Icons.wifi_off_rounded,
                size: 36,
                color: AppColors.secondaryText,
              ),
              const SizedBox(height: 14),
            ],
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: compact ? 6 : 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
              style: compact
                  ? FilledButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      visualDensity: VisualDensity.compact,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.compact = false,
  });

  final String title;
  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 8 : 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!compact) ...[
               Icon(
                Icons.search_off_rounded,
                size: 38,
                color: AppColors.secondaryText,
              ),
              const SizedBox(height: 14),
            ],
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: compact ? 3 : 6),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
