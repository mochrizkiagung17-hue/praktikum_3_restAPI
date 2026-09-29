import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/announcement.dart';

class AnnouncementApi {
  AnnouncementApi({
    http.Client? client,
    this.modeSimulasi = false,
  })  : _client = client ?? http.Client(),
        _milikSendiri = client == null;

  final http.Client _client;
  final bool _milikSendiri;

  final bool modeSimulasi;

  static const String baseUrl =
      'https://jsonplaceholder.typicode.com';

  static const Duration batasWaktu = Duration(seconds: 10);

  static const List<String> daftarKategori = [
    'Akademik',
    'Beasiswa',
    'Kegiatan',
    'Prestasi',
    'Tidak ada',
  ];

  Future<List<Announcement>> ambilPengumuman() async {
    if (modeSimulasi) {
      await Future<void>.delayed(
        const Duration(seconds: 1),
      );

      return Announcement.getSampleAnnouncements();
    }

    late http.Response response;

    try {
      response = await _client
          .get(
            Uri.parse('$baseUrl/posts?_limit=10'),
          )
          .timeout(batasWaktu);
    } on TimeoutException {
      throw Exception(
        'Koneksi ke server timeout. Periksa sambungan internet Anda.',
      );
    } on http.ClientException {
      throw Exception(
        'Gagal terhubung ke server. Periksa koneksi data atau Wi-Fi Anda.',
      );
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Server merespons dengan status ${response.statusCode}.',
      );
    }

    dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw Exception(
        'Respons server bukan JSON yang valid.',
      );
    }

    if (decoded is! List) {
      throw Exception(
        'Format data server tidak sesuai.',
      );
    }

    final List<Announcement> hasil = [];

    for (int i = 0; i < decoded.length; i++) {
      final dynamic raw = decoded[i];

      if (raw is! Map) {
        throw Exception(
          'Format salah pada data pengumuman ke-${i + 1}.',
        );
      }

      final Map<String, dynamic> mentah =
          Map<String, dynamic>.from(raw);

      hasil.add(
        Announcement.fromJson({
          'id': mentah['id'],
          'title': mentah['title'],
          'content': mentah['body'],
          'author': 'Bagian Akademik Poliwangi',
          'category':
              daftarKategori[i % daftarKategori.length],
          'date':
              '2026-09-${(i % 28 + 1).toString().padLeft(2, '0')}',
          'readCount': (i + 1) * 37,
        }),
      );
    }

    return List<Announcement>.unmodifiable(hasil);
  }

  void tutup() {
    if (_milikSendiri) {
      _client.close();
    }
  }
}