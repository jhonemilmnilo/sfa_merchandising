import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

/// Centralized bottom navigation bar used across the app.
/// Replace per-page NavigationBar blocks with:
///   bottomNavigationBar: const AppBottomNav(),
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _selectedIndexFromLocation(location);

    return NavigationBar(
      selectedIndex: selectedIndex,
      height: 72,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            _safeGo(context, "/dashboard");
            break;
          case 1:
            _safeGo(context, "/my-day");
            break;
          case 2:
            _safeGo(context, "/calendar");
            break;
          case 3:
            _safeGo(context, "/reports");
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.grid_view_rounded),
          label: "Dashboard",
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_rounded),
          label: "My Day",
        ),
        NavigationDestination(
          icon: Icon(Icons.event_note_rounded),
          label: "Calendar",
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_rounded),
          label: "Reports",
        ),
      ],
    );
  }

  /// Decide active tab based on the current route.
  /// This makes it work even if you push deeper routes later.
  static int _selectedIndexFromLocation(String location) {
    if (location.startsWith("/dashboard")) return 0;
    if (location.startsWith("/my-day")) return 1;
    if (location.startsWith("/calendar")) return 2;
    if (location.startsWith("/reports")) return 3;

    // Default (e.g. login) - don't highlight anything weird; pick Dashboard
    return 0;
  }

  static void _safeGo(BuildContext context, String path) {
    try {
      context.go(path);
    } catch (_) {
      // Routes might not be registered yet during UI-first phase.
    }
  }
}
