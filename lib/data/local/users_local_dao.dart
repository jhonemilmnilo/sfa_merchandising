import "package:sqflite/sqflite.dart";
import "../app_db.dart";
import "../../models/app_user.dart";

class UsersLocalDao {
  UsersLocalDao._();
  static final UsersLocalDao instance = UsersLocalDao._();

  Future<Database> get _db async => AppDb.instance.db;

  String _normEmail(String email) => email.trim().toLowerCase();

  /// Cache (insert/update) a user row locally.
  Future<void> upsertUser(AppUser user) async {
    final db = await _db;

    await db.insert(
      "users",
      {
        ...user.toJson(),
        "user_email": _normEmail(user.email),
        "updated_at": DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Bulk cache users (useful after a successful online fetch).
  Future<void> upsertUsers(List<AppUser> users) async {
    final db = await _db;

    await db.transaction((txn) async {
      final batch = txn.batch();

      final now = DateTime.now().toIso8601String();
      for (final u in users) {
        batch.insert(
          "users",
          {
            ...u.toJson(),
            "user_email": _normEmail(u.email),
            "updated_at": now,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    });
  }

  /// Fetch cached user by email.
  Future<AppUser?> getByEmail(String email) async {
    final db = await _db;

    final rows = await db.query(
      "users",
      where: "user_email = ?",
      whereArgs: [_normEmail(email)],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return AppUser.fromJson(rows.first);
  }

  /// Offline login check (prototype): email + password must match cached row.
  Future<AppUser?> authenticateOffline({
    required String email,
    required String password,
  }) async {
    final db = await _db;

    final rows = await db.query(
      "users",
      where: "user_email = ? AND user_password = ?",
      whereArgs: [_normEmail(email), password],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return AppUser.fromJson(rows.first);
  }

  /// Optional: clear user cache (e.g., on logout)
  Future<void> clearUsers() async {
    final db = await _db;
    await db.delete("users");
  }
}
