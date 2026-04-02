class UserModel {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final List<String> preferences;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.preferences,
  });
}
