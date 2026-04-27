class SpotModel {
  final int id;
  final String namaSpot;
  final String alamat;
  final double lat;
  final double lng;
  final String? hargaRange;
  final String? jamBuka;
  final String? jamTutup;
  final double googleRating;
  final double avgRating;
  final int reviewCount;
  final bool isOpen;
  final String? imageUrl;
  final String category;      // nama_kategori pertama
  final List<String> tags;    // nama_preference yang relevan

  SpotModel({
    required this.id,
    required this.namaSpot,
    required this.alamat,
    required this.lat,
    required this.lng,
    this.hargaRange,
    this.jamBuka,
    this.jamTutup,
    this.googleRating = 0.0,
    this.avgRating = 0.0,
    this.reviewCount = 0,
    this.isOpen = false,
    this.imageUrl,
    this.category = '',
    this.tags = const [],
  });

  factory SpotModel.fromJson(Map<String, dynamic> json) {
    return SpotModel(
      id          : json['id'],
      namaSpot    : json['nama_spot'] ?? '',
      alamat      : json['alamat'] ?? '',
      lat         : double.tryParse(json['lat'].toString()) ?? 0.0,
      lng         : double.tryParse(json['lng'].toString()) ?? 0.0,
      hargaRange  : json['harga_range'],
      jamBuka     : json['jam_buka'],
      jamTutup    : json['jam_tutup'],
      googleRating: double.tryParse(json['google_rating'].toString()) ?? 0.0,
      avgRating   : double.tryParse(json['avg_rating'].toString()) ?? 0.0,
      reviewCount : json['review_count'] ?? 0,
      isOpen      : json['is_open'] ?? false,
      imageUrl    : json['image_url'],
      category    : json['category'] ?? '',
      tags        : List<String>.from(json['tags'] ?? []),
    );
  }
}

class RecommendationModel {
  final int ranking;
  final double skorPrediksi;
  final SpotModel spot;

  /// Kecocokan 0–100%, dinormalisasi dari skor CF (skala 0–5)
  double get matchPercent => (skorPrediksi / 5.0 * 100).clamp(0, 100);

  /// Jarak placeholder — isi dengan hasil kalkulasi haversine jika ada lokasi user
  String get distance => '';

  RecommendationModel({
    required this.ranking,
    required this.skorPrediksi,
    required this.spot,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      ranking      : json['ranking'],
      skorPrediksi : double.tryParse(json['skor_prediksi'].toString()) ?? 0.0,
      spot         : SpotModel.fromJson(json['spot']),
    );
  }
}