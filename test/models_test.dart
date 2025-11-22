import 'package:flutter_test/flutter_test.dart';
import 'package:skillshub/models/kelas.dart';
import 'package:skillshub/models/pendaftaran.dart';
import 'dart:io';

import 'package:skillshub/models/peserta.dart';

void main() {
  test('Peserta toJson/fromJson', () {
    final p = Peserta(
      id: 1,
      nama: 'Andi',
      email: 'a@example.com',
      noTelp: '081234',
    );
    final json = p.toJson();
    expect(json['nama'], 'Andi');
    final p2 = Peserta.fromJson({
      'id': 1,
      'nama': 'Andi',
      'email': 'a@example.com',
      'no_telp': '081234',
    });
    expect(p2.email, 'a@example.com');
  });

  test('Kelas toJson/fromJson', () {
    final k = Kelas(
      id: 2,
      namaKelas: 'Flutter',
      deskripsi: 'desc',
      instruktur: 'Budi',
    );
    final json = k.toJson();
    expect(json['nama_kelas'], 'Flutter');
    final k2 = Kelas.fromJson({
      'id': 2,
      'nama_kelas': 'Flutter',
      'deskripsi': 'desc',
      'instruktur': 'Budi',
    });
    expect(k2.instruktur, 'Budi');
  });

  test('Pendaftaran toJson/fromJson', () {
    final d = Pendaftaran(
      id: 3,
      pesertaId: 1,
      kelasId: 2,
      tanggalDaftar: '2025-01-01',
    );
    final json = d.toJson();
    expect(json['peserta_id'], 1);
    final d2 = Pendaftaran.fromJson({
      'id': 3,
      'peserta_id': 1,
      'kelas_id': 2,
      'tanggal_daftar': '2025-01-01',
    });
    expect(d2.kelasId, 2);
  });

  test('Uploaded spec PDF exists', () {
    final path = '/mnt/data/13.a.FR.IA.04A. Penjelasan Singkat Proyek.pdf';
    final f = File(path);
    expect(
      f.existsSync(),
      true,
      reason: 'Project spec PDF must exist at $path',
    );
  });
}
