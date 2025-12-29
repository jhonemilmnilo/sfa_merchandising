import "package:flutter/material.dart";
import "package:sfa_merchandising/widgets/app_bottom_nav.dart";
import "../theme.dart";

class MyDayPage extends StatelessWidget {
  const MyDayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // ---------------------------------------------------------------------
    // START: Mock Data (UI-first)
    // One Store -> many Tasks
    // ---------------------------------------------------------------------
    final stores = <_MyDayStore>[
      _MyDayStore(
        storeName: "ABC Pharmacy",
        address: "123 Main St, Barangay Sampaloc, Manila",
        tasks: const [
          _MyDayTask(taskName: "Planogram Compliance"),
          _MyDayTask(taskName: "Price Check"),
          _MyDayTask(taskName: "Display Compliance"),
        ],
      ),
      _MyDayStore(
        storeName: "HealthPlus Drugstore",
        address: "Unit 4, Market Road, Quezon City",
        tasks: const [
          _MyDayTask(taskName: "Planogram Compliance"),
          _MyDayTask(taskName: "OOS Check"),
        ],
      ),
    ];
    // ---------------------------------------------------------------------
    // END: Mock Data
    // ---------------------------------------------------------------------

    return Scaffold(
      backgroundColor: cs.background,

      // ---------------------------------------------------------------------
      // START: App Bar
      // ---------------------------------------------------------------------
      appBar: AppBar(
        title: const Text("My Day"),
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () {
            // TODO: open drawer/menu later
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              // TODO: notifications later
            },
          ),
        ],
      ),
      // ---------------------------------------------------------------------
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
            // START: Page Title Section
            // -----------------------------------------------------------------
            Text(
              "Task for Today",
              style: context.textStyles.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              "Complete your store tasks and submit before end of day.",
              style: context.textStyles.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // -----------------------------------------------------------------
            // END: Page Title Section
            // -----------------------------------------------------------------

            // -----------------------------------------------------------------
            // START: Store Sections (each store header outside, tasks inside)
            // -----------------------------------------------------------------
            for (final store in stores) ...[
              _StoreSection(store: store),
              const SizedBox(height: AppSpacing.lg),
            ],
            // -----------------------------------------------------------------
            // END: Store Sections
            // -----------------------------------------------------------------
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
}

/* ------------------------------ Store Section ------------------------------ */

class _StoreSection extends StatelessWidget {
  final _MyDayStore store;

  const _StoreSection({required this.store});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -------------------------------------------------------------------
        // START: Store Header (outside the task cards)
        // -------------------------------------------------------------------
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store identity
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.storeName,
                      style: context.textStyles.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      store.address,
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      "${store.tasks.length} task(s)",
                      style: context.textStyles.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Optional chip/status for the store
              const SizedBox(width: AppSpacing.sm),
              const _Chip(label: "Today", icon: Icons.today_rounded),
            ],
          ),
        ),
        // -------------------------------------------------------------------
        // END: Store Header
        // -------------------------------------------------------------------

        const SizedBox(height: AppSpacing.md),

        // -------------------------------------------------------------------
        // START: Tasks for this store
        // -------------------------------------------------------------------
        for (final task in store.tasks) ...[
          _TaskCard(task: task),
          const SizedBox(height: AppSpacing.md),
        ],
        // -------------------------------------------------------------------
        // END: Tasks for this store
        // -------------------------------------------------------------------
      ],
    );
  }
}

/* ------------------------------ Task Card ------------------------------ */

class _TaskCard extends StatefulWidget {
  final _MyDayTask task;

