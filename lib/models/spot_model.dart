// lib/core/models/spot__model.dart

class SpotModel {
  final int id;
  final String namaSpot;
  final String alamat;
  final double? lokasiLat;
  final double? lokasiLng;
  final String? jamBuka;
  final String? jamTutup;
  final String? hargaRange;
  final String? deskripsi;
  final double avgRating;
  final int reviewCount;
  final bool isOpen;
  final List<String> kategoris;

  SpotModel({
    required this.id,
    required this.namaSpot,
    required this.alamat,
    this.lokasiLat,
    this.lokasiLng,
    this.jamBuka,
    this.jamTutup,
    this.hargaRange,
    this.deskripsi,
    required this.avgRating,
    required this.reviewCount,
    required this.isOpen,
    required this.kategoris,
  });

  factory SpotModel.fromJson(Map<String, dynamic> json) {
    return SpotModel(
      id:          json['id'],
      namaSpot:    json['nama_spot'] ?? '',
      alamat:      json['alamat'] ?? '',
      lokasiLat:   (json['lokasi_lat'] as num?)?.toDouble(),
      lokasiLng:   (json['lokasi_lng'] as num?)?.toDouble(),
      jamBuka:     json['jam_buka'],
      jamTutup:    json['jam_tutup'],
      hargaRange:  json['harga_range'],
      deskripsi:   json['deskripsi'],
      avgRating:   (json['avg_rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] ?? 0,
      isOpen:      json['is_open'] ?? true,
      kategoris:   List<String>.from(json['kategoris'] ?? []),
    );
  }

  String get kategoriUtama =>
      kategoris.isNotEmpty ? kategoris.first.toUpperCase() : 'LAINNYA';

  String get jamOperasional =>
      (jamBuka != null && jamTutup != null) ? '$jamBuka - $jamTutup' : '-';
}