import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "../theme.dart";
import "../nav.dart"; // AppRoutes constants

class AppDrawer extends StatelessWidget {
  final String name;
  final String position;

  const AppDrawer({
    super.key,
    this.name = "Merchandiser Name",
    this.position = "Field Merchandiser",
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // -----------------------------------------------------------------
            // Header: Avatar + Name + Position + Profile Button
            // -----------------------------------------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border(
                  bottom: BorderSide(
                    color: cs.outline.withOpacity(0.14),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: avatar + info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _AvatarBadge(
                        size: 54,
                        background: cs.primary.withOpacity(0.12),
                        border: cs.primary.withOpacity(0.22),
                        iconColor: cs.primary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textStyles.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              position,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textStyles.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Profile action button (clean, subtle)
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: () => _safeGo(context, AppRoutes.profile),
                      icon: const Icon(Icons.person_outline_rounded, size: 18),
                      label: Text(
                        "Profile",
                        style: context.textStyles.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: cs.onSurface,
                        side: BorderSide(color: cs.outline.withOpacity(0.18)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // -----------------------------------------------------------------
            // Menu Items
            // -----------------------------------------------------------------
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  _SectionLabel(text: "Navigation"),

                  const SizedBox(height: AppSpacing.sm),

                  _DrawerNavTile(
                    icon: Icons.insert_chart_outlined_rounded,
                    label: "Weekly Reports",
                    onTap: () => _safeGo(context, AppRoutes.weeklyReports),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  _DrawerNavTile(
                    icon: Icons.shopping_bag_outlined,
                    label: "Sales",
                    onTap: () => _safeGo(context, AppRoutes.sales),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  _DrawerNavTile(
                    icon: Icons.assignment_outlined,
                    label: "Call Sheet",
                    onTap: () => _safeGo(context, AppRoutes.callSheet),
                  ),
                ],
              ),
            ),

            // -----------------------------------------------------------------
            // Bottom: Logout pinned
            // -----------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: cs.outline.withOpacity(0.14)),
                ),
                child: ListTile(
                  leading: Icon(Icons.logout_rounded, color: cs.error),
                  title: Text(
                    "Logout",
                    style: context.textStyles.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: cs.error,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop(); // close drawer
                    _safeGo(context, AppRoutes.login);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _safeGo(BuildContext context, String path) {
    // close drawer if open
    Navigator.of(context).pop();

    try {
      context.go(path);
    } catch (_) {
      // UI-first: route may not exist yet
    }
  }
}

/* ------------------------------ UI Pieces ------------------------------ */

class _AvatarBadge extends StatelessWidget {
  final double size;
  final Color background;
  final Color border;
  final Color iconColor;

  const _AvatarBadge({
    required this.size,
    required this.background,
    required this.border,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: border),
      ),
      child: Icon(Icons.person_rounded, color: iconColor, size: size * 0.58),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Text(
      text.toUpperCase(),
      style: context.textStyles.labelMedium?.copyWith(
        letterSpacing: 0.8,
        fontWeight: FontWeight.w900,
        color: cs.onSurfaceVariant,
      ),
    );
  }
}

class _DrawerNavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerNavTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: cs.outline.withOpacity(0.14),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: cs.onSurface, size: 22),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: context.textStyles.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: cs.onSurface.withOpacity(0.55),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
