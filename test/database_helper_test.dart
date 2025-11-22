import 'package:flutter_test/flutter_test.dart';
import 'package:skillshub/db/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    // Initialize ffi implementation for tests running on host
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('Create DB and insert peserta/kelas/pendaftaran', () async {
    final db = await DatabaseHelper.instance.database;

    // Clean tables in case previous run left data
    await db.delete('pendaftaran');
    await db.delete('peserta');
    await db.delete('kelas');

    final pesertaId = await db.insert('peserta', {
      'nama': 'Test A',
      'email': 't@example.com',
      'no_telp': '',
    });
    final kelasId = await db.insert('kelas', {
      'nama_kelas': 'Test Kelas',
      'deskripsi': 'd',
      'instruktur': 'I',
    });

    expect(pesertaId, isNonZero);
    expect(kelasId, isNonZero);

    final daftarId = await db.insert('pendaftaran', {
      'peserta_id': pesertaId,
      'kelas_id': kelasId,
      'tanggal_daftar': DateTime.now().toIso8601String(),
    });

    final rows = await db.query('pendaftaran');
    expect(rows.length, 1);
    expect(rows.first['id'], daftarId);

    // update
    await db.update(
      'peserta',
      {'nama': 'Test A 2', 'email': 't2@example.com', 'no_telp': ''},
      where: 'id = ?',
      whereArgs: [pesertaId],
    );
    final p = await db.query(
      'peserta',
      where: 'id = ?',
      whereArgs: [pesertaId],
    );
    expect(p.first['nama'], 'Test A 2');

    // delete
    await db.delete('pendaftaran', where: 'id = ?', whereArgs: [daftarId]);
    final after = await db.query('pendaftaran');
    expect(after, isEmpty);
  });
}
