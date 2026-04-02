import '../../models/spot_model.dart';
import '../../models/recommendation_model.dart';
import '../../models/saved_spot_model.dart';

class DummyData {
  static List<ReviewModel> get reviews => [
        ReviewModel(
          id: 'r1',
          userName: 'Budi Santoso',
          userAvatar: '',
          rating: 5.0,
          comment:
              'Tempatnya asik banget buat nugas atau sekedar ngopi sore. Kopinya strong dan pelayanannya ramah. Wajib coba Croissant-nya!',
          timeAgo: '2 hari yang lalu',
          images: ['img1', 'img2'],
        ),
        ReviewModel(
          id: 'r2',
          userName: 'Sari Indah',
          userAvatar: '',
          rating: 4.0,
          comment:
              'Suasananya tenang, cocok buat meeting santai. Harganya standar Jakarta Selatan lah ya. Makanan beratnya juga enak-enak.',
          timeAgo: 'Seminggu yang lalu',
          images: [],
        ),
      ];

  static List<SpotModel> get spots => [
        SpotModel(
          id: 's1',
          name: 'Senja Coffee & Chill',
          category: 'KAFE',
          imageUrl:
              'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=800',
          rating: 4.8,
          distance: '1.2 km dari lokasimu',
          description:
              'Tempat favorit buat nugas atau sekedar ngobrol santai dengan view sunset terbaik di kota.',
          address: 'Jl. Sudirman No. 12, Indramayu',
          priceRange: 'Rp 20rb - Rp 80rb',
          openHours: '08:00 - 23:00',
          isOpen: true,
          tags: ['KAFE'],
        ),
        SpotModel(
          id: 's2',
          name: 'The Garden Terrace',
          category: 'RESTO',
          imageUrl:
              'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800',
          rating: 4.5,
          distance: '2.5 km dari lokasimu',
          description:
              'Nikmati hidangan nusantara dengan konsep semi-outdoor yang asri dan sejuk.',
          address: 'Jl. Gatot Subroto No. 45, Indramayu',
          priceRange: 'Rp 30rb - Rp 120rb',
          openHours: '10:00 - 22:00',
          isOpen: true,
          tags: ['RESTO'],
        ),
        SpotModel(
          id: 's3',
          name: 'Taman Ria Indramayu',
          category: 'OUTDOOR',
          imageUrl:
              'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=800',
          rating: 4.9,
          distance: '0.8 km dari lokasimu',
          description:
              'Pusat keramaian baru dengan banyak spot foto estetik dan jajanan kekinian.',
          address: 'Jl. Pahlawan No. 1, Indramayu',
          priceRange: 'Gratis',
          openHours: '07:00 - 22:00',
          isOpen: true,
          tags: ['OUTDOOR', 'HITS'],
        ),
        SpotModel(
          id: 's4',
          name: 'LO.LO Coffee & Resto',
          category: 'KAFE',
          imageUrl:
              'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800',
          rating: 4.8,
          distance: '1.5 km dari lokasimu',
          description:
              'Kafe premium dengan konsep modern industrial. Menu kopi dan makanan berat tersedia.',
          address: 'Jl. Melati No. 45, Indramayu',
          priceRange: 'Rp 50rb - Rp 150rb',
          openHours: '09:00 - 22:00',
          isOpen: true,
          tags: ['KAFE'],
          reviews: reviews,
        ),
        SpotModel(
          id: 's5',
          name: 'Rannum Space',
          category: 'KAFE',
          imageUrl:
              'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800',
          rating: 4.6,
          distance: '3.0 km dari lokasimu',
          description:
              'Co-working space dengan suasana nyaman, cocok buat kerja dan meeting.',
          address: 'Jl. Diponegoro No. 22, Indramayu',
          priceRange: 'Rp 25rb - Rp 100rb',
          openHours: '08:00 - 21:00',
          isOpen: true,
          tags: ['KAFE', 'WIFI'],
        ),
      ];

  static List<SavedSpotModel> get savedSpots => [
        SavedSpotModel(
          spot: spots[0].copyWith(isSaved: true),
          personalNote: 'Wajib coba manual brew-nya kalau ke sini sore-sore.',
          savedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        SavedSpotModel(
          spot: spots[1].copyWith(isSaved: true),
          personalNote: 'Tempat oke buat meeting bareng klien. Agak berisik kalau jam makan siang.',
          savedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        SavedSpotModel(
          spot: spots[2].copyWith(isSaved: true),
          personalNote: 'Bawa alas piknik sendiri. Datang sebelum jam 4 biar dapat spot bagus.',
          savedAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
        SavedSpotModel(
          spot: spots[3].copyWith(isSaved: true),
          personalNote: '',
          savedAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ];

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
