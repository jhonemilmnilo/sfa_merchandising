import "package:flutter/material.dart";
import "package:sfa_merchandising/widgets/app_bottom_nav.dart";
import "package:sfa_merchandising/widgets/app_drawer.dart"; // ✅ new shared drawer
import "../theme.dart";

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  late DateTime _selectedDate;

  // Mock schedule: date -> list of store visits
  late final Map<DateTime, List<_StoreVisit>> _visitsByDate;

  @override
  void initState() {
    super.initState();

    // ---------------------------------------------------------------------
    // START: Selected Date Init (date-only)
    // ---------------------------------------------------------------------
    _selectedDate = _dateOnly(DateTime.now());
    // ---------------------------------------------------------------------
    // END: Selected Date Init
    // ---------------------------------------------------------------------

    // ---------------------------------------------------------------------
    // START: Static mock data (UI-first)
    // ---------------------------------------------------------------------
    final today = _dateOnly(DateTime.now());

    _visitsByDate = {
      today.subtract(const Duration(days: 2)): const [
        _StoreVisit(storeName: "ABC Pharmacy", address: "Sampaloc, Manila", visited: false), // missed => red
        _StoreVisit(storeName: "HealthPlus", address: "España Blvd", visited: true), // green
      ],
      today.subtract(const Duration(days: 1)): const [
        _StoreVisit(storeName: "Mercury Drug", address: "Quezon Ave", visited: false), // missed => red
      ],
      today: const [
        _StoreVisit(storeName: "Watsons", address: "SM City", visited: true), // green
        _StoreVisit(storeName: "Generika", address: "Dapitan St", visited: false), // today not visited => red
      ],
      today.add(const Duration(days: 1)): const [
        _StoreVisit(storeName: "SouthStar", address: "Makati", visited: false), // future not visited => red (pending)
      ],
    };
    // ---------------------------------------------------------------------
    // END: Static mock data
    // ---------------------------------------------------------------------
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final today = _dateOnly(DateTime.now());

    final days = _buildMonthGridDays(_focusedMonth);
    final selectedVisits = _visitsByDate[_selectedDate] ?? const [];

    return Scaffold(
      backgroundColor: cs.background,
drawer: const AppDrawer(),
      // ---------------------------------------------------------------------
      // START: App Bar (Calendar)
      // ---------------------------------------------------------------------
  appBar: AppBar(
  title: const Text("Calendar"),
  leading: Builder(
    builder: (ctx) => IconButton(
      icon: const Icon(Icons.menu_rounded),
      onPressed: () => Scaffold.of(ctx).openDrawer(),
    ),
  ),
  actions: [
    IconButton(
      tooltip: "Sync",
      icon: const Icon(Icons.sync_rounded),
      onPressed: () {
        // TODO: trigger offline-first sync (upload pending changes, then pull latest)
        // Example (later): context.read(syncControllerProvider).sync();
      },
    ),
  ],
),

      // END: App Bar
      // ---------------------------------------------------------------------

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          children: [
            // -----------------------------------------------------------------
            // START: Month Header (Prev / Month Title / Next)
            // -----------------------------------------------------------------
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
                    _selectedDate = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
                  }),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      _monthTitle(_focusedMonth),
                      style: context.textStyles.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
                    _selectedDate = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
                  }),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
            // -----------------------------------------------------------------
            // END: Month Header
            // -----------------------------------------------------------------

            const SizedBox(height: AppSpacing.md),

            // -----------------------------------------------------------------
            // START: Calendar Grid Container
            // -----------------------------------------------------------------
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
                children: [
                  // Weekday header
                  Row(
                    children: const [
                      _WeekdayLabel("Sun"),
                      _WeekdayLabel("Mon"),
                      _WeekdayLabel("Tue"),
                      _WeekdayLabel("Wed"),
                      _WeekdayLabel("Thu"),
                      _WeekdayLabel("Fri"),
                      _WeekdayLabel("Sat"),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Calendar day grid (42 cells)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: days.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                      childAspectRatio: 1.05,
                    ),
                    itemBuilder: (context, index) {
                      final day = days[index];
                      final dayOnly = _dateOnly(day);

                      final inMonth =
                          day.month == _focusedMonth.month && day.year == _focusedMonth.year;
                      final isSelected = dayOnly == _selectedDate;
                      final isToday = dayOnly == today;

                      // Dot type for this date (green if all visited, red if any missed/pending)
                      final visits = _visitsByDate[dayOnly] ?? const [];
                      final dot = _dayDotType(dayOnly, visits);

                      return _DayCell(
                        day: day,
                        inMonth: inMonth,
                        isSelected: isSelected,
                        isToday: isToday,
                        dot: dot,
                        onTap: () => setState(() => _selectedDate = dayOnly),
                      );
                    },
                  ),
                ],
              ),
            ),
            // -----------------------------------------------------------------
            // END: Calendar Grid Container
            // -----------------------------------------------------------------

            const SizedBox(height: AppSpacing.lg),

            // -----------------------------------------------------------------
            // START: Legend (Red/Green)
            // -----------------------------------------------------------------
            Row(
              children: [
                _LegendDot(color: Colors.green, label: "Visited"),
                const SizedBox(width: AppSpacing.md),
                _LegendDot(color: Colors.red, label: "Not visited / Missed"),
              ],
            ),
            // -----------------------------------------------------------------
            // END: Legend
            // -----------------------------------------------------------------

            const SizedBox(height: AppSpacing.lg),

            // -----------------------------------------------------------------
            // START: Store Visit List for Selected Date
            // -----------------------------------------------------------------
            Text(
              "Store Visit",
              style: context.textStyles.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            if (selectedVisits.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: cs.outline.withOpacity(0.18), width: 1),
                ),
                child: Text(
                  "No scheduled visits for this date.",
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              )
            else
              ...selectedVisits.map((v) {
                final statusColor = _visitStatusColor(_selectedDate, v);
                final statusIcon = v.visited
                    ? Icons.check_circle_rounded
                    : Icons.error_rounded;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: cs.outline.withOpacity(0.18), width: 1),
                    ),
                    child: Row(
                      children: [
                        // Store info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                v.storeName,
                                style: context.textStyles.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                v.address,
                                style: context.textStyles.bodyMedium?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Status icon (green if visited, red if missed/pending)
                        Icon(statusIcon, color: statusColor),
                      ],
                    ),
                  ),
                );
              }),
            // -----------------------------------------------------------------
            // END: Store Visit List
            // -----------------------------------------------------------------
          ],
        ),
      ),

      // ---------------------------------------------------------------------
      // START: Shared Bottom Navigation
      // ---------------------------------------------------------------------
      bottomNavigationBar: const AppBottomNav(),
      // ---------------------------------------------------------------------
      // END: Shared Bottom Navigation
      // ---------------------------------------------------------------------
    );
  }

  // -------------------------------------------------------------------------
  // Dot logic for each day cell:
  // - If no schedule => none
  // - If all visits completed => green
  // - If any unvisited => red (pending or missed)
  // -------------------------------------------------------------------------
  _DotType _dayDotType(DateTime day, List<_StoreVisit> visits) {
    if (visits.isEmpty) return _DotType.none;

    final allVisited = visits.every((v) => v.visited);
    if (allVisited) return _DotType.green;

    // Any unvisited => red (covers both "pending today/future" and "missed past")
    return _DotType.red;
  }

  Color _visitStatusColor(DateTime selectedDate, _StoreVisit v) {
    if (v.visited) return Colors.green;
    return Colors.red;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static String _monthTitle(DateTime d) {
    const months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return "${months[d.month - 1]} ${d.year}";
  }

  static List<DateTime> _buildMonthGridDays(DateTime monthFirstDay) {
    final firstOfMonth = DateTime(monthFirstDay.year, monthFirstDay.month, 1);

    // Make Sunday = 0
    final firstWeekday = firstOfMonth.weekday % 7;

    final start = firstOfMonth.subtract(Duration(days: firstWeekday));

    // 6 rows x 7 days = 42 cells
    return List.generate(42, (i) => start.add(Duration(days: i)));
  }
}

