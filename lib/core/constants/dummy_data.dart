// lib/core/constants/dummy_data.dart

import '../../models/recommendation_model.dart';

class DummyData {
  // Spots sudah diambil dari API via SpotApiService — tidak perlu dummy lagi.

  static List<RecommendationModel> get recommendations => [
        RecommendationModel(
          id: 'rec1',
          spotName: 'Kopi Kenangan - Senayan',
          category: 'Kafe Lokal',
          imageUrl:
              'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800',
          matchPercent: 98,
          distance: '1.2 km',
          location: 'Senayan, Jakarta Pusat',
          tags: [],
          rank: 1,
        ),
        RecommendationModel(
          id: 'rec2',
          spotName: 'Anomali Coffee - Menteng',
          category: 'Kopi lokal premium',
          imageUrl:
              'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800',
          matchPercent: 94,
          distance: '2.5 km',
          location: 'Menteng, Jakarta Pusat',
          tags: ['WIFI KENCANG', 'TENANG'],
          rank: 2,
        ),
        RecommendationModel(
          id: 'rec3',
          spotName: 'Common Grounds',
          category: 'Brunch & Speciality Coffee',
          imageUrl:
              'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=800',
          matchPercent: 89,
          distance: '3.1 km',
          location: 'Jakarta Selatan',
          tags: ['OUTDOOR', 'PARKIR LUAS'],
          rank: 3,
        ),
        RecommendationModel(
          id: 'rec4',
          spotName: 'Fore Coffee - Grand Indo',
          category: 'Modern & High-tech',
          imageUrl:
              'https://images.unsplash.com/photo-1511920170033-f8396924c348?w=800',
          matchPercent: 82,
          distance: '0.8 km',
          location: 'Grand Indonesia, Jakarta',
          tags: ['CHARGING POINT'],
          rank: 4,
        ),
      ];

  static List<String> get preferenceOptions => [
        'Kafe',
        'Resto',
        'Outdoor',
        'Rooftop',
        'Budget-friendly',
        'Late Night',
        'WiFi',
        'Live Music',
        'Kid Friendly',
        'Stopkontak',
      ];

  static List<String> get preferenceIcons => [
        '☕',
        '🍽️',
        '🌲',
        '🏙️',
        '💰',
        '🌙',
        '📶',
        '🎵',
        '👶',
        '🔌',
      ];

  static List<String> get userPreferences => [
        'Konser',
        'Olahraga',
        'Kuliner',
        'Teknologi',
        'Seni',
      ];
}