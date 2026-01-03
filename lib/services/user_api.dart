import "dart:convert";
import "package:http/http.dart" as http;

import "../models/app_user.dart";
import "api_config.dart";

class UserApi {
  const UserApi();

  static String _normEmail(String v) => v.trim().toLowerCase();

  /// Fetch all users (useful for initial sync/caching).
  /// Directus response: { "data": [ ... ] }
  Future<List<AppUser>> fetchUsers() async {
    final uri = Uri.parse(ApiConfig.users());

    final res = await http.get(
      uri,
      headers: const {"Accept": "application/json"},
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Failed to fetch users. HTTP ${res.statusCode}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception("Invalid response format: expected JSON object.");
    }

    final data = decoded["data"];
    if (data is! List) {
      throw Exception("Invalid response format: missing data[]");
    }

    return data
        .whereType<Map>()
        .map((e) => AppUser.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Fetch one user by email (Directus filter).
  Future<AppUser?> fetchUserByEmail(String email) async {
    final safeEmail = email.trim();

    final uri = Uri.parse(ApiConfig.users()).replace(queryParameters: {
      "filter[user_email][_eq]": safeEmail,
      "limit": "1",
    });

    final res = await http.get(
      uri,
      headers: const {"Accept": "application/json"},
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Failed to fetch user. HTTP ${res.statusCode}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception("Invalid response format: expected JSON object.");
    }

    final data = decoded["data"];
    if (data is! List) {
      throw Exception("Invalid response format: missing data[]");
    }

    if (data.isEmpty) return null;

    final first = Map<String, dynamic>.from(data.first as Map);
    return AppUser.fromJson(first);
  }

  /// Online auth (prototype): fetch by email, then compare password.
  /// Later replace with Directus Auth / token-based login.
  Future<AppUser?> authenticateOnline({
    required String email,
    required String password,
  }) async {
    final e = _normEmail(email);
    final p = password.trim();

    final user = await fetchUserByEmail(e);
    if (user == null) return null;

    // Prototype only: plaintext compare
    if (user.password.trim() != p) return null;

    return user;
  }
}
