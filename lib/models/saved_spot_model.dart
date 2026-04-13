// lib/core/models/saved_spot_model.dart

import 'spot_model.dart';

class SavedSpotModel {
  final SpotModel spot;
  final String personalNote;
  final DateTime savedAt;

  SavedSpotModel({
    required this.spot,
    required this.personalNote,
    required this.savedAt,
  });

  factory SavedSpotModel.fromJson(Map<String, dynamic> json) {
    return SavedSpotModel(
      spot: SpotModel.fromJson(json['spot'] ?? json),
      personalNote: json['personal_note'] ?? '',
      savedAt: json['saved_at'] != null
          ? DateTime.tryParse(json['saved_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}