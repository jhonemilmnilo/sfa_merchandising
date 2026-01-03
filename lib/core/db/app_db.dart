import "dart:async";
import "package:path/path.dart" as p;
import "package:path_provider/path_provider.dart";
import "package:sqflite/sqflite.dart";

class AppDb {
  AppDb._();
  static final AppDb instance = AppDb._();

  static const _dbName = "sfa_merchandising.db";
  static const _dbVersion = 1;

  Database? _db;

  Future<Database> get db async {
    final existing = _db;
    if (existing != null) return existing;

    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);

    final database = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await _createSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // For later migrations
      },
    );

    _db = database;
    return database;
  }

  Future<void> _createSchema(Database db) async {
    // Offline cache for users pulled from: /items/user
    await db.execute("""
      CREATE TABLE users (
        user_id INTEGER PRIMARY KEY,
        user_email TEXT NOT NULL,
        user_password TEXT NOT NULL,  -- prototype only; replace later with token flow
        user_fname TEXT NOT NULL,
        user_mname TEXT NOT NULL,
        user_lname TEXT NOT NULL,
        user_position TEXT NOT NULL,
        user_image TEXT,
        updated_at TEXT,
        synced_at TEXT
      );
    """);

    await db.execute("""
      CREATE INDEX idx_users_email ON users(user_email);
    """);

    // Optional: store who is currently logged-in offline (single-user device mode)
    await db.execute("""
      CREATE TABLE session (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        user_id INTEGER,
        logged_in_at TEXT,
        FOREIGN KEY(user_id) REFERENCES users(user_id)
      );
    """);
  }

  Future<void> close() async {
    final database = _db;
    _db = null;
    if (database != null) await database.close();
  }
}
