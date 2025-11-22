class Kelas {
  int? id;
  String namaKelas;
  String deskripsi;
  String instruktur;

  Kelas({
    this.id,
    required this.namaKelas,
    required this.deskripsi,
    required this.instruktur,
  });

  factory Kelas.fromJson(Map<String, dynamic> json) {
    return Kelas(
      id: json['id'],
      namaKelas: json['nama_kelas'],
      deskripsi: json['deskripsi'],
      instruktur: json['instruktur'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_kelas': namaKelas,
      'deskripsi': deskripsi,
      'instruktur': instruktur,
    };
  }
}
