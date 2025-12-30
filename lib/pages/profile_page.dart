// lib/pages/profile_page.dart
import "package:flutter/material.dart";

import "package:sfa_merchandising/widgets/app_bottom_nav.dart";
import "package:sfa_merchandising/widgets/app_drawer.dart";
import "../theme.dart";

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // UI-first: mock user payload (replace with API later)
  _UserProfile _mockUser() {
    return const _UserProfile(
      firstName: "Andrei",
      middleName: "Jam Bacho",
      lastName: "Siapno",
      position: "System Developer",
      isAdmin: true,
      email: "ajsiapno60@men2corp.com",
      phone: "09459736254",
      province: "Tarlac",
      city: "Select a City / Municipality",
      barangay: "Select a Barangay",
      dateHired: "2023-10-24",
      departmentId: 14,
      imagePath: "/uploads/users/1760428251958_3ffb7c63-4d10-491f-84e1-54b8c44567a1.jpg",
      emergencyName: null,
      emergencyNumber: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = _mockUser();

    final fullName = _fullName(user.firstName, user.middleName, user.lastName);
    final hired = _fmtDate(user.dateHired);

    return Scaffold(
      backgroundColor: cs.background,
      drawer: const AppDrawer(),

      // ---------------------------------------------------------------------
      // App Bar (hamburger + title + sync)
      // ---------------------------------------------------------------------
      appBar: AppBar(
        title: const Text("Profile"),
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
              // TODO: trigger offline-first sync
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Sync started (static UI).")),
              );
            },
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
            // -----------------------------------------------------------------
            // Header Card (avatar + name + position)
            // -----------------------------------------------------------------
            _HeaderCard(
              name: fullName,
              position: user.position,
              isAdmin: user.isAdmin,
              imagePath: user.imagePath,
              departmentText: user.departmentId != null
                  ? "Department #${user.departmentId}"
                  : null, // replace with real department name later
            ),

            const SizedBox(height: AppSpacing.lg),

            // -----------------------------------------------------------------
            // Contact
            // -----------------------------------------------------------------
            _SectionCard(
              title: "Contact",
              icon: Icons.contact_mail_rounded,
              children: [
                _InfoRow(
                  icon: Icons.email_outlined,
                  label: "Email",
                  value: user.email,
                ),
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: "Mobile",
                  value: user.phone,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // -----------------------------------------------------------------
            // Address (hide placeholder values)
            // -----------------------------------------------------------------
            if (_hasAnyAddress(user.province, user.city, user.barangay))
              _SectionCard(
                title: "Address",
                icon: Icons.location_on_outlined,
                children: [
                  if (_isGoodValue(user.province))
                    _InfoRow(
                      icon: Icons.map_outlined,
                      label: "Province",
                      value: user.province!,
                    ),
                  if (_isGoodValue(user.city) && !_isPlaceholder(user.city!))
                    _InfoRow(
                      icon: Icons.location_city_outlined,
                      label: "City / Municipality",
                      value: user.city!,
                    ),
                  if (_isGoodValue(user.barangay) && !_isPlaceholder(user.barangay!))
                    _InfoRow(
                      icon: Icons.place_outlined,
                      label: "Barangay",
                      value: user.barangay!,
                    ),
                ],
              ),

            if (_hasAnyAddress(user.province, user.city, user.barangay))
              const SizedBox(height: AppSpacing.md),

            // -----------------------------------------------------------------
            // Employment
            // -----------------------------------------------------------------
            _SectionCard(
              title: "Employment",
              icon: Icons.badge_outlined,
              children: [
                _InfoRow(
                  icon: Icons.work_outline_rounded,
                  label: "Position",
                  value: user.position,
                ),
                if (_isGoodValue(hired))
                  _InfoRow(
                    icon: Icons.event_outlined,
                    label: "Date Hired",
                    value: hired,
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // -----------------------------------------------------------------
            // Emergency Contact (optional)
            // -----------------------------------------------------------------
            if (_isGoodValue(user.emergencyName) || _isGoodValue(user.emergencyNumber))
              _SectionCard(
                title: "Emergency Contact",
                icon: Icons.health_and_safety_outlined,
                children: [
                  if (_isGoodValue(user.emergencyName))
                    _InfoRow(
                      icon: Icons.person_outline_rounded,
                      label: "Name",
                      value: user.emergencyName!,
                    ),
                  if (_isGoodValue(user.emergencyNumber))
                    _InfoRow(
                      icon: Icons.phone_in_talk_outlined,
                      label: "Number",
                      value: user.emergencyNumber!,
                    ),
                ],
              ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),

      // Shared bottom navigation
      bottomNavigationBar: const AppBottomNav(),
    );
  }

  // ------------------------------ helpers ------------------------------

  static String _fullName(String f, String? m, String l) {
    final mid = (m == null || m.trim().isEmpty) ? "" : " ${m.trim()}";
    return "${f.trim()}$mid ${l.trim()}".replaceAll(RegExp(r"\s+"), " ").trim();
  }

  static bool _isGoodValue(String? v) => v != null && v.trim().isNotEmpty;

  static bool _isPlaceholder(String v) {
    final s = v.trim().toLowerCase();
    return s.startsWith("select a ");
  }

  static bool _hasAnyAddress(String? p, String? c, String? b) {
    final goodP = _isGoodValue(p);
    final goodC = _isGoodValue(c) && !_isPlaceholder(c!.trim());
    final goodB = _isGoodValue(b) && !_isPlaceholder(b!.trim());
    return goodP || goodC || goodB;
  }

  static String _fmtDate(String? ymd) {
    if (ymd == null || ymd.trim().isEmpty) return "";
    try {
      final d = DateTime.parse(ymd.trim());
      const months = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
      ];
      return "${months[d.month - 1]} ${d.day}, ${d.year}";
    } catch (_) {
      return ymd;
    }
  }
}

/* -------------------------------------------------------------------------- */
/*                                   Widgets                                  */
/* -------------------------------------------------------------------------- */

class _HeaderCard extends StatelessWidget {
  final String name;
  final String position;
  final bool isAdmin;
  final String? departmentText;
  final String? imagePath;

  const _HeaderCard({
    required this.name,
    required this.position,
    required this.isAdmin,
    this.departmentText,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
          _Avatar(imagePath: imagePath),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: context.textStyles.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  position,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (departmentText != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    departmentText!,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _PillChip(
                      icon: Icons.verified_user_outlined,
                      label: "Active",
                    ),
                    if (isAdmin)
                      _PillChip(
                        icon: Icons.admin_panel_settings_outlined,
                        label: "Admin",
                        emphasized: true,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? imagePath;

  const _Avatar({this.imagePath});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final hasImage = imagePath != null && imagePath!.trim().isNotEmpty;
    // UI-first: if your backend returns relative path, you can prefix later (e.g., BASE_URL + imagePath)
    final imageProvider = hasImage && imagePath!.startsWith("http")
        ? NetworkImage(imagePath!)
        : null;

    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: cs.primary.withOpacity(0.18),
          width: 1,
        ),
        image: imageProvider != null
            ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
            : null,
      ),
      child: imageProvider == null
          ? Icon(Icons.person_rounded, color: cs.primary, size: 38)
          : null,
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
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
              Icon(icon, color: cs.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ..._withDividers(context, children),
        ],
      ),
    );
  }

  List<Widget> _withDividers(BuildContext context, List<Widget> items) {
    final cs = Theme.of(context).colorScheme;

    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      out.add(items[i]);
      if (i != items.length - 1) {
        out.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(
              height: 1,
              thickness: 1,
              color: cs.outline.withOpacity(0.12),
            ),
          ),
        );
      }
    }
    return out;
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: cs.onSurface.withOpacity(0.70)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textStyles.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: context.textStyles.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PillChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool emphasized;

  const _PillChip({
    required this.icon,
    required this.label,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final bg = emphasized ? cs.primary.withOpacity(0.14) : cs.surfaceContainerHighest.withOpacity(0.35);
    final border = emphasized ? cs.primary.withOpacity(0.22) : cs.outline.withOpacity(0.14);
    final fg = emphasized ? cs.primary : cs.onSurface.withOpacity(0.75);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: context.textStyles.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                    Model                                   */
/* -------------------------------------------------------------------------- */

class _UserProfile {
  final String firstName;
  final String? middleName;
  final String lastName;
  final String position;
  final bool isAdmin;

  final String email;
  final String phone;

  final String? province;
  final String? city;
  final String? barangay;

  final String? dateHired;
  final int? departmentId;

  final String? imagePath;

  final String? emergencyName;
  final String? emergencyNumber;

  const _UserProfile({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.position,
    required this.isAdmin,
    required this.email,
    required this.phone,
    required this.province,
    required this.city,
    required this.barangay,
    required this.dateHired,
    required this.departmentId,
    required this.imagePath,
    required this.emergencyName,
    required this.emergencyNumber,
  });
}
