import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/app_constants.dart';
import '../models/global_market_stats.dart';
import '../viewmodels/market_view_model.dart';

class MarketOverviewCard extends StatelessWidget {
  const MarketOverviewCard({super.key, required this.stats});

  final GlobalMarketStats? stats;

  static final _moneyFormat = NumberFormat.compactCurrency(
    symbol: '\$',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    final change = stats?.marketCapChange24h;
    final hasMarketCap = stats?.marketCapUsd != null;
    final changeColor = change == null
        ? AppColors.secondaryText
        : change >= 0
        ? AppColors.positive
        : AppColors.negative;
    final isLightMode = AppColors.isLightMode;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLightMode
                ? [const Color(0xFFE8E5FF), const Color(0xFFFFFFFF)]
                : [const Color(0xFF202B49), const Color(0xFF151D30)],
          ),
          border: Border.all(
            color: isLightMode ? const Color(0xFFD8D0FF) : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: isLightMode ? .08 : .1),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: .13),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.public_rounded,
                    color: AppColors.accent,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GLOBAL MARKET CAP',
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .65,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasMarketCap
                            ? 'Worldwide crypto value'
                            : 'Live data unavailable',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                if (change != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: changeColor.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: changeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 13),
            Text(
              hasMarketCap ? _moneyFormat.format(stats!.marketCapUsd) : '—',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 30,
                height: 1.1,
                fontWeight: FontWeight.w800,
                letterSpacing: -.7,
              ),
            ),
            const SizedBox(height: 15),
            Container(height: 1, color: AppColors.border.withValues(alpha: .8)),
            const SizedBox(height: 12),
            Row(
              children: [
                _OverviewMetric(
                  label: '24H VOLUME',
                  value: stats?.volumeUsd == null
                      ? '—'
                      : _moneyFormat.format(stats!.volumeUsd),
                  icon: Icons.swap_vert_rounded,
                ),
                Container(
                  width: 1,
                  height: 32,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: AppColors.border,
                ),
                _OverviewMetric(
                  label: 'BTC DOMINANCE',
                  value: stats?.bitcoinDominance == null
                      ? '—'
                      : '${stats!.bitcoinDominance!.toStringAsFixed(1)}%',
                  icon: Icons.currency_bitcoin_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.accent, size: 16),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .45,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class MarketFilterSortToolbar extends StatelessWidget {
  const MarketFilterSortToolbar({
    super.key,
    required this.selectedFilter,
    required this.filterPanelOpen,
    required this.sortPanelOpen,
    required this.onFilterSelected,
    required this.onFilterPanelToggle,
    required this.onSortPanelToggle,
  });

  final MarketFilter selectedFilter;
  final bool filterPanelOpen;
  final bool sortPanelOpen;
  final ValueChanged<MarketFilter> onFilterSelected;
  final VoidCallback onFilterPanelToggle;
  final VoidCallback onSortPanelToggle;

  @override
  Widget build(BuildContext context) {
    const options = [
      (MarketFilter.all, 'All'),
      (MarketFilter.bitcoin, 'Bitcoin'),
      (MarketFilter.ethereum, 'Ethereum'),
      (MarketFilter.BNB, 'BNB'),
    ];

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 42,
            child: ListView.separated(
              key: const ValueKey('market-filter-scroll'),
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              itemCount: options.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) => Center(
                child: _MarketFilterChip(
                  label: options[index].$2,
                  selected: selectedFilter == options[index].$1,
                  onTap: () => onFilterSelected(options[index].$1),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 5),
        _ToolbarIconButton(
          tooltip: filterPanelOpen
              ? 'Hide filter options'
              : 'Show filter options',
          icon: Icons.tune_rounded,
          selected: filterPanelOpen,
          onTap: onFilterPanelToggle,
        ),
        const SizedBox(width: 4),
        _ToolbarIconButton(
          tooltip: sortPanelOpen ? 'Hide sort options' : 'Show sort options',
          icon: Icons.swap_vert_rounded,
          selected: sortPanelOpen,
          onTap: onSortPanelToggle,
        ),
      ],
    );
  }
}

class _MarketFilterChip extends StatelessWidget {
  const _MarketFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(label),
    selected: selected,
    onSelected: (_) => onTap(),
    showCheckmark: false,
    backgroundColor: AppColors.card,
    selectedColor: AppColors.accent,
    side: BorderSide(color: selected ? AppColors.accent : AppColors.border),
    labelStyle: TextStyle(
      color: selected ? Colors.white : AppColors.secondaryText,
      fontWeight: FontWeight.w700,
      fontSize: 11,
    ),
    visualDensity: const VisualDensity(horizontal: -2, vertical: 0),
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
  );
}

class _ToolbarIconButton extends StatelessWidget {
  const _ToolbarIconButton({
    required this.tooltip,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: selected ? AppColors.accent.withValues(alpha: .2) : AppColors.card,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.border,
            ),
          ),
          child: Icon(
            icon,
            size: 19,
            color: selected ? AppColors.accent : AppColors.secondaryText,
          ),
        ),
      ),
    ),
  );
}

