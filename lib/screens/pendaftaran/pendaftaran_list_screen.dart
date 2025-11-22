import 'package:flutter/material.dart';
import '../../db/database_helper.dart';
import 'pendaftaran_edit_screen.dart';

class PendaftaranListScreen extends StatefulWidget {
  const PendaftaranListScreen({super.key});

  @override
  State<PendaftaranListScreen> createState() => _PendaftaranListScreenState();
}

class _PendaftaranListScreenState extends State<PendaftaranListScreen> {
  List<Map<String, dynamic>> kelasList = [];
  Map<int, List<Map<String, dynamic>>> pesertaPerKelas = {};
  bool _isLoading = true;
  int _totalPeserta = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => _isLoading = true);

    try {
      final db = await DatabaseHelper.instance.database;

      kelasList = await db.query('kelas', orderBy: 'nama_kelas ASC');

      // Load peserta per kelas
      pesertaPerKelas.clear();
      int total = 0;

      for (var k in kelasList) {
        final list = await db.rawQuery(
          '''
          SELECT pendaftaran.id AS daftar_id,
                 peserta.nama AS peserta_nama,
                 peserta.id AS peserta_id,
                 peserta.email AS peserta_email,
                 peserta.no_telp AS peserta_telepon,
                 pendaftaran.kelas_id AS kelas_id,
                 pendaftaran.tanggal_daftar AS tanggal_daftar,
                 kelas.nama_kelas AS kelas_nama
          FROM pendaftaran
          JOIN peserta ON peserta.id = pendaftaran.peserta_id
          JOIN kelas ON kelas.id = pendaftaran.kelas_id
          WHERE pendaftaran.kelas_id = ?
          ORDER BY peserta.nama ASC
        ''',
          [k['id']],
        );

        pesertaPerKelas[k['id']] = list;
        total += list.length;
      }

      if (mounted) {
        setState(() {
          _totalPeserta = total;
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

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          if (!_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Chip(
                  avatar: const Icon(Icons.people, size: 16),
                  label: Text(
                    '$_totalPeserta Pendaftaran',
                    style: const TextStyle(fontSize: 12),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : kelasList.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: loadData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: kelasList.length,
                itemBuilder: (context, index) {
                  final kelas = kelasList[index];
                  final peserta = pesertaPerKelas[kelas['id']] ?? [];

                  return _buildKelasCard(kelas, peserta);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum ada pendaftaran',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Daftarkan peserta ke kelas untuk melihat data',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildKelasCard(
    Map<String, dynamic> kelas,
    List<Map<String, dynamic>> peserta,
  ) {
    final isEmpty = peserta.isEmpty;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          // FIX: Start expanded so content is visible immediately
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(bottom: 12),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isEmpty
                  ? Colors.grey[200]
                  : Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.school,
              color: isEmpty
                  ? Colors.grey[600]
                  : Theme.of(context).colorScheme.onPrimaryContainer,
              size: 24,
            ),
          ),
          title: Text(
            kelas['nama_kelas'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  kelas['instruktur'] ?? '',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isEmpty ? Colors.grey[300] : Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${peserta.length} peserta',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isEmpty ? Colors.grey[700] : Colors.blue[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
          children: [
            if (isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.person_off_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Belum ada peserta terdaftar',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              )
            else
              ...peserta.map((p) => _buildPesertaItem(p, kelas)),
          ],
        ),
      ),
    );
  }

  Widget _buildPesertaItem(
    Map<String, dynamic> peserta,
    Map<String, dynamic> kelas,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PendaftaranEditScreen(
              daftarId: peserta['daftar_id'] as int,
              pesertaNama: peserta['peserta_nama'] as String,
              kelasNama: kelas['nama_kelas'] as String,
              currentKelasId: peserta['kelas_id'] as int,
              onUpdated: loadData,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: Text(
                peserta['peserta_nama'][0].toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    peserta['peserta_nama'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.email, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          peserta['peserta_email'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (peserta['tanggal_daftar'] != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Terdaftar: ${_formatDate(peserta['tanggal_daftar'])}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
