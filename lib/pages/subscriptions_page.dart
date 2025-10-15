import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subscription_model.dart';
import '../provider/simplified_subscription_provider.dart';
import '../widgets/shared/subscription_card_wrapper.dart';
import '../views/calendar_helpers.dart'; // Import the centralized helpers

class Subscriptions extends StatefulWidget {
  const Subscriptions({
    super.key,
    required this.onEdit,
    required this.isSubscriptionSnoozed,
    required this.onDelete,
    required this.isSelectionMode,
    required this.enterSelectionMode,
    required this.toggleSnooze,
    required this.snoozedIds,
  });

  final Future<void> Function(dynamic sub) onEdit;
  final bool Function(String subscriptionId) isSubscriptionSnoozed;
  final Future<bool> Function(dynamic sub) onDelete;
  final bool isSelectionMode;
  final void Function(String subscriptionId) enterSelectionMode;
  final void Function(String subscriptionId) toggleSnooze;
  final Set<String> snoozedIds;

  @override
  State<Subscriptions> createState() => _SubscriptionsState();
}

class _SubscriptionsState extends State<Subscriptions>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SimplifiedSubscriptionProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    if (provider.subscriptions.isEmpty) {
      return _buildEmptyState(colorScheme);
    }

    // Use the single source of truth for data logic
    final occurrences =
    CalendarHelpers.getUpcomingOccurrences(provider.subscriptions);
    final grouped = CalendarHelpers.groupOccurrences(occurrences);

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
      child: Column(
        children: [
          // The stats header now lives on this page
          _EnhancedStatsHeader(
            isSelectionMode: widget.isSelectionMode,
            snoozedIds: widget.snoozedIds,
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: widget.isSelectionMode ? 120 : 16,
              ),
              itemCount: grouped.length,
              itemBuilder: (context, index) {
                final entry = grouped.entries.elementAt(index);
                return _AnimatedSection(
                  title: entry.key,
                  occurrences: entry.value,
                  provider: provider,
                  parent: this,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.subscriptions_outlined,
                size: 90, color: colorScheme.primary.withOpacity(0.35)),
            const SizedBox(height: 28),
            Text(
              "No subscriptions yet",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(
              "Tap the '+' button to add your first one!",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation({
    required BuildContext context,
    required Subscription subscription,
    required SimplifiedSubscriptionProvider provider,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Confirm Deletion',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Delete "${subscription.name}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () {
              provider.deleteSubscription(subscription.id);
              Navigator.pop(context, true);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

// --- WIDGETS USED ON THIS PAGE ---

class _EnhancedStatsHeader extends StatelessWidget {
  final bool isSelectionMode;
  final Set<String> snoozedIds;

  const _EnhancedStatsHeader({
    required this.isSelectionMode,
    required this.snoozedIds,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<SimplifiedSubscriptionProvider>(
      builder: (context, provider, _) {
        final total = isSelectionMode
            ? provider.getActiveSubscriptions(snoozedIds).length
            : provider.subscriptions.length;
        final monthly = isSelectionMode
            ? provider.getFilteredTotalMonthlyCost(snoozedIds)
            : provider.totalMonthlyCost;
        final yearly = monthly * 12;

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Overview', // Title updated
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primaryContainer,
                          colorScheme.secondaryContainer,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$total',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primaryContainer.withOpacity(0.6),
                      colorScheme.secondaryContainer.withOpacity(0.4),
                      colorScheme.tertiaryContainer.withOpacity(0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.15),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Monthly',
                        value: '€${monthly.toStringAsFixed(0)}',
                        suffix: '/mo',
                        icon: Icons.calendar_today_rounded,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Yearly',
                        value: '€${yearly.toStringAsFixed(0)}',
                        suffix: '/yr',
                        icon: Icons.trending_up_rounded,
                        color: colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String suffix;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.suffix,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.2),
                      color.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: -0.8,
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 1),
                child: Text(
                  suffix,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedSection extends StatelessWidget {
  final String title;
  final List<SubscriptionOccurrence> occurrences;
  final SimplifiedSubscriptionProvider provider;
  final _SubscriptionsState parent;

  const _AnimatedSection({
    required this.title,
    required this.occurrences,
    required this.provider,
    required this.parent,
  });

  @override
  Widget build(BuildContext context) {
    final headerAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: parent._fadeController,
      curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SlideTransition(
          position: headerAnimation,
          child: _buildSectionHeader(context, title, occurrences.length),
        ),
        ...occurrences.map((occ) {
          return SubscriptionCardWrapper(
            subscription: occ.subscription,
            displayDate: occ.date,
            isAmountBlurred: false,
            isSelectionMode: parent.widget.isSelectionMode,
            isSnoozed: parent.widget.isSubscriptionSnoozed(occ.subscription.id),
            onEdit: (updatedSub) => provider.updateSubscription(updatedSub),
            onDelete: (sub) => parent._showDeleteConfirmation(
              context: context,
              subscription: sub,
              provider: provider,
            ),
            onLongPress: () =>
                parent.widget.enterSelectionMode(occ.subscription.id),
            onTap: parent.widget.isSelectionMode
                ? () => parent.widget.toggleSnooze(occ.subscription.id)
                : null,
            onSnoozeChanged: (value) =>
                parent.widget.toggleSnooze(occ.subscription.id),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    final colorScheme = Theme.of(context).colorScheme;

    // ✅ CHANGÉ : On utilise toujours la couleur primaire du thème pour une cohérence parfaite.
    final Color headerColor = colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 12),
      // ✅ CHANGÉ : Le fond est maintenant un dégradé très subtil de la couleur primaire.
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            headerColor.withOpacity(0.1), // Plus doux
            headerColor.withOpacity(0.0), // Fondu vers transparent
          ],
          stops: const [0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        // ✅ CHANGÉ : Une bordure subtile qui correspond au thème.
        border: Border.all(color: headerColor.withOpacity(0.2), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // ✅ CHANGÉ : L'icône est maintenant toujours l'icône "calendrier".
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: headerColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.calendar_month_rounded, size: 18, color: headerColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                color: headerColor,
                fontWeight: FontWeight.w800,
                fontSize: 13,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              // ✅ CHANGÉ : Le fond de la pastille est plus doux.
              color: headerColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: headerColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}