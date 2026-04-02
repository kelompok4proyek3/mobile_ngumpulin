class RecommendationModel {
  final String id;
  final String spotName;
  final String category;
  final String imageUrl;
  final double matchPercent;
  final String distance;
  final String location;
  final List<String> tags;
  final int rank;

  RecommendationModel({
    required this.id,
    required this.spotName,
    required this.category,
    required this.imageUrl,
    required this.matchPercent,
    required this.distance,
    required this.location,
    required this.tags,
    required this.rank,
  });
}
