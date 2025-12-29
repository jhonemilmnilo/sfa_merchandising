import "package:flutter/material.dart";

import "package:sfa_merchandising/widgets/app_bottom_nav.dart";
import "../theme.dart";

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  // Lime card color from your reference UI (kept consistent across the dashboard)
  static const Color _limeCard = Color(0xFFB7E35B);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Static mock values (UI-first)
    const visitsDone = 0;
    const visitsTotal = 4;
    const remaining = 5;

    const pendingTask = 0;
    const overdue = 0;

    const totalOrder = 0;

    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar (menu + small label + bell)
              Row(
                children: [
                  _IconChip(
                    onTap: () {
                      // TODO: open drawer/menu
                    },
                    icon: Icons.menu_rounded,
                    iconColor: const Color(0xFFE07DA0), // subtle pink like screenshot
                    background: cs.surface,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    "Dashboard",
                    style: context.textStyles.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const Spacer(),
                  _IconChip(
                    onTap: () {
                      // TODO: notifications page
                    },
                    icon: Icons.notifications_none_rounded,
                    iconColor: cs.onSurface,
                    background: cs.surface,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // Big title
              Text(
                "Dash board",
                style: context.textStyles.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              Text(
                "Welcome back Merchant • Here are your task for today",
                style: context.textStyles.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Main KPI card
              _KpiLargeCard(
                background: _limeCard,
                title: "Today’s Visits (DAP)",
                value: "$visitsDone/$visitsTotal",
                subtext: "$remaining remaining",
                icon: Icons.place_outlined,
              ),

              const SizedBox(height: AppSpacing.md),

              // Two small KPI cards
              Row(
                children: [
                  Expanded(
                    child: _KpiSmallCard(
                      background: _limeCard,
                      title: "Pending Task",
                      value: "$pendingTask",
                      subtext: "$overdue Overdue",
                      icon: Icons.assignment_outlined,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _KpiSmallCard(
                      background: _limeCard,
                      title: "Total Order",
                      value: "$totalOrder",
                      subtext: "All time",
                      icon: Icons.shopping_bag_outlined,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Quick actions container
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: cs.outline.withOpacity(0.18),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bolt_rounded, color: cs.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          "Quick Actions",
                          style: context.textStyles.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        // For very small widths, wrap. Otherwise keep 3 across.
                        final useWrap = constraints.maxWidth < 340;

                        final tiles = [
                          _QuickActionTile(
                            background: _limeCard,
                            label: "New Order",
                            icon: Icons.shopping_cart_rounded,
                            iconColor: const Color(0xFFE07DA0),
                            onTap: () {
                              // TODO: route later (static UI phase)
                            },
                          ),
                          _QuickActionTile(
                            background: _limeCard,
                            label: "New Task",
                            icon: Icons.check_circle_rounded,
                            iconColor: const Color(0xFFB80F0A),
                            onTap: () {
                              // TODO: route later (static UI phase)
                            },
                          ),
                          _QuickActionTile(
                            background: _limeCard,
                            label: "Take Photo",
                            icon: Icons.photo_camera_rounded,
                            iconColor: cs.onSurface,
                            onTap: () {
                              // TODO: route later (static UI phase)
                            },
                          ),
                        ];

                        if (useWrap) {
                          return Wrap(
                            spacing: AppSpacing.md,
                            runSpacing: AppSpacing.md,
                            children: tiles
                                .map(
                                  (t) => SizedBox(
                                    width: (constraints.maxWidth - AppSpacing.md) / 2,
                                    child: t,
                                  ),
                                )
                                .toList(),
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: tiles[0]),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(child: tiles[1]),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(child: tiles[2]),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),

      // ---------------------------------------------------------------------
      // START: Bottom Navigation (shared widget)
      // ---------------------------------------------------------------------
      bottomNavigationBar: const AppBottomNav(),
      // ---------------------------------------------------------------------
      // END: Bottom Navigation
      // ---------------------------------------------------------------------
    );
  }
}

/* -------------------------------- Widgets -------------------------------- */

class _IconChip extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color iconColor;
  final Color background;

  const _IconChip({
    required this.onTap,
    required this.icon,
    required this.iconColor,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.16),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: SizedBox(
          height: 42,
          width: 42,
          child: Icon(icon, color: iconColor),
        ),
      ),
    );
  }
}

class _KpiLargeCard extends StatelessWidget {
  final Color background;
  final String title;
  final String value;
  final String subtext;
  final IconData icon;

  const _KpiLargeCard({
    required this.background,
    required this.title,
    required this.value,
    required this.subtext,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  value,
                  style: context.textStyles.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtext,
                  style: context.textStyles.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Right icon
          Icon(icon, size: 28, color: cs.onSurface),
        ],
      ),
    );
  }
}

class _KpiSmallCard extends StatelessWidget {
  final Color background;
  final String title;
  final String value;
  final String subtext;
  final IconData icon;

  const _KpiSmallCard({
    required this.background,
    required this.title,
    required this.value,
    required this.subtext,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with icon top-right
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: context.textStyles.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
              ),
              Icon(icon, size: 24, color: cs.onSurface),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: context.textStyles.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
              height: 1.0,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtext,
            style: context.textStyles.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final Color background;
  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.background,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36, color: iconColor),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                textAlign: TextAlign.center,
                style: context.textStyles.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