  const _TaskCard({required this.task});

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard> {
  // Static placeholders for now (later: store image file paths)
  bool _beforeCaptured = false;
  bool _afterCaptured = false;

  bool get _canSubmit => _beforeCaptured && _afterCaptured;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // ---------------------------------------------------------------------
    // START: Task Card Container
    // ---------------------------------------------------------------------
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
          // ---------------------------------------------------------------
          // START: Task Header (task name + status chip)
          // ---------------------------------------------------------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.task.taskName,
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const _Chip(label: "Pending", icon: Icons.schedule_rounded),
            ],
          ),
          // ---------------------------------------------------------------
          // END: Task Header
          // ---------------------------------------------------------------

          const SizedBox(height: AppSpacing.sm),

          // ---------------------------------------------------------------
          // START: Planogram Section
          // ---------------------------------------------------------------
          _ImageBlock(
            title: "Planogram",
            subtitle: "Reference image (static placeholder)",
            height: 150,
            child: Center(
              child: Icon(
                Icons.image_outlined,
                size: 42,
                color: cs.onSurface.withOpacity(0.45),
              ),
            ),
          ),
          // ---------------------------------------------------------------
          // END: Planogram Section
          // ---------------------------------------------------------------

          const SizedBox(height: AppSpacing.md),

          // ---------------------------------------------------------------
          // START: Before/After Capture Section
          // ---------------------------------------------------------------
          Row(
            children: [
              Expanded(
                child: _CaptureTile(
                  label: "Before",
                  captured: _beforeCaptured,
                  onTap: () => setState(() => _beforeCaptured = true),
                  onClear: _beforeCaptured
                      ? () => setState(() => _beforeCaptured = false)
                      : null,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _CaptureTile(
                  label: "After",
                  captured: _afterCaptured,
                  onTap: () => setState(() => _afterCaptured = true),
                  onClear: _afterCaptured
                      ? () => setState(() => _afterCaptured = false)
                      : null,
                ),
              ),
            ],
          ),
          // ---------------------------------------------------------------
          // END: Before/After Capture Section
          // ---------------------------------------------------------------

          const SizedBox(height: AppSpacing.md),

          // ---------------------------------------------------------------
          // START: Submit Button Section
          // ---------------------------------------------------------------
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _canSubmit
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Submitted: ${widget.task.taskName} (static UI)",
                          ),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.check_circle_rounded),
              label: Text(
                "Submit",
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _canSubmit
                ? "Ready to submit."
                : "Capture both Before and After to enable Submit.",
            style: context.textStyles.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          // ---------------------------------------------------------------
          // END: Submit Button Section
          // ---------------------------------------------------------------
        ],
      ),
    );
    // ---------------------------------------------------------------------
    // END: Task Card Container
    // ---------------------------------------------------------------------
  }
}

/* ------------------------------ UI bits ------------------------------ */

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _Chip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // START: Chip Container
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: cs.primary.withOpacity(0.18),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.primary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: context.textStyles.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
    // END: Chip Container
  }
}

class _ImageBlock extends StatelessWidget {
  final String title;
  final String subtitle;
  final double height;
  final Widget child;

  const _ImageBlock({
    required this.title,
    required this.subtitle,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // START: Image Block Container
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textStyles.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: context.textStyles.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withOpacity(0.35),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: cs.outline.withOpacity(0.16),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: child,
          ),
        ),
      ],
    );
    // END: Image Block Container
  }
}

class _CaptureTile extends StatelessWidget {
  final String label;
  final bool captured;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _CaptureTile({
    required this.label,
    required this.captured,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // START: Capture Tile Container
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: onTap,
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withOpacity(0.25),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: cs.outline.withOpacity(0.16),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // START: Capture Tile Main Content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    captured ? Icons.photo_rounded : Icons.add_a_photo_rounded,
                    size: 36,
                    color: cs.onSurface.withOpacity(0.60),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    captured ? "$label Captured" : "Capture $label",
                    style: context.textStyles.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            // END: Capture Tile Main Content

            // START: Top-left Label Tag
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: cs.surface.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: cs.outline.withOpacity(0.16),
                    width: 1,
                  ),
                ),
                child: Text(
                  label,
                  style: context.textStyles.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            // END: Top-left Label Tag

            // START: Clear Button
            if (onClear != null)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  tooltip: "Remove",
                  onPressed: onClear,
                  icon: Icon(Icons.close_rounded, color: cs.onSurface),
                ),
              ),
            // END: Clear Button

            // START: Plus Badge
            if (!captured)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 34,
                  width: 60,
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: cs.outline.withOpacity(0.16),
                      width: 1,
                    ),
                  ),
                  child: Icon(Icons.add_rounded, color: cs.onSurface),
                ),
              ),
            // END: Plus Badge
          ],
        ),
      ),
    );
    // END: Capture Tile Container
  }
}

/* ------------------------------ Models ------------------------------ */

class _MyDayStore {
  final String storeName;
  final String address;
  final List<_MyDayTask> tasks;

  const _MyDayStore({
    required this.storeName,
    required this.address,
    required this.tasks,
  });
}

class _MyDayTask {
  final String taskName;

  const _MyDayTask({
    required this.taskName,
  });
}
