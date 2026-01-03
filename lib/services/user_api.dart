import "dart:convert";
import "package:http/http.dart" as http;

import "../models/app_user.dart";
import "api_config.dart";

class UserApi {
  const UserApi();

  /// Fetch all users (useful for initial sync / caching).
  /// Expected response: { "data": [ {..user..}, ... ] }
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
        .map((e) => AppUser.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Fetch one user by email (recommended for login online-first).
  /// This assumes your backend supports filtering via query params.
  ///
  /// If your backend does NOT support this filter syntax, tell me what query
  /// format it expects and I’ll adjust it.
  Future<AppUser?> fetchUserByEmail(String email) async {
    final safeEmail = email.trim();

    // Common "items" filter styles:
    // Option A (Directus-like): ?filter[user_email][_eq]=...
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

  /// Online auth (prototype): fetch user by email then compare password.
  /// Later: replace with server-side auth/token.
  Future<AppUser?> authenticateOnline({
    required String email,
    required String password,
  }) async {
    final user = await fetchUserByEmail(email);
    if (user == null) return null;

    // Prototype only: plaintext compare
    if (user.password != password) return null;

    return user;
  }
}
