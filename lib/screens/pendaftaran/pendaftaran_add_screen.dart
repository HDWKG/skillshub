import 'package:flutter/material.dart';
import '../../db/database_helper.dart';

class PendaftaranAddScreen extends StatefulWidget {
  const PendaftaranAddScreen({super.key});

  @override
  State<PendaftaranAddScreen> createState() => _PendaftaranAddScreenState();
}

class _PendaftaranAddScreenState extends State<PendaftaranAddScreen> {
  List<Map<String, dynamic>> pesertaList = [];
  List<Map<String, dynamic>> kelasList = [];

  int? selectedPeserta;
  int? selectedKelas;

  bool _isLoading = true;
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => _isLoading = true);
    try {
      final db = await DatabaseHelper.instance.database;
      final peserta = await db.query('peserta', orderBy: 'nama ASC');
      final kelas = await db.query('kelas', orderBy: 'nama_kelas ASC');

      if (mounted) {
        setState(() {
          pesertaList = peserta;
          kelasList = kelas;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> daftar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final db = await DatabaseHelper.instance.database;

      // Check for duplicate registration
      final existing = await db.query(
        'pendaftaran',
        where: 'peserta_id = ? AND kelas_id = ?',
        whereArgs: [selectedPeserta, selectedKelas],
      );

      if (existing.isNotEmpty) {
        if (!mounted) return;
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Peserta sudah terdaftar di kelas ini'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      await db.insert('pendaftaran', {
        'peserta_id': selectedPeserta,
        'kelas_id': selectedKelas,
        'tanggal_daftar': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pendaftaran berhasil ditambahkan'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mendaftarkan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String? _getSelectedPesertaInfo() {
    if (selectedPeserta == null) return null;
    final peserta = pesertaList.firstWhere((p) => p['id'] == selectedPeserta);
    return '${peserta['email']} • ${peserta['telepon']}';
  }

  String? _getSelectedKelasInfo() {
    if (selectedKelas == null) return null;
    final kelas = kelasList.firstWhere((k) => k['id'] == selectedKelas);
    return 'Instruktur: ${kelas['instruktur']}';
  }

  // ... (rest of the code remains the same)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : pesertaList.isEmpty || kelasList.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Pilih Peserta
                      DropdownButtonFormField<int>(
                        value: selectedPeserta,
                        decoration: InputDecoration(
                          labelText: "Pilih Peserta",
                          hintText: "Pilih peserta yang akan didaftarkan",
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withOpacity(0.3),
                        ),
                        items: pesertaList
                            .map(
                              (p) => DropdownMenuItem<int>(
                                value: p['id'],
                                // --- SIMPLIFIED CONTENT ---
                                child: Text(
                                  p['nama'], // ONLY display the name
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                // --------------------------
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => selectedPeserta = v),
                        validator: (value) {
                          if (value == null) {
                            return 'Peserta harus dipilih';
                          }
                          return null;
                        },
                      ),

                      if (selectedPeserta != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.blue[700],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _getSelectedPesertaInfo() ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[900],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Pilih Kelas
                      DropdownButtonFormField<int>(
                        value: selectedKelas,
                        decoration: InputDecoration(
                          labelText: "Pilih Kelas",
                          hintText: "Pilih kelas yang akan diikuti",
                          prefixIcon: const Icon(Icons.school),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withOpacity(0.3),
                        ),
                        items: kelasList
                            .map(
                              (k) => DropdownMenuItem<int>(
                                value: k['id'],
                                // --- SIMPLIFIED CONTENT ---
                                child: Text(
                                  k['nama_kelas'], // ONLY display the class name
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                // --------------------------
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => selectedKelas = v),
                        validator: (value) {
                          if (value == null) {
                            return 'Kelas harus dipilih';
                          }
                          return null;
                        },
                      ),

                      if (selectedKelas != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.green[700],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _getSelectedKelasInfo() ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green[900],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Daftarkan Button
                      FilledButton.icon(
                        onPressed: _isSaving ? null : daftar,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_circle),
                        label: Text(
                          _isSaving ? 'Mendaftarkan...' : 'Daftarkan',
                        ),
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
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.pop(context),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              pesertaList.isEmpty ? Icons.person_off : Icons.school_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              pesertaList.isEmpty ? 'Belum ada peserta' : 'Belum ada kelas',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              pesertaList.isEmpty
                  ? 'Tambahkan peserta terlebih dahulu sebelum melakukan pendaftaran'
                  : 'Tambahkan kelas terlebih dahulu sebelum melakukan pendaftaran',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}
