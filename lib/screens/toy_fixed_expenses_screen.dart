import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/month_calculations_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/services/currency_formatter.dart';
import 'package:kakeibo/services/month_helpers.dart';
import 'package:kakeibo/services/swipe_nav.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';
import 'package:kakeibo/widgets/toy/toy_widgets.dart';

/// The gachapon-redesign Fixed Costs screen (README §4d).
class ToyFixedExpensesScreen extends ConsumerWidget {
  const ToyFixedExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthId = ref.watch(currentMonthIdProvider);
    final monthAsync = ref.watch(currentMonthProvider);
    final fixedTotal = ref.watch(fixedExpensesTotalProvider);
    final settings = ref.watch(settingsProvider);
    final currency = settings.whenOrNull(data: (s) => s.currency) ?? 'GBP';

    final (:year, :month) = MonthHelpers.parseMonthId(monthId);
    final displayMonth = MonthHelpers.formatMonthDisplay(year, month);

    String fmt(double amount) => CurrencyFormatter.format(amount, currency: currency);

    return monthAsync.when(
      loading: () => Scaffold(
        backgroundColor: ToyColors.bg,
        body: const Center(child: CircularProgressIndicator(color: ToyColors.brand)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: ToyColors.bg,
        body: Center(child: Text('Error: $e')),
      ),
      data: (currentMonth) {
        final items = currentMonth.fixedExpenses;

        return ToyScaffold(
          title: '固定費 Fixed costs',
          subtitle: '$displayMonth ・ ${items.length} ${items.length == 1 ? 'item' : 'items'}',
          headlineFigure: fmt(fixedTotal),
          tab: ToyTabDestination.fixed,
          trailing: const ToyMenuButton(),
          floatingActionButton: ToyFab(onTap: () => context.push('/add-fixed-expense')),
          body: GestureDetector(
            onHorizontalDragEnd: (details) => SwipeNav.handleTabSwipe(
              context,
              ToyTabDestination.fixed,
              details.primaryVelocity ?? 0,
            ),
            behavior: HitTestBehavior.translucent,
            child: items.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: ToyMetrics.screenPaddingH),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'No fixed costs yet.\nAdd one with ＋, or bring forward a\nprevious month\'s setup.',
                            style: ToyTextStyles.body(),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: ToyMetrics.cardGap),
                          ToyCapsuleButton(
                            label: '先月からコピー ・ Copy from another month',
                            onTap: () => context.push('/import-fixed-costs'),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    // A single scroll view for the whole body, not a
                    // pinned button above a separately-scrolled list --
                    // the previous nested-scroll layout left the list
                    // card's own bottom shadow with no trailing space to
                    // paint into, so it was clipped by the viewport edge
                    // at the end of the scroll extent (reported: "the
                    // display is clipped at the bottom, don't see the
                    // full shadow"). This layout gives the shadow real
                    // scroll-content space below the card, the same fix
                    // already applied to Spend's list/Categories-card gap.
                    padding: const EdgeInsets.fromLTRB(
                      ToyMetrics.screenPaddingH,
                      12,
                      ToyMetrics.screenPaddingH,
                      ToyMetrics.listBottomPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ToyCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              for (var i = 0; i < items.length; i++) ...[
                                if (i > 0) const DashedDivider(),
                                ToyRow(
                                  title: items[i].name.isNotEmpty ? items[i].name : items[i].category,
                                  meta: items[i].category,
                                  amountText: fmt(items[i].amount),
                                  onTap: () => context.push('/edit-fixed-expense/${items[i].id}'),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: ToyMetrics.cardGap),
                        ToyLinkRow(
                          label: 'Copy from another month',
                          onTap: () => context.push('/import-fixed-costs'),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
