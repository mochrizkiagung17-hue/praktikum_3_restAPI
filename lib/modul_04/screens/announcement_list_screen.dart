import 'package:flutter/material.dart';

import '../models/announcement.dart';
import '../services/announcement_api.dart';
import '../widgets/announcement_card.dart';
import 'announcement_detail_screen.dart';

class AnnouncementListScreen extends StatefulWidget {
  const AnnouncementListScreen({
    super.key,
    this.api,
  });

  final AnnouncementApi? api;

  @override
  State<AnnouncementListScreen> createState() =>
      _AnnouncementListScreenState();
}

class _AnnouncementListScreenState
    extends State<AnnouncementListScreen> {
  static const List<String> kategori = [
    'Semua',
    'Akademik',
    'Beasiswa',
    'Kegiatan',
    'Prestasi',
  ];

  late final AnnouncementApi _api =
      widget.api ?? AnnouncementApi();

  late Future<List<Announcement>>
      _futurePengumuman;

  String _kategoriTerpilih = 'Semua';

  @override
  void initState() {
    super.initState();

    _futurePengumuman =
        _api.ambilPengumuman();
  }

  @override
  void dispose() {
    _api.tutup();
    super.dispose();
  }

  Future<void> _muatUlang() async {
    final Future<List<Announcement>> futureBaru =
        _api.ambilPengumuman();

    setState(() {
      _futurePengumuman = futureBaru;
    });

    try {
      await futureBaru;
    } catch (_) {
      // Error ditangani oleh FutureBuilder.
    }
  }

  void _pilihKategori(String value) {
    if (value == _kategoriTerpilih) {
      return;
    }

    setState(() {
      _kategoriTerpilih = value;
    });
  }

  void _bukaDetail(
    Announcement announcement,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) =>
            AnnouncementDetailScreen(
          announcement: announcement,
        ),
      ),
    );
  }

  String _pesanError(Object error) {
    return error.toString().replaceFirst(
          'Exception: ',
          '',
        );
  }

  Widget _buildMemuat() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Sedang mengambil pengumuman...',
          ),
        ],
      ),
    );
  }

  Widget _buildGagal(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color:
                  Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Data',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _pesanError(error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _muatUlang,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKosong() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak Ada Pengumuman',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada pengumuman untuk kategori '
              '"$_kategoriTerpilih".',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaftar(
    List<Announcement> items,
  ) {
    return RefreshIndicator(
      onRefresh: _muatUlang,
      child: ListView.builder(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final Announcement item = items[index];

          return AnnouncementCard(
            announcement: item,
            onTap: () => _bukaDetail(item),
          );
        },
      ),
    );
  }

  Widget _buildFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: kategori.map((String item) {
          return Padding(
            padding:
                const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(item),
              selected:
                  _kategoriTerpilih == item,
              onSelected: (_) =>
                  _pilihKategori(item),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Portal Pengumuman TRPL'),
        actions: [
          IconButton(
            onPressed: _muatUlang,
            tooltip: 'Segarkan Data',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilter(),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<
                List<Announcement>>(
              future: _futurePengumuman,
              builder: (
                BuildContext context,
                AsyncSnapshot<
                        List<Announcement>>
                    snapshot,
              ) {
                // 1. LOADING
                if (snapshot.connectionState !=
                    ConnectionState.done) {
                  return _buildMemuat();
                }

                // 2. ERROR
                if (snapshot.hasError) {
                  return _buildGagal(
                    snapshot.error!,
                  );
                }

                // 3. DATA
                final List<Announcement> semua =
                    snapshot.data ??
                        const <Announcement>[];

                final List<Announcement> tampil;

                if (_kategoriTerpilih ==
                    'Semua') {
                  tampil = semua;
                } else {
                  tampil = semua
                      .where(
                        (Announcement item) =>
                            item.category
                                .toLowerCase() ==
                            _kategoriTerpilih
                                .toLowerCase(),
                      )
                      .toList(
                        growable: false,
                      );
                }

                // 4. EMPTY
                if (tampil.isEmpty) {
                  return _buildKosong();
                }

                return _buildDaftar(tampil);
              },
            ),
          ),
        ],
      ),
    );
  }
}