class FilterOptionsPanel extends StatelessWidget {
  const FilterOptionsPanel({
    super.key,
    required this.period,
    required this.onPeriodSelected,
    required this.onCollapse,
  });

  final MarketPeriod period;
  final ValueChanged<MarketPeriod> onPeriodSelected;
  final VoidCallback onCollapse;

  @override
  Widget build(BuildContext context) => _InlineOptionsPanel(
    title: 'Filter options',
    onCollapse: onCollapse,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Change period',
          style: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        _PeriodChips(selected: period, onSelected: onPeriodSelected),
      ],
    ),
  );
}

class SortOptionsPanel extends StatelessWidget {
  const SortOptionsPanel({
    super.key,
    required this.sort,
    required this.ascending,
    required this.onSortSelected,
    required this.onDirectionSelected,
    required this.onCollapse,
  });

  final MarketSort sort;
  final bool ascending;
  final ValueChanged<MarketSort> onSortSelected;
  final ValueChanged<bool> onDirectionSelected;
  final VoidCallback onCollapse;

  @override
  Widget build(BuildContext context) => _InlineOptionsPanel(
    title: 'Sort options',
    onCollapse: onCollapse,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (
                var index = 0;
                index < MarketSort.values.length;
                index++
              ) ...[
                if (index > 0) const SizedBox(width: 6),
                _OptionChip(
                  label: MarketSort.values[index].label,
                  selected: sort == MarketSort.values[index],
                  onTap: () => onSortSelected(MarketSort.values[index]),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _DirectionButton(
                label: 'Ascending',
                icon: Icons.arrow_upward_rounded,
                selected: ascending,
                onTap: () => onDirectionSelected(true),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _DirectionButton(
                label: 'Descending',
                icon: Icons.arrow_downward_rounded,
                selected: !ascending,
                onTap: () => onDirectionSelected(false),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _InlineOptionsPanel extends StatelessWidget {
  const _InlineOptionsPanel({
    required this.title,
    required this.child,
    required this.onCollapse,
  });

  final String title;
  final Widget child;
  final VoidCallback onCollapse;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 9, 10, 10),
    decoration: BoxDecoration(
      color: AppColors.card.withValues(alpha: .72),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Collapse $title',
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints.tightFor(width: 30, height: 30),
              padding: EdgeInsets.zero,
              onPressed: onCollapse,
              icon: Icon(
                Icons.keyboard_arrow_up_rounded,
                color: AppColors.secondaryText,
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        child,
      ],
    ),
  );
}

class _PeriodChips extends StatelessWidget {
  const _PeriodChips({required this.selected, required this.onSelected});

  final MarketPeriod selected;
  final ValueChanged<MarketPeriod> onSelected;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var index = 0; index < MarketPeriod.values.length; index++) ...[
        if (index > 0) const SizedBox(width: 7),
        Expanded(
          child: _OptionChip(
            label: MarketPeriod.values[index].label,
            selected: selected == MarketPeriod.values[index],
            onTap: () => onSelected(MarketPeriod.values[index]),
            expand: true,
          ),
        ),
      ],
    ],
  );
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.expand = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final chip = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        constraints: const BoxConstraints(minHeight: 32),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.canvas,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          maxLines: 1,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.secondaryText,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
    return SizedBox(width: expand ? double.infinity : null, child: chip);
  }
}

class _DirectionButton extends StatelessWidget {
  const _DirectionButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(9),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? AppColors.accent : AppColors.canvas,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: selected ? AppColors.accent : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: selected ? Colors.white : AppColors.secondaryText,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.secondaryText,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );
}

class MarketCoinShimmer extends StatefulWidget {
  const MarketCoinShimmer({super.key});

  @override
  State<MarketCoinShimmer> createState() => _MarketCoinShimmerState();
}

class _MarketCoinShimmerState extends State<MarketCoinShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _animationController,
    builder: (context, child) => ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        final offset = _animationController.value * 2 - 1;
        return LinearGradient(
          begin: Alignment(offset - 1, 0),
          end: Alignment(offset + 1, 0),
          colors: [AppColors.card, AppColors.elevated, AppColors.card],
          stops: const [0.15, 0.5, 0.85],
        ).createShader(bounds);
      },
      child: child,
    ),
    child: Column(
      children: [
        for (var index = 0; index < 7; index++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(
              children: [
                const _ShimmerBlock(width: 36, height: 36, circle: true),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBlock(width: 104, height: 11),
                      SizedBox(height: 7),
                      _ShimmerBlock(width: 128, height: 9),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _ShimmerBlock(width: 66, height: 11),
                    SizedBox(height: 7),
                    _ShimmerBlock(width: 42, height: 9),
                  ],
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

class _ShimmerBlock extends StatelessWidget {
  const _ShimmerBlock({
    required this.width,
    required this.height,
    this.circle = false,
  });

  final double width;
  final double height;
  final bool circle;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(circle ? height : 5),
    ),
  );
}
