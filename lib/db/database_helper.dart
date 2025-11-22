import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('skillhub.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE peserta (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        email TEXT NOT NULL,
        no_telp TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE kelas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_kelas TEXT NOT NULL,
        deskripsi TEXT NOT NULL,
        instruktur TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE pendaftaran (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        peserta_id INTEGER NOT NULL,
        kelas_id INTEGER NOT NULL,
        tanggal_daftar TEXT,
        FOREIGN KEY (peserta_id) REFERENCES peserta (id),
        FOREIGN KEY (kelas_id) REFERENCES kelas (id)
      )
    ''');
  }
}
