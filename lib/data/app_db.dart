import "package:path/path.dart" as p;
import "package:sqflite/sqflite.dart";

class AppDb {
  AppDb._();
  static final AppDb instance = AppDb._();

  Database? _db;

  Future<Database> get db async {
    final existing = _db;
    if (existing != null) return existing;

    final dbPath = await getDatabasesPath();
    final filePath = p.join(dbPath, "sfa_merchandising.db");

    final opened = await openDatabase(
      filePath,
      version: 1,
      onCreate: (Database db, int version) async {
        // Users cache (offline-first use: login fallback + profile rendering)
        await db.execute("""
          CREATE TABLE IF NOT EXISTS users (
            user_id INTEGER PRIMARY KEY,
            user_email TEXT NOT NULL UNIQUE,
            user_password TEXT NOT NULL,          -- prototype only (later token/hash)
            user_fname TEXT NOT NULL,
            user_mname TEXT NOT NULL DEFAULT '',
            user_lname TEXT NOT NULL,
            user_position TEXT NOT NULL DEFAULT '',
            is_admin INTEGER NOT NULL DEFAULT 0,  -- 0/1
            user_contact TEXT,
            user_province TEXT,
            user_city TEXT,
            user_brgy TEXT,
            user_dateOfHire TEXT,
            user_department INTEGER,
            user_image TEXT,
            updated_at TEXT                       -- cache timestamp
          );
        """);

        await db.execute("""
          CREATE INDEX IF NOT EXISTS idx_users_email ON users(user_email);
        """);
      },
    );

    _db = opened;
    return opened;
  }
}
