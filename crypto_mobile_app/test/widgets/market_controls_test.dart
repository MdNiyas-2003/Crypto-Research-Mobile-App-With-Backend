import 'package:crypto_mobile_app/viewmodels/market_view_model.dart';
import 'package:crypto_mobile_app/widgets/market_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'filter chips can be swiped horizontally while panel buttons stay visible',
    (tester) async {
      tester.view.physicalSize = const Size(280, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: EdgeInsets.all(12),
              child: MarketFilterSortToolbar(
                selectedFilter: MarketFilter.all,
                filterPanelOpen: false,
                sortPanelOpen: false,
                onFilterSelected: _ignoreFilter,
                onFilterPanelToggle: _ignore,
                onSortPanelToggle: _ignore,
              ),
            ),
          ),
        ),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.byTooltip('Show filter options'), findsOneWidget);
      expect(find.byTooltip('Show sort options'), findsOneWidget);

      final scrollableFinder = find.descendant(
        of: find.byKey(const ValueKey('market-filter-scroll')),
        matching: find.byType(Scrollable),
      );
      final scrollable = tester.state<ScrollableState>(scrollableFinder);
      expect(scrollable.position.maxScrollExtent, greaterThan(0));

      await tester.drag(
        find.byKey(const ValueKey('market-filter-scroll')),
        const Offset(-100, 0),
      );
      await tester.pumpAndSettle();

      expect(scrollable.position.pixels, greaterThan(0));
      await tester.drag(
        find.byKey(const ValueKey('market-filter-scroll')),
        const Offset(-300, 0),
      );
      await tester.pumpAndSettle();
      expect(find.text('BNB'), findsOneWidget);
      expect(find.byTooltip('Show filter options'), findsOneWidget);
      expect(find.byTooltip('Show sort options'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('filter and sort panels can remain open independently', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _PanelHarness()));

    await tester.tap(find.byTooltip('Show filter options'));
    await tester.pumpAndSettle();
    expect(find.text('Filter options'), findsOneWidget);
    expect(find.text('Sort options'), findsNothing);

    await tester.tap(find.byTooltip('Show sort options'));
    await tester.pumpAndSettle();
    expect(find.text('Filter options'), findsOneWidget);
    expect(find.text('Sort options'), findsOneWidget);

    await tester.tap(find.byTooltip('Collapse Filter options'));
    await tester.pumpAndSettle();
    expect(find.text('Filter options'), findsNothing);
    expect(find.text('Sort options'), findsOneWidget);

    await tester.tap(find.byTooltip('Show filter options'));
    await tester.pumpAndSettle();
    expect(find.text('Filter options'), findsOneWidget);
    expect(find.text('Sort options'), findsOneWidget);
  });

  testWidgets('period, sort field, and direction selections are actionable', (
    tester,
  ) async {
    MarketPeriod? selectedPeriod;
    MarketSort? selectedSort;
    bool? selectedDirection;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              FilterOptionsPanel(
                period: MarketPeriod.day,
                onPeriodSelected: (value) => selectedPeriod = value,
                onCollapse: _ignore,
              ),
              SortOptionsPanel(
                sort: MarketSort.price,
                ascending: false,
                onSortSelected: (value) => selectedSort = value,
                onDirectionSelected: (value) => selectedDirection = value,
                onCollapse: _ignore,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('7D'));
    await tester.tap(find.text('Volume'));
    await tester.tap(find.text('Ascending'));

    expect(selectedPeriod, MarketPeriod.week);
    expect(selectedSort, MarketSort.volume);
    expect(selectedDirection, isTrue);
    expect(tester.takeException(), isNull);
  });
}

void _ignore() {}

void _ignoreFilter(MarketFilter filter) {}

class _PanelHarness extends StatefulWidget {
  const _PanelHarness();

  @override
  State<_PanelHarness> createState() => _PanelHarnessState();
}

class _PanelHarnessState extends State<_PanelHarness> {
  bool _filterOpen = false;
  bool _sortOpen = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: ListView(
      padding: const EdgeInsets.all(12),
      children: [
        MarketFilterSortToolbar(
          selectedFilter: MarketFilter.all,
          filterPanelOpen: _filterOpen,
          sortPanelOpen: _sortOpen,
          onFilterSelected: _ignoreFilter,
          onFilterPanelToggle: () => setState(() {
            _filterOpen = !_filterOpen;
          }),
          onSortPanelToggle: () => setState(() {
            _sortOpen = !_sortOpen;
          }),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 1),
          child: Column(
            children: [
              if (_filterOpen)
                FilterOptionsPanel(
                  period: MarketPeriod.day,
                  onPeriodSelected: _ignorePeriod,
                  onCollapse: () => setState(() {
                    _filterOpen = false;
                  }),
                ),
              if (_sortOpen)
                SortOptionsPanel(
                  sort: MarketSort.marketCap,
                  ascending: false,
                  onSortSelected: _ignoreSort,
                  onDirectionSelected: _ignoreDirection,
                  onCollapse: () => setState(() {
                    _sortOpen = false;
                  }),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

void _ignorePeriod(MarketPeriod period) {}

void _ignoreSort(MarketSort sort) {}

void _ignoreDirection(bool ascending) {}
