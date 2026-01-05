// lib/models/app_user.dart
//
// Canonical User model for the app.
//
// Goals:
// - Works with Directus payload keys (snake_case like user_email, user_fname, etc.)
// - Safe for SQLite inserts based on your CURRENT AppDb schema:
//
//   CREATE TABLE users (
//     user_id INTEGER PRIMARY KEY,
//     user_email TEXT NOT NULL,
//     user_password TEXT NOT NULL,
//     user_fname TEXT NOT NULL,
//     user_mname TEXT NOT NULL,
//     user_lname TEXT NOT NULL,
//     user_position TEXT NOT NULL,
//     user_image TEXT,
//     updated_at TEXT
//   );
//
// IMPORTANT:
// - Do NOT include extra columns in toJson() unless your SQLite table has them,
//   because sqflite INSERT will fail if you pass unknown columns.
// - We still PARSE extra fields from Directus (contact, address, etc.) so they
//   are available in-memory (session/profile) when online.

class AppUser {
  // -----------------------------
  // Core fields (in both Directus + SQLite table)
  // -----------------------------
  final int userId;
  final String email;
  final String password;
  final String firstName;
  final String middleName;
  final String lastName;
  final String position;
  final String? imagePath;

  // -----------------------------
  // Extra fields (present in Directus; NOT stored in your current SQLite table)
  // -----------------------------
  final bool? isAdmin;
  final String? contact;
  final String? province;
  final String? city;
  final String? barangay;
  final String? dateHired; // usually "YYYY-MM-DD"
  final int? departmentId;

  // Local cache metadata (SQLite column exists, but DAO usually sets this)
  final String? updatedAt;

  const AppUser({
    required this.userId,
    required this.email,
    required this.password,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.position,
    this.imagePath,
    this.isAdmin,
    this.contact,
    this.province,
    this.city,
    this.barangay,
    this.dateHired,
    this.departmentId,
    this.updatedAt,
  });

  // -----------------------------
  // Convenience
  // -----------------------------
  String get fullName {
    final mid = middleName.trim().isEmpty ? "" : " ${middleName.trim()}";
    return "${firstName.trim()}$mid ${lastName.trim()}"
        .replaceAll(RegExp(r"\s+"), " ")
        .trim();
  }

  // -----------------------------
  // JSON parsing
  // -----------------------------
  factory AppUser.fromJson(Map<String, dynamic> json) {
    // Helper: pull string safely
    String _s(dynamic v, {String fallback = ""}) {
      if (v == null) return fallback;
      return v.toString();
    }

    // Helper: parse int safely
    int _i(dynamic v, {int fallback = 0}) {
      if (v == null) return fallback;
      if (v is int) return v;
      if (v is double) return v.toInt();
      final parsed = int.tryParse(v.toString());
      return parsed ?? fallback;
    }

    // Helper: parse optional int safely
    int? _iOpt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is double) return v.toInt();
      return int.tryParse(v.toString());
    }

    // Helper: parse bool safely (Directus usually returns bool)
    bool? _bOpt(dynamic v) {
      if (v == null) return null;
      if (v is bool) return v;
      if (v is int) return v != 0;
      final s = v.toString().trim().toLowerCase();
      if (s == "true" || s == "1" || s == "yes") return true;
      if (s == "false" || s == "0" || s == "no") return false;
      return null;
    }

    // Support alternative id keys just in case (Directus customizations / local cache)
    final id = json.containsKey("user_id")
        ? _i(json["user_id"])
        : json.containsKey("userId")
            ? _i(json["userId"])
            : json.containsKey("id")
                ? _i(json["id"])
                : 0;

    // Email keys
    final email = json.containsKey("user_email")
        ? _s(json["user_email"])
        : json.containsKey("email")
            ? _s(json["email"])
            : "";

    // Password keys (prototype)
    final password = json.containsKey("user_password")
        ? _s(json["user_password"])
        : json.containsKey("password")
            ? _s(json["password"])
            : "";

    // Name keys
    final fname = _s(json["user_fname"] ?? json["first_name"] ?? json["firstName"]);
    final mname = _s(json["user_mname"] ?? json["middle_name"] ?? json["middleName"], fallback: "");
    final lname = _s(json["user_lname"] ?? json["last_name"] ?? json["lastName"]);

    // Position keys
    final position = _s(json["user_position"] ?? json["position"], fallback: "");

    // Image path keys
    final imagePath = (json["user_image"] ?? json["imagePath"] ?? json["image"])?.toString();

    // Extra fields from Directus
    final isAdmin = _bOpt(json["isAdmin"] ?? json["is_admin"]);
    final contact = (json["user_contact"] ?? json["phone"] ?? json["contact"])?.toString();
    final province = (json["user_province"] ?? json["province"])?.toString();
    final city = (json["user_city"] ?? json["city"])?.toString();
    final barangay = (json["user_brgy"] ?? json["barangay"])?.toString();
    final dateHired = (json["user_dateOfHire"] ?? json["dateHired"] ?? json["date_hired"])?.toString();
    final deptId = _iOpt(json["user_department"] ?? json["departmentId"] ?? json["department_id"]);

    // Local metadata
    final updatedAt = (json["updated_at"] ?? json["updateAt"] ?? json["updatedAt"])?.toString();

    return AppUser(
      userId: id,
      email: email,
      password: password,
      firstName: fname,
      middleName: mname,
      lastName: lname,
      position: position,
      imagePath: imagePath,
      isAdmin: isAdmin,
      contact: contact,
      province: province,
      city: city,
      barangay: barangay,
      dateHired: dateHired,
      departmentId: deptId,
      updatedAt: updatedAt,
    );
  }

  // -----------------------------
  // SQLite-safe JSON
  // -----------------------------
  //
  // This MUST match your current SQLite schema columns exactly.
  // Your DAO adds "updated_at" itself, so we do not include it here by default.
  //
  Map<String, Object?> toJson() {
    return <String, Object?>{
      "user_id": userId,
      "user_email": email,
      "user_password": password,
      "user_fname": firstName,
      "user_mname": middleName,
      "user_lname": lastName,
      "user_position": position,
      "user_image": imagePath,
      // NOTE: updated_at is intentionally excluded; DAO sets it.
    };
  }

  // If you later expand SQLite schema, you can start using this for caching.
  // Do NOT use this with your current DAO unless you add the columns to SQLite.
  Map<String, Object?> toExpandedDbJson() {
    return <String, Object?>{
      ...toJson(),
      "is_admin": (isAdmin ?? false) ? 1 : 0,
      "user_contact": contact,
      "user_province": province,
      "user_city": city,
      "user_brgy": barangay,
      "user_dateOfHire": dateHired,
      "user_department": departmentId,
      "updated_at": updatedAt,
    };
  }

  // -----------------------------
  // Copy helper
  // -----------------------------
  AppUser copyWith({
    int? userId,
    String? email,
    String? password,
    String? firstName,
    String? middleName,
    String? lastName,
    String? position,
    String? imagePath,
    bool? isAdmin,
    String? contact,
    String? province,
    String? city,
    String? barangay,
    String? dateHired,
    int? departmentId,
    String? updatedAt,
  }) {
    return AppUser(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      password: password ?? this.password,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      position: position ?? this.position,
      imagePath: imagePath ?? this.imagePath,
      isAdmin: isAdmin ?? this.isAdmin,
      contact: contact ?? this.contact,
      province: province ?? this.province,
      city: city ?? this.city,
      barangay: barangay ?? this.barangay,
      dateHired: dateHired ?? this.dateHired,
      departmentId: departmentId ?? this.departmentId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