/* ------------------------------ Small Widgets ------------------------------ */

class _WeekdayLabel extends StatelessWidget {
  final String text;
  const _WeekdayLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: Center(
        child: Text(
          text,
          style: context.textStyles.labelMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime day;
  final bool inMonth;
  final bool isSelected;
  final bool isToday;
  final _DotType dot;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.inMonth,
    required this.isSelected,
    required this.isToday,
    required this.dot,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color textColor;
    if (!inMonth) {
      textColor = cs.onSurface.withOpacity(0.25);
    } else if (isSelected) {
      textColor = cs.onPrimary;
    } else {
      textColor = cs.onSurface;
    }

    final bgColor = isSelected ? cs.primary : Colors.transparent;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isToday && !isSelected
                ? cs.primary.withOpacity(0.35)
                : cs.outline.withOpacity(0.10),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                "${day.day}",
                style: context.textStyles.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
            ),
            if (dot != _DotType.none)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _Dot(
                    color: dot == _DotType.green ? Colors.green : Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        _Dot(color: color),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: context.textStyles.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/* ------------------------------ Models ------------------------------ */

class _StoreVisit {
  final String storeName;
  final String address;
  final bool visited;

  const _StoreVisit({
    required this.storeName,
    required this.address,
    required this.visited,
  });
}

enum _DotType { none, red, green }
