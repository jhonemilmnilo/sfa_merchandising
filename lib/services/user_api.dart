// lib/services/user_api.dart
// Talks to Directus REST endpoints under /items
// Supports:
// 1) Fetch all users (for initial cache/sync)
// 2) Fetch one user by email (Directus filter)
// 3) Fetch one user by user_id (Directus single-item endpoint)
// 4) Prototype online authentication (email + plaintext password compare)

import "dart:convert"; // jsonDecode for parsing Directus responses
import "package:http/http.dart" as http; // HTTP client

import "../models/app_user.dart"; // AppUser model mapping
import "api_config.dart"; // Centralized Directus endpoints

class UserApi {
  const UserApi();

  // For server queries, do NOT force lowercase to avoid mismatches if DB collation is case-sensitive.
  // We only trim to remove accidental spaces from user input.
  static String _safeEmailQuery(String v) => v.trim();

  // Fields to request from Directus (keep payload small + predictable).
  // IMPORTANT: if Directus permissions hide user_password, online auth will fail (prototype behavior).
  static const String _userFields =
      "user_id,user_email,user_password,user_fname,user_mname,user_lname,"
      "user_position,user_image,user_contact,user_province,user_city,user_brgy,"
      "user_dateOfHire,user_department,isAdmin";

  // Common headers for Directus reads.
  static const Map<String, String> _headers = {
    "Accept": "application/json",
  };

  /// Fetch all users (useful for initial sync/caching).
  /// Directus collection read response:
  /// { "data": [ {...}, {...} ] }
  Future<List<AppUser>> fetchUsers() async {
    final uri = Uri.parse(ApiConfig.users()).replace(
      queryParameters: {
        "fields": _userFields,
        // Optional: set a sane limit; adjust if you expect more users.
        // "limit": "500",
      },
    );

    final res = await http.get(uri, headers: _headers);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Failed to fetch users. HTTP ${res.statusCode}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception("Invalid response format: expected JSON object.");
    }

    final data = decoded["data"];
    if (data is! List) {
      throw Exception("Invalid response format: expected data[] list.");
    }

    return data
        .whereType<Map>()
        .map((e) => AppUser.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Fetch one user by email using Directus filter syntax.
  /// Directus collection read response:
  /// { "data": [ {...} ] }
  Future<AppUser?> fetchUserByEmail(String email) async {
    final safeEmail = _safeEmailQuery(email);

    final uri = Uri.parse(ApiConfig.users()).replace(
      queryParameters: {
        "filter[user_email][_eq]": safeEmail,
        "limit": "1",
        "fields": _userFields,
      },
    );

    final res = await http.get(uri, headers: _headers);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Failed to fetch user by email. HTTP ${res.statusCode}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception("Invalid response format: expected JSON object.");
    }

    final data = decoded["data"];
    if (data is! List) {
      throw Exception("Invalid response format: expected data[] list.");
    }

    if (data.isEmpty) return null;

    final first = Map<String, dynamic>.from(data.first as Map);
    return AppUser.fromJson(first);
  }

  /// Fetch one user by user_id using Directus single-item endpoint:
  /// GET /items/user/{id}
  ///
  /// Directus single read response:
  /// { "data": { ...user... } }
  Future<AppUser?> fetchUserById(int userId) async {
    final uri = Uri.parse(ApiConfig.userById(userId)).replace(
      queryParameters: {
        "fields": _userFields,
      },
    );

    final res = await http.get(uri, headers: _headers);

    if (res.statusCode == 404) {
      // Not found is a valid "no user" outcome for profile refresh.
      return null;
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Failed to fetch user by id. HTTP ${res.statusCode}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception("Invalid response format: expected JSON object.");
    }

    final data = decoded["data"];
    if (data is! Map) {
      // Single-item reads return an object, not a list.
      throw Exception("Invalid response format: expected data{} object.");
    }

    return AppUser.fromJson(Map<String, dynamic>.from(data));
  }

  /// Online authentication (prototype):
  /// - Fetch user by email (online)
  /// - Compare plaintext password
  ///
  /// NOTE: This is prototype only. Replace with token-based auth later.
  Future<AppUser?> authenticateOnline({
    required String email,
    required String password,
  }) async {
    final safeEmail = _safeEmailQuery(email);
    final safePassword = password.trim();

    final user = await fetchUserByEmail(safeEmail);
    if (user == null) return null;

    // If Directus permissions do not return user_password, user.password may be empty.
    // In that case, online auth will not work (by design in this prototype).
    if (user.password.trim() != safePassword) return null;

    return user;
  }
}
