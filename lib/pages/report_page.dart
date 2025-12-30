import "package:flutter/material.dart";
import "package:sfa_merchandising/widgets/app_bottom_nav.dart";
import "package:sfa_merchandising/widgets/app_drawer.dart"; // ✅ new shared drawer
import "../theme.dart";

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _soldCtrl = TextEditingController();
  int _selectedProductIndex = 0;

  // Static mock products (UI-first)
  final List<_ReportProduct> _products = const [
    _ReportProduct(
      name: "Product A",
      code: "PRD-001",
      dailyPieces: 12,
      monthlySales: 340,
      yearlySales: 4020,
    ),
    _ReportProduct(
      name: "Product B",
      code: "PRD-002",
      dailyPieces: 7,
      monthlySales: 210,
      yearlySales: 2860,
    ),
    _ReportProduct(
      name: "Product C",
      code: "PRD-003",
      dailyPieces: 19,
      monthlySales: 520,
      yearlySales: 6250,
    ),
  ];

  @override
  void dispose() {
    _soldCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final product = _products[_selectedProductIndex];

    return Scaffold(
      backgroundColor: cs.background,
drawer: const AppDrawer(),
      // ---------------------------------------------------------------------
      // START: App Bar (Report and Monitoring)
      // ---------------------------------------------------------------------
      appBar: AppBar(
  title: const Text("Reports & Monitoring"),
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
            // START: Product Tabs (static chips)
            // -----------------------------------------------------------------
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_products.length, (i) {
                  final isSelected = i == _selectedProductIndex;

                  return Padding(
                    padding: EdgeInsets.only(
                      right: i == _products.length - 1 ? 0 : AppSpacing.sm,
                    ),
                    child: ChoiceChip(
                      selected: isSelected,
                      label: Text(_products[i].name),
                      onSelected: (_) => setState(() => _selectedProductIndex = i),
                      labelStyle: context.textStyles.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isSelected ? cs.onPrimary : cs.onSurface,
                      ),
                      selectedColor: cs.primary,
                      backgroundColor: cs.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        side: BorderSide(
                          color: cs.outline.withOpacity(0.18),
                          width: 1,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            // -----------------------------------------------------------------
            // END: Product Tabs
            // -----------------------------------------------------------------

            const SizedBox(height: AppSpacing.lg),

            // -----------------------------------------------------------------
            // START: Sales Summary Section
            // -----------------------------------------------------------------
            Text(
              "Sale in a year",
              style: context.textStyles.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // KPI cards (Daily / Monthly / Yearly)
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: "Daily Sale (pieces)",
                    value: "${product.dailyPieces}",
                    icon: Icons.today_rounded,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _StatCard(
                    title: "Monthly Sale",
                    value: "${product.monthlySales}",
                    icon: Icons.calendar_month_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            _StatCardWide(
              title: "Total Yearly Sale",
              value: "${product.yearlySales}",
              icon: Icons.assessment_rounded,
            ),
            // -----------------------------------------------------------------
            // END: Sales Summary Section
            // -----------------------------------------------------------------

            const SizedBox(height: AppSpacing.lg),

            // -----------------------------------------------------------------
            // START: Product Info Card (name/code + image placeholder)
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
              child: Row(
                children: [
                  // Product name + code
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: context.textStyles.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          "Product Code: ${product.code}",
                          style: context.textStyles.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: AppSpacing.md),

                  // Image placeholder
                  Container(
                    height: 86,
                    width: 110,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: cs.outline.withOpacity(0.16),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.image_outlined,
                      size: 32,
                      color: cs.onSurface.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),
            // -----------------------------------------------------------------
            // END: Product Info Card
            // -----------------------------------------------------------------

            const SizedBox(height: AppSpacing.lg),

            // -----------------------------------------------------------------
            // START: Record Today's Sales
            // -----------------------------------------------------------------
            Text(
              "Record Today's Sales",
              style: context.textStyles.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

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
                  Text(
                    "Total Sold Pieces",
                    style: context.textStyles.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  TextField(
                    controller: _soldCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "e.g. 24",
                      prefixIcon: Icon(
                        Icons.numbers_rounded,
                        color: cs.onSurface.withOpacity(0.55),
                      ),
                      filled: true,
                      fillColor: cs.surfaceContainerHighest.withOpacity(0.25),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: BorderSide(
                          color: cs.outline.withOpacity(0.14),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: BorderSide(
                          color: cs.primary.withOpacity(0.8),
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => _save(context, product),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                      child: Text(
                        "Save",
                        style: context.textStyles.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // -----------------------------------------------------------------
            // END: Record Today's Sales
            // -----------------------------------------------------------------

            const SizedBox(height: AppSpacing.xl),
          ],
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

  void _save(BuildContext context, _ReportProduct product) {
    final raw = _soldCtrl.text.trim();
    final parsed = int.tryParse(raw);

    if (parsed == null || parsed < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid number.")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Saved: $parsed sold pieces for ${product.name} (static UI)"),
      ),
    );

    // UI-first: clear input
    _soldCtrl.clear();
  }
}

/* ------------------------------ UI Widgets ------------------------------ */

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
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
              Expanded(
                child: Text(
                  title,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(icon, size: 18, color: cs.primary),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: context.textStyles.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCardWide extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCardWide({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: cs.outline.withOpacity(0.18),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: cs.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              title,
              style: context.textStyles.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: context.textStyles.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

/* ------------------------------ Model ------------------------------ */

class _ReportProduct {
  final String name;
  final String code;

  // Static metrics for the selected product
  final int dailyPieces;
  final int monthlySales;
  final int yearlySales;

  const _ReportProduct({
    required this.name,
    required this.code,
    required this.dailyPieces,
    required this.monthlySales,
    required this.yearlySales,
  });
}
