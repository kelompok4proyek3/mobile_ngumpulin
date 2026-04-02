class SpotModel {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final double rating;
  final String distance;
  final String description;
  final String address;
  final String priceRange;
  final String openHours;
  final bool isOpen;
  final List<String> tags;
  final List<ReviewModel> reviews;
  final bool isSaved;

  SpotModel({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.distance,
    required this.description,
    required this.address,
    required this.priceRange,
    required this.openHours,
    required this.isOpen,
    this.tags = const [],
    this.reviews = const [],
    this.isSaved = false,
  });

  SpotModel copyWith({bool? isSaved}) {
    return SpotModel(
      id: id,
      name: name,
      category: category,
      imageUrl: imageUrl,
      rating: rating,
      distance: distance,
      description: description,
      address: address,
      priceRange: priceRange,
      openHours: openHours,
      isOpen: isOpen,
      tags: tags,
      reviews: reviews,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

class ReviewModel {
  final String id;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final String timeAgo;
  final List<String> images;

  ReviewModel({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.timeAgo,
    this.images = const [],
  });
}
