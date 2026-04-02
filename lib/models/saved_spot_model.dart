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
}
