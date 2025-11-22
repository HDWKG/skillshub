class Peserta {
  int? id;
  String nama;
  String email;
  String? noTelp;

  Peserta({this.id, required this.nama, required this.email, this.noTelp});

  factory Peserta.fromJson(Map<String, dynamic> json) {
    return Peserta(
      id: json['id'],
      nama: json['nama'],
      email: json['email'],
      noTelp: json['no_telp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nama': nama, 'email': email, 'no_telp': noTelp};
  }
}
