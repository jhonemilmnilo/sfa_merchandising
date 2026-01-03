import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

import "package:sfa_merchandising/pages/loginPage.dart";
import "package:sfa_merchandising/pages/dashboard_page.dart";
import "package:sfa_merchandising/pages/my_day_page.dart";
import "package:sfa_merchandising/pages/report_page.dart";
import "package:sfa_merchandising/pages/calendar_page.dart";
import "package:sfa_merchandising/pages/profile_page.dart";
import "package:sfa_merchandising/pages/inventory_page.dart";


  
/// GoRouter configuration for app navigation
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      // -------------------------------------------------------------------
      // START: Login Route
      // -------------------------------------------------------------------
      GoRoute(
        path: AppRoutes.login,
        name: "login",
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LoginPage(),
        ),
      ),
      // -------------------------------------------------------------------
      // END: Login Route
      // -------------------------------------------------------------------

      // -------------------------------------------------------------------
      // START: Dashboard Route
      // -------------------------------------------------------------------
      GoRoute(
        path: AppRoutes.dashboard,
        name: "dashboard",
        pageBuilder: (context, state) => const NoTransitionPage(
          child: DashboardPage(),
        ),
      ),
      // -------------------------------------------------------------------
      // END: Dashboard Route
      // -------------------------------------------------------------------

      // -------------------------------------------------------------------
      // START: My Day Route
      // -------------------------------------------------------------------
      GoRoute(
        path: AppRoutes.myDay,
        name: "myDay",
        pageBuilder: (context, state) => const NoTransitionPage(
          child: MyDayPage(),
        ),
      ),
      // -------------------------------------------------------------------
      // END: My Day Route
      // -------------------------------------------------------------------

      // -------------------------------------------------------------------
      // START: Calendar Route (Bottom Nav)
      // -------------------------------------------------------------------
      GoRoute(
        path: AppRoutes.calendar,
        name: "calendar",
        pageBuilder: (context, state) => const NoTransitionPage(
          child: CalendarPage(),
        ),
      ),
      // -------------------------------------------------------------------
      // END: Calendar Route
      // -------------------------------------------------------------------

      // -------------------------------------------------------------------
      // START: Reports Route (Bottom Nav)
      // -------------------------------------------------------------------
      GoRoute(
        path: AppRoutes.reports,
        name: "reports",
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ReportPage(),
        ),
      ),
      // -------------------------------------------------------------------
      // END: Reports Route
      // -------------------------------------------------------------------

      // -------------------------------------------------------------------
      // START: Drawer Routes (Static placeholders for now)
      // -------------------------------------------------------------------
      GoRoute(
        path: AppRoutes.profile,
        name: "profile",
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ProfilePage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.salesHistory,
        name: "salesHistory",
        pageBuilder: (context, state) => const NoTransitionPage(
          child: _PlaceholderPage(title: "Sales History"),
        ),
      ),
      GoRoute(
        path: AppRoutes.weeklySheet,
        name: "weeklySheet",
        pageBuilder: (context, state) => const NoTransitionPage(
          child: _PlaceholderPage(title: "Weekly Sheet"),
        ),
      ),
      // -------------------------------------------------------------------
      // END: Drawer Routes
      // -------------------------------------------------------------------
GoRoute(
  path: AppRoutes.inventory,
  name: "inventory",
  pageBuilder: (context, state) => const NoTransitionPage(
    child: InventoryPage(),
  ),
),

      // -------------------------------------------------------------------
      // START: Future Routes (placeholders so navigation won't crash)
      // -------------------------------------------------------------------
      GoRoute(
        path: AppRoutes.newOrder,
        name: "newOrder",
        pageBuilder: (context, state) => const NoTransitionPage(
          child: _PlaceholderPage(title: "New Order"),
        ),
      ),
      GoRoute(
        path: AppRoutes.newTask,
        name: "newTask",
        pageBuilder: (context, state) => const NoTransitionPage(
          child: _PlaceholderPage(title: "New Task"),
        ),
      ),
      GoRoute(
        path: AppRoutes.camera,
        name: "camera",
        pageBuilder: (context, state) => const NoTransitionPage(
          child: _PlaceholderPage(title: "Camera"),
        ),
      ),
      GoRoute(
        path: AppRoutes.customers,
        name: "customers",
        pageBuilder: (context, state) => const NoTransitionPage(
          child: _PlaceholderPage(title: "Customers"),
        ),
      ),
      GoRoute(
        path: AppRoutes.audit,
        name: "audit",
        pageBuilder: (context, state) => const NoTransitionPage(
          child: _PlaceholderPage(title: "Audit"),
        ),
      ),
      GoRoute(
        path: AppRoutes.menu,
        name: "menu",
        pageBuilder: (context, state) => const NoTransitionPage(
          child: _PlaceholderPage(title: "Menu"),
        ),
      ),
      // -------------------------------------------------------------------
      // END: Future Routes
      // -------------------------------------------------------------------
    ],
  );
}

/// Route path constants
class AppRoutes {
  static const String login = "/";
  static const String dashboard = "/dashboard";

  // Bottom nav pages
  static const String myDay = "/my-day";
  static const String calendar = "/calendar";
  static const String reports = "/reports";

  // Drawer pages
  static const String profile = "/profile";
  static const String salesHistory = "/sales-history";
  static const String weeklySheet = "/weekly-sheet";

  // Future routes (referenced by dashboard quick actions)
  static const String newOrder = "/orders/new";
  static const String newTask = "/tasks/new";
  static const String camera = "/camera";
  static const String customers = "/customers";
  static const String audit = "/audit";
  static const String menu = "/menu";

  static const String inventory = "/inventory";

static const String sales = "/sales";
static const String callSheet = "/call-sheet";

}

/// Simple placeholder page for routes not built yet.
class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          "$title (Coming soon)",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
