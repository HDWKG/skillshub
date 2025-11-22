// test/database_helper_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:skillshub/db/database_helper.dart'; // adjust if path differs

void main() {
  // Database filename used by your DatabaseHelper
  const dbFileName = 'skillhub.db';

  setUpAll(() {
    // Initialize ffi implementation
    sqfliteFfiInit();
    // Tell sqflite to use the ffi factory (so getDatabasesPath/openDatabase work on the VM)
    databaseFactory = databaseFactoryFfi;
  });

  tearDownAll(() async {
    // Remove test DB file if it exists
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbFileName);
    if (await File(path).exists()) {
      await deleteDatabase(path);
    }
  });

  group('DatabaseHelper unit tests', () {
    test('Peserta CRUD', () async {
      final db = await DatabaseHelper.instance.database;

      // INSERT Peserta
      final peserta = {
        'nama': 'Test Peserta',
        'email': 'test@example.com',
        'no_telp': '08123456789',
      };
      final pesertaId = await db.insert('peserta', peserta);
      expect(pesertaId, isNonZero);

      // READ Peserta
      final fetched = await db.query(
        'peserta',
        where: 'id = ?',
        whereArgs: [pesertaId],
      );
      expect(fetched.length, 1);
      expect(fetched.first['nama'], 'Test Peserta');
      expect(fetched.first['email'], 'test@example.com');

      // UPDATE Peserta
      final updatedCount = await db.update(
        'peserta',
        {
          'nama': 'Updated Peserta',
          'email': 'upd@example.com',
          'no_telp': '0810000',
        },
        where: 'id = ?',
        whereArgs: [pesertaId],
      );
      expect(updatedCount, 1);

      final fetchedAfterUpdate = await db.query(
        'peserta',
        where: 'id = ?',
        whereArgs: [pesertaId],
      );
      expect(fetchedAfterUpdate.first['nama'], 'Updated Peserta');

      // DELETE Peserta
      final deletedCount = await db.delete(
        'peserta',
        where: 'id = ?',
        whereArgs: [pesertaId],
      );
      expect(deletedCount, 1);

      final afterDelete = await db.query(
        'peserta',
        where: 'id = ?',
        whereArgs: [pesertaId],
      );
      expect(afterDelete, isEmpty);
    });

    test('Kelas CRUD', () async {
      final db = await DatabaseHelper.instance.database;

      // INSERT Kelas
      final kelas = {
        'nama_kelas': 'Test Kelas',
        'deskripsi': 'Deskripsi test',
        'instruktur': 'Instruktur A',
      };
      final kelasId = await db.insert('kelas', kelas);
      expect(kelasId, isNonZero);

      // READ Kelas
      final fetched = await db.query(
        'kelas',
        where: 'id = ?',
        whereArgs: [kelasId],
      );
      expect(fetched.length, 1);
      expect(fetched.first['nama_kelas'], 'Test Kelas');

      // UPDATE Kelas
      final updatedCount = await db.update(
        'kelas',
        {
          'nama_kelas': 'Updated Kelas',
          'deskripsi': 'desc upd',
          'instruktur': 'Instruktur B',
        },
        where: 'id = ?',
        whereArgs: [kelasId],
      );
      expect(updatedCount, 1);

      final afterUpdate = await db.query(
        'kelas',
        where: 'id = ?',
        whereArgs: [kelasId],
      );
      expect(afterUpdate.first['nama_kelas'], 'Updated Kelas');

      // DELETE Kelas
      final deletedCount = await db.delete(
        'kelas',
        where: 'id = ?',
        whereArgs: [kelasId],
      );
      expect(deletedCount, 1);

      final afterDelete = await db.query(
        'kelas',
        where: 'id = ?',
        whereArgs: [kelasId],
      );
      expect(afterDelete, isEmpty);
    });

    test('Pendaftaran (relationship) CRUD', () async {
      final db = await DatabaseHelper.instance.database;

      // Create Peserta
      final peserta = {
        'nama': 'Pendaftar',
        'email': 'pendaftar@example.com',
        'no_telp': '08999',
      };
      final pesertaId = await db.insert('peserta', peserta);
      expect(pesertaId, isNonZero);

      // Create Kelas
      final kelas = {
        'nama_kelas': 'Kelas Untuk Pendaftaran',
        'deskripsi': 'desc',
        'instruktur': 'Guru',
      };
      final kelasId = await db.insert('kelas', kelas);
      expect(kelasId, isNonZero);

      // Insert Pendaftaran
      final now = DateTime.now().toIso8601String();
      final pendaftaran = {
        'peserta_id': pesertaId,
        'kelas_id': kelasId,
        'tanggal_daftar': now,
      };
      final pendaftaranId = await db.insert('pendaftaran', pendaftaran);
      expect(pendaftaranId, isNonZero);

      // Verify pendaftaran exists and references correct peserta/kelas
      final fetched = await db.query(
        'pendaftaran',
        where: 'id = ?',
        whereArgs: [pendaftaranId],
      );
      expect(fetched.length, 1);
      expect(fetched.first['peserta_id'], pesertaId);
      expect(fetched.first['kelas_id'], kelasId);

      // Query participants of kelas
      final pesertaOfKelas = await db.rawQuery(
        'SELECT p.* FROM peserta p JOIN pendaftaran d ON p.id = d.peserta_id WHERE d.kelas_id = ?',
        [kelasId],
      );
      expect(pesertaOfKelas.length, 1);
      expect(pesertaOfKelas.first['nama'], 'Pendaftar');

      // Query classes of peserta
      final kelasOfPeserta = await db.rawQuery(
        'SELECT k.* FROM kelas k JOIN pendaftaran d ON k.id = d.kelas_id WHERE d.peserta_id = ?',
        [pesertaId],
      );
      expect(kelasOfPeserta.length, 1);
      expect(kelasOfPeserta.first['nama_kelas'], 'Kelas Untuk Pendaftaran');

      // Delete pendaftaran
      final deletedCount = await db.delete(
        'pendaftaran',
        where: 'id = ?',
        whereArgs: [pendaftaranId],
      );
      expect(deletedCount, 1);

      final afterDelete = await db.query(
        'pendaftaran',
        where: 'id = ?',
        whereArgs: [pendaftaranId],
      );
      expect(afterDelete, isEmpty);

      // Clean up peserta & kelas
      await db.delete('peserta', where: 'id = ?', whereArgs: [pesertaId]);
      await db.delete('kelas', where: 'id = ?', whereArgs: [kelasId]);
    });
  });
}
