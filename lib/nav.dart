import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

import "package:sfa_merchandising/pages/loginPage.dart";
import "package:sfa_merchandising/pages/dashboard_page.dart";
import "package:sfa_merchandising/pages/my_day_page.dart";
import "package:sfa_merchandising/pages/report_page.dart";
import "package:sfa_merchandising/pages/calendar_page.dart";

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
      // START: Calendar Route (replaces Sales History)
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
      // START: Reports Route (real page)
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
    ],
  );
}

/// Route path constants
class AppRoutes {
  static const String login = "/";
  static const String dashboard = "/dashboard";

  // Bottom nav
  static const String myDay = "/my-day";
  static const String calendar = "/calendar";
  static const String reports = "/reports";

  // Future routes (referenced by dashboard quick actions)
  static const String newOrder = "/orders/new";
  static const String newTask = "/tasks/new";
  static const String camera = "/camera";
  static const String customers = "/customers";
  static const String audit = "/audit";
  static const String profile = "/profile";
  static const String menu = "/menu";
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
