// lib/pages/my_day_page.dart
import "dart:io";

import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";

import "package:sfa_merchandising/widgets/app_bottom_nav.dart";
import "package:sfa_merchandising/widgets/app_drawer.dart";
import "../theme.dart";

class MyDayPage extends StatefulWidget {
  const MyDayPage({super.key});

  @override
  State<MyDayPage> createState() => _MyDayPageState();
}

class _MyDayPageState extends State<MyDayPage> {
  final _picker = ImagePicker();

  // v0: single store, single task
  final _storeName = "COSTSAVER'S SUPERMARKET, INC";
  final _storeAddress = "Biday, San Fernando City, La Union";
  final _taskName = "Prepare and update sales proposals";

  // captured images (camera)
  XFile? _before;
  XFile? _after;

  bool _syncing = false;

  bool get _canSubmit => _before != null && _after != null;

  Future<void> _captureBefore() async {
    final file = await _captureFromCamera();
    if (!mounted) return;
    if (file != null) setState(() => _before = file);
  }

  Future<void> _captureAfter() async {
    final file = await _captureFromCamera();
    if (!mounted) return;
    if (file != null) setState(() => _after = file);
  }

  Future<XFile?> _captureFromCamera() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 82, // compress a bit (offline-first friendly)
      );
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Camera error: $e")),
      );
      return null;
    }
  }

  Future<void> _onSubmit() async {
    if (!_canSubmit) return;

    // v0: local-only action (later: offline queue + upload)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Submitted: $_taskName (local v0)")),
    );
  }

  Future<void> _onSync() async {
    setState(() => _syncing = true);
    try {
      // v0 placeholder
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sync placeholder (v0).")),
      );
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text("My Day"),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            tooltip: "Sync",
            icon: _syncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync_rounded),
            onPressed: _syncing ? null : _onSync,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          children: [
            Text(
              "Task for Today",
              style: context.textStyles.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              "Complete your store task and submit before end of day.",
              style: context.textStyles.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Store header
            _StoreHeader(
              storeName: _storeName,
              address: _storeAddress,
              taskCountText: "1 task",
            ),

            const SizedBox(height: AppSpacing.md),

            // Task card
            _TaskCard(
              taskName: _taskName,
              planogramAssetPath: "assets/images/shelves-3d-rendered-product-displays-on-supermarket_9774954.jpg!bw700",
              beforeFile: _before,
              afterFile: _after,
              onCaptureBefore: _captureBefore,
              onCaptureAfter: _captureAfter,
              onClearBefore: _before == null ? null : () => setState(() => _before = null),
              onClearAfter: _after == null ? null : () => setState(() => _after = null),
              canSubmit: _canSubmit,
              onSubmit: _onSubmit,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                   Widgets                                  */
/* -------------------------------------------------------------------------- */

class _StoreHeader extends StatelessWidget {
  final String storeName;
  final String address;
  final String taskCountText;

  const _StoreHeader({
    required this.storeName,
    required this.address,
    required this.taskCountText,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeName,
                  style: context.textStyles.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  address,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  taskCountText,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const _Chip(label: "Today", icon: Icons.today_rounded),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final String taskName;

  final String planogramAssetPath;

  final XFile? beforeFile;
  final XFile? afterFile;

  final VoidCallback onCaptureBefore;
  final VoidCallback onCaptureAfter;
  final VoidCallback? onClearBefore;
  final VoidCallback? onClearAfter;

  final bool canSubmit;
  final VoidCallback onSubmit;

  const _TaskCard({
    required this.taskName,
    required this.planogramAssetPath,
    required this.beforeFile,
    required this.afterFile,
    required this.onCaptureBefore,
    required this.onCaptureAfter,
    required this.onClearBefore,
    required this.onClearAfter,
    required this.canSubmit,
    required this.onSubmit,
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
          // Header (name + status)
          Row(
            children: [
              Expanded(
                child: Text(
                  taskName,
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const _Chip(label: "Pending", icon: Icons.schedule_rounded),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Planogram reference image
          _ImageBlock(
            title: "Planogram",
            subtitle: "Reference image",
            height: 170,
            child: _PlanogramPreview(assetPath: planogramAssetPath),
          ),

          const SizedBox(height: AppSpacing.md),

          // Before/After
          Row(
            children: [
              Expanded(
                child: _CaptureTile(
                  label: "Before",
                  file: beforeFile,
                  onTap: onCaptureBefore,
                  onClear: onClearBefore,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _CaptureTile(
                  label: "After",
                  file: afterFile,
                  onTap: onCaptureAfter,
                  onClear: onClearAfter,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Submit
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: canSubmit ? onSubmit : null,
              icon: const Icon(Icons.check_circle_rounded),
              label: Text(
                "Submit",
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
      foregroundColor: cs.onPrimary,

      // Disabled (when onPressed == null)
      disabledBackgroundColor: cs.surfaceContainerHighest.withOpacity(0.6),
      disabledForegroundColor: cs.onSurfaceVariant.withOpacity(0.7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            canSubmit
                ? "Ready to submit."
                : "Capture both Before and After to enable Submit.",
            style: context.textStyles.bodySmall?.copyWith(
              color: canSubmit ? cs.primary : cs.onSurfaceVariant,
    fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanogramPreview extends StatelessWidget {
  final String assetPath;
  const _PlanogramPreview({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (_) => Dialog(
          insetPadding: const EdgeInsets.all(AppSpacing.md),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: InteractiveViewer(
              child: Image.asset(assetPath, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
      child: Image.asset(assetPath, fit: BoxFit.cover),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Chip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
  }
}

class _CaptureTile extends StatelessWidget {
  final String label;
  final XFile? file;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _CaptureTile({
    required this.label,
    required this.file,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final hasImage = file != null;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: onTap,
      child: Container(
        height: 150,
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
            // Main content
            Center(
              child: hasImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Image.file(
                        File(file!.path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_a_photo_rounded,
                          size: 36,
                          color: cs.onSurface.withOpacity(0.60),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          "Capture $label",
                          style: context.textStyles.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
            ),

            // Label tag
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: cs.surface.withOpacity(0.92),
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

            // Clear button
            if (onClear != null)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  tooltip: "Remove",
                  onPressed: onClear,
                  icon: Icon(Icons.close_rounded, color: cs.onSurface),
                ),
              ),

            // Bottom “tap to retake” hint when image exists
            if (hasImage)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surface.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: cs.outline.withOpacity(0.16),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    "Tap to retake",
                    style: context.textStyles.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
