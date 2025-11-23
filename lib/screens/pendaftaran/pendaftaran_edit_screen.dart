import 'package:flutter/material.dart';
import '../../db/database_helper.dart';

class PendaftaranEditScreen extends StatefulWidget {
  final int daftarId;
  final String pesertaNama;
  final String kelasNama;
  final int currentKelasId;
  final VoidCallback onUpdated;

  const PendaftaranEditScreen({
    super.key,
    required this.daftarId,
    required this.pesertaNama,
    required this.kelasNama,
    required this.currentKelasId,
    required this.onUpdated,
  });

  @override
  State<PendaftaranEditScreen> createState() => _PendaftaranEditScreenState();
}

class _PendaftaranEditScreenState extends State<PendaftaranEditScreen> {
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> kelasList = [];
  int? selectedKelas;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    selectedKelas = widget.currentKelasId;
    loadKelas();
  }

  Future<void> loadKelas() async {
    try {
      final db = await DatabaseHelper.instance.database;
      kelasList = await db.query('kelas', orderBy: 'nama_kelas ASC');

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memuat kelas: $e")));
    }
  }

  Future<void> saveEdit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedKelas == widget.currentKelasId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pilih kelas baru untuk memindahkan peserta"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final db = await DatabaseHelper.instance.database;

      await db.update(
        "pendaftaran",
        {"kelas_id": selectedKelas},
        where: "id = ?",
        whereArgs: [widget.daftarId],
      );

      widget.onUpdated();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pendaftaran berhasil diperbarui"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memperbarui: $e")));
    }
  }

  Future<void> deleteDaftar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: Text(
          'Hapus pendaftaran "${widget.pesertaNama}" dari kelas "${widget.kelasNama}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final db = await DatabaseHelper.instance.database;

      await db.delete(
        "pendaftaran",
        where: "id = ?",
        whereArgs: [widget.daftarId],
      );

      widget.onUpdated();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pendaftaran berhasil dihapus"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menghapus: $e")));
    }
  }

  String? _kelasInfo(int? id) {
    try {
      final m = kelasList.firstWhere((k) => k["id"] == id);
      return "Instruktur: ${m['instruktur']}";
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 40,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Peserta",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.pesertaNama,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Kelas saat ini",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.kelasNama,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        "Pindah ke Kelas",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),

                      DropdownButtonFormField<int>(
                        initialValue: selectedKelas,
                        items: kelasList.map((k) {
                          return DropdownMenuItem<int>(
                            value: k['id'] as int,
                            child: Text(k['nama_kelas']),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => selectedKelas = v),
                        validator: (v) => v == null ? "Pilih kelas" : null,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.swap_horiz),
                        ),
                      ),

                      if (selectedKelas != null &&
                          selectedKelas != widget.currentKelasId)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            _kelasInfo(selectedKelas) ?? "",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[900],
                            ),
                          ),
                        ),

                      const SizedBox(height: 32),

                      FilledButton.icon(
                        onPressed: _isSaving ? null : saveEdit,
                        icon: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          _isSaving ? "Menyimpan..." : "Simpan Perubahan",
                        ),
                      ),

                      const SizedBox(height: 14),

                      OutlinedButton.icon(
                        onPressed: _isSaving ? null : deleteDaftar,
                        icon: const Icon(Icons.delete),
                        label: const Text("Hapus Pendaftaran"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextButton(
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text("Batal"),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
