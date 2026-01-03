import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:go_router/go_router.dart";
import "../theme.dart";
import "../nav.dart";

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
    // final textStyles = Theme.of(context).textTheme;
    
    // Get current route to highlight the active menu item
    final String currentRoute = GoRouterState.of(context).uri.path;

    return Drawer(
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(AppRadius.xl),
          bottomRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // --- Header Section ---
            _DrawerHeader(
              name: name,
              position: position,
              onProfileTap: () => _safeGo(context, AppRoutes.profile),
            ),

            // --- Menu Items ---
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.lg,
                ),
                children: [
                  const _SectionLabel(text: "Management"),
                  const SizedBox(height: AppSpacing.sm),
                  
                  _NavTile(
                    label: "Inventory",
                    icon: Icons.inventory_2_outlined,
                    activeIcon: Icons.inventory_2_rounded,
                    isActive: currentRoute == AppRoutes.inventory,
                    onTap: () => _safeGo(context, AppRoutes.inventory),
                  ),
                  
                  _NavTile(
                    label: "Sales Tracking",
                    icon: Icons.analytics_outlined,
                    activeIcon: Icons.analytics_rounded,
                    isActive: currentRoute == AppRoutes.sales,
                    onTap: () => _safeGo(context, AppRoutes.sales),
                  ),
                  
                  _NavTile(
                    label: "Call Sheet",
                    icon: Icons.assignment_outlined,
                    activeIcon: Icons.assignment_rounded,
                    isActive: currentRoute == AppRoutes.callSheet,
                    onTap: () => _safeGo(context, AppRoutes.callSheet),
                  ),
                ],
              ),
            ),

            // --- Footer / Logout ---
            _LogoutButton(onTap: () => _safeGo(context, AppRoutes.login)),
          ],
        ),
      ),
    );
  }

  void _safeGo(BuildContext context, String path) {
    HapticFeedback.lightImpact();
    if (Scaffold.of(context).isDrawerOpen) {
      Navigator.of(context).pop();
    }
    try {
      context.go(path);
    } catch (e) {
      debugPrint("Navigation error: $e");
    }
  }
}

// -----------------------------------------------------------------------------
// Sub-Widgets (Private to this file for encapsulation)
// -----------------------------------------------------------------------------

class _DrawerHeader extends StatelessWidget {
  final String name;
  final String position;
  final VoidCallback onProfileTap;

  const _DrawerHeader({
    required this.name,
    required this.position,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: cs.outlineVariant.withOpacity(0.5)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: cs.primaryContainer,
                child: Icon(Icons.person_3_rounded, color: cs.onPrimaryContainer, size: 30),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      position,
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.tonalIcon(
            onPressed: onProfileTap,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
            icon: const Icon(Icons.account_circle_outlined, size: 18),
            label: const Text("User Profile"),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTile({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: ListTile(
        onTap: onTap,
        selected: isActive,
        selectedTileColor: cs.primaryContainer.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        leading: Icon(
          isActive ? activeIcon : icon,
          color: isActive ? cs.primary : cs.onSurfaceVariant,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? cs.primary : cs.onSurface,
            fontSize: 15,
          ),
        ),
        trailing: isActive 
          ? Icon(Icons.circle, size: 6, color: cs.primary) 
          : Icon(Icons.chevron_right, size: 18, color: cs.outline),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Material(
        color: cs.errorContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: cs.error, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  "Sign Out",
                  style: TextStyle(color: cs.error, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}