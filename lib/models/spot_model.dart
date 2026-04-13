// lib/core/models/spot_model.dart

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
      id: json['id'] as int,
      namaSpot: json['nama_spot']?.toString() ?? '',
      alamat: json['alamat']?.toString() ?? '',
      // Safe parse: handle String, int, double, atau null
      lokasiLat: _toDouble(json['lokasi_lat']),
      lokasiLng: _toDouble(json['lokasi_lng']),
      jamBuka: json['jam_buka']?.toString(),
      jamTutup: json['jam_tutup']?.toString(),
      hargaRange: json['harga_range']?.toString(),
      deskripsi: json['deskripsi']?.toString(),
      avgRating: _toDouble(json['avg_rating']) ?? 0.0,
      reviewCount: _toInt(json['review_count']) ?? 0,
      isOpen: json['is_open'] == true || json['is_open'] == 1,
      kategoris: (json['kategoris'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  /// Parse apapun (String/int/double/null) jadi double?
  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Parse apapun (String/int/null) jadi int?
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  String get kategoriUtama =>
      kategoris.isNotEmpty ? kategoris.first.toUpperCase() : 'LAINNYA';

  String get jamOperasional =>
      (jamBuka != null && jamTutup != null) ? '$jamBuka - $jamTutup' : '-';
}
