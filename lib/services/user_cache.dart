import "dart:convert";
import "package:shared_preferences/shared_preferences.dart";

import "../models/app_user.dart";

class UserCache {
  static const _kUsersKey = "cached_users_v1";
  static const _kUsersUpdatedAtKey = "cached_users_updated_at_v1";

  Future<void> saveUsers(List<AppUser> users) async {
    final prefs = await SharedPreferences.getInstance();

    // Store as JSON string
    final payload = jsonEncode(users.map((u) => u.toJson()).toList());

    await prefs.setString(_kUsersKey, payload);
    await prefs.setString(_kUsersUpdatedAtKey, DateTime.now().toIso8601String());
  }

  Future<List<AppUser>> loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUsersKey);

    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(AppUser.fromJson)
        .toList();
  }

  Future<String?> lastUpdatedAt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUsersUpdatedAtKey);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUsersKey);
    await prefs.remove(_kUsersUpdatedAtKey);
  }
}
