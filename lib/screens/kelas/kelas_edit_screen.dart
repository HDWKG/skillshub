import 'package:flutter/material.dart';
import '../../db/database_helper.dart';

class KelasEditScreen extends StatefulWidget {
  final Map<String, dynamic> kelasData;
  final VoidCallback onUpdated;

  const KelasEditScreen({
    super.key,
    required this.kelasData,
    required this.onUpdated,
  });

  @override
  State<KelasEditScreen> createState() => _KelasEditScreenState();
}

class _KelasEditScreenState extends State<KelasEditScreen> {
  late TextEditingController namaC;
  late TextEditingController deskripsiC;
  late TextEditingController instrukturC;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    namaC = TextEditingController(text: widget.kelasData['nama_kelas']);
    deskripsiC = TextEditingController(text: widget.kelasData['deskripsi']);
    instrukturC = TextEditingController(text: widget.kelasData['instruktur']);
  }

  @override
  void dispose() {
    namaC.dispose();
    deskripsiC.dispose();
    instrukturC.dispose();
    super.dispose();
  }

  Future<void> saveEdit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final db = await DatabaseHelper.instance.database;

      await db.update(
        'kelas',
        {
          'nama_kelas': namaC.text.trim(),
          'deskripsi': deskripsiC.text.trim(),
          'instruktur': instrukturC.text.trim(),
        },
        where: 'id = ?',
        whereArgs: [widget.kelasData['id']],
      );

      widget.onUpdated();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kelas berhasil diperbarui'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui kelas: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: namaC,
                  decoration: InputDecoration(
                    labelText: "Nama Kelas",
                    hintText: "Masukkan nama kelas",
                    prefixIcon: const Icon(Icons.school),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama kelas harus diisi';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),

                const SizedBox(height: 16),

                // Deskripsi Field
                TextFormField(
                  controller: deskripsiC,
                  decoration: InputDecoration(
                    labelText: "Deskripsi",
                    hintText: "Masukkan deskripsi kelas",
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Deskripsi harus diisi';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.sentences,
                ),

                const SizedBox(height: 16),

                // Instruktur Field
                TextFormField(
                  controller: instrukturC,
                  decoration: InputDecoration(
                    labelText: "Instruktur",
                    hintText: "Masukkan nama instruktur",
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Instruktur harus diisi';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),

                const SizedBox(height: 32),

                // Save Button
                FilledButton.icon(
                  onPressed: _isLoading ? null : saveEdit,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isLoading ? 'Menyimpan...' : 'Simpan Perubahan'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Cancel Button
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Batal'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
