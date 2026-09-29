class Announcement {
  final int id;
  final String title;
  final String content;
  final String author;
  final String category;
  final String date;
  final int readCount;

  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.category,
    required this.date,
    this.readCount = 0,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] is String
          ? json['title'] as String
          : 'Tanpa Judul',
      content: json['content'] is String
          ? json['content'] as String
          : json['body'] is String
              ? json['body'] as String
              : '',
      author: json['author'] is String
          ? json['author'] as String
          : 'Admin Jurusan',
      category: json['category'] is String
          ? json['category'] as String
          : 'Akademik',
      date: json['date'] is String
          ? json['date'] as String
          : '2026-09-01',
      readCount: json['readCount'] is int
          ? json['readCount'] as int
          : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author': author,
      'category': category,
      'date': date,
      'readCount': readCount,
    };
  }

  static List<Announcement> getSampleAnnouncements() {
    return const [
      Announcement(
        id: 1,
        title: 'Jadwal Pengisian KRS Semester Ganjil 2026/2027',
        content:
            'Pengisian Kartu Rencana Studi untuk mahasiswa tingkat 3 '
            'dimulai tanggal 1 hingga 7 September 2026. '
            'Pastikan telah menyelesaikan bimbingan dosen wali.',
        author: 'Bagian Akademik Poliwangi',
        category: 'Akademik',
        date: '2026-09-01',
        readCount: 142,
      ),
      Announcement(
        id: 2,
        title: 'Pendaftaran Program Magang Industri Bersertifikat Batch 7',
        content:
            'Kesempatan magang enam bulan di perusahaan teknologi '
            'mitra jurusan. Mahasiswa semester 5 yang memenuhi syarat '
            'dapat mengunggah portofolio GitHub.',
        author: 'Koordinator Magang TRPL',
        category: 'Kegiatan',
        date: '2026-09-02',
        readCount: 89,
      ),
      Announcement(
        id: 3,
        title: 'Sosialisasi Beasiswa Unggulan dan Bantuan UKT 2026',
        content:
            'Informasi mengenai persyaratan beasiswa prestasi akademik '
            'dan bantuan dana pendidikan semester 5.',
        author: 'Kemahasiswaan Poliwangi',
        category: 'Beasiswa',
        date: '2026-08-28',
        readCount: 215,
      ),
      Announcement(
        id: 4,
        title: 'Tim Mahasiswa TRPL Meraih Prestasi Hackathon Nasional',
        content:
            'Selamat kepada tim mahasiswa TRPL yang berhasil meraih '
            'prestasi dalam kompetisi nasional pengembangan aplikasi.',
        author: 'Himpunan Mahasiswa TI',
        category: 'Prestasi',
        date: '2026-08-25',
        readCount: 304,
      ),
    ];
  }
}