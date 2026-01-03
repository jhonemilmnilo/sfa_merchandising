import "package:flutter/material.dart";
import "../theme.dart";
import "package:sfa_merchandising/widgets/app_bottom_nav.dart";
import "package:sfa_merchandising/widgets/app_drawer.dart";
import "../stores/inventory_store.dart";

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  late DateTime _weekStart;
  late DateTime _weekEnd;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _weekStart = startOfWeekMonday(now);
    _weekEnd = endOfWeekSunday(now);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      drawer: const AppDrawer(),

      appBar: AppBar(
        title: const Text("Inventory"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            tooltip: "Sync",
            icon: const Icon(Icons.sync_rounded),
            onPressed: () {
              // TODO: offline-first sync later
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Sync queued (UI-first).")),
              );
            },
          ),
        ],
      ),

      body: AnimatedBuilder(
        animation: inventoryStore,
        builder: (context, _) {
          final rows = inventoryStore.buildWeekRows(
            weekStart: _weekStart,
            weekEnd: _weekEnd,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            children: [
              _WeekHeader(
                weekStart: _weekStart,
                weekEnd: _weekEnd,
                onPrev: () => setState(() {
                  _weekStart = _weekStart.subtract(const Duration(days: 7));
                  _weekEnd = _weekEnd.subtract(const Duration(days: 7));
                }),
                onNext: () => setState(() {
                  _weekStart = _weekStart.add(const Duration(days: 7));
                  _weekEnd = _weekEnd.add(const Duration(days: 7));
                }),
              ),

              const SizedBox(height: AppSpacing.md),

              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: cs.outline.withOpacity(0.18), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Weekly Sales → Inventory (Excel View)",
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      "Columns: Product Name • Code • Date (Initial) • % Sales (Week)",
                      style: context.textStyles.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    if (rows.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: cs.outline.withOpacity(0.14)),
                        ),
                        child: Text(
                          "No records yet. Go to Reports & Monitoring and Save sold pieces.",
                          style: context.textStyles.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowHeight: 44,
                          dataRowMinHeight: 44,
                          dataRowMaxHeight: 56,
                          columns: const [
                            DataColumn(label: Text("Product Name")),
                            DataColumn(label: Text("Product Code")),
                            DataColumn(label: Text("Date (Initial)")),
                            DataColumn(label: Text("% Sales (Week)")),
                          ],
                          rows: rows.map((r) {
                            return DataRow(
                              cells: [
                                DataCell(Text(r.productName)),
                                DataCell(Text(r.productCode)),
                                DataCell(Text(fmtYmd(r.initialDateInWeek))),
                                DataCell(Text("${r.weekPercent.toStringAsFixed(1)}%")),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),

      bottomNavigationBar: const AppBottomNav(),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  final DateTime weekStart;
  final DateTime weekEnd;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _WeekHeader({
    required this.weekStart,
    required this.weekEnd,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        IconButton(
          onPressed: onPrev,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm,
              horizontal: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: cs.outline.withOpacity(0.18)),
            ),
            child: Center(
              child: Text(
                "${fmtYmd(weekStart)}  →  ${fmtYmd(weekEnd)}",
                style: context.textStyles.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}
