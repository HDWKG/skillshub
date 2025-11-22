class Pendaftaran {
  int? id;
  int pesertaId;
  int kelasId;
  String? tanggalDaftar;

  Pendaftaran({
    this.id,
    required this.pesertaId,
    required this.kelasId,
    this.tanggalDaftar,
  });

  factory Pendaftaran.fromJson(Map<String, dynamic> json) {
    return Pendaftaran(
      id: json['id'],
      pesertaId: json['peserta_id'],
      kelasId: json['kelas_id'],
      tanggalDaftar: json['tanggal_daftar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'peserta_id': pesertaId,
      'kelas_id': kelasId,
      'tanggal_daftar': tanggalDaftar,
    };
  }
}
