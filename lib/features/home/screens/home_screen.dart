// lib/features/home/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../models/spot_model.dart';
import '../../../core/widgets/spot_card.dart';
import '../services/location_api_service.dart';
import '../services/spot_api_service.dart';
import '../services/kategori_api_service.dart';
import '../../detail/screens/detail_screen.dart';
import '../../notification/screens/notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  String _currentCity = 'Memuat...';
  bool _isLoadingLocation = true;

  List<SpotModel> _spots = [];
  bool _isLoadingSpots = true;
  String? _errorMessage;

  // Kategori: index 0 selalu 'Semua', sisanya dari API
  List<String> _categories = [AppStrings.semua];
  bool _isLoadingKategoris = true;

  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  final _spotApiService = SpotApiService();
  final _kategoriApiService = KategoriApiService();

  @override
  void initState() {
    super.initState();
    _loadLocation();
    _loadKategoris();
    // Home pakai item-based murni: sort by google_rating dari server
    _loadSpots();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadLocation() async {
    setState(() => _isLoadingLocation = true);
    final city = await LocationService().getCurrentCity();
    if (mounted) {
      setState(() {
        _currentCity = city;
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _loadKategoris() async {
    final result = await _kategoriApiService.getKategoris();
    if (!mounted) return;

    if (result['success'] == true) {
      final List<dynamic> data = result['data'] ?? [];
      setState(() {
        _categories = [
          AppStrings.semua,
          ...data.map((k) => k['nama_kategori'].toString()),
        ];
        _isLoadingKategoris = false;
      });
    } else {
      setState(() {
        _categories = [AppStrings.semua, AppStrings.kafe, AppStrings.resto, AppStrings.outdoor];
        _isLoadingKategoris = false;
      });
    }
  }

  // Home: selalu sort=google_rating, tidak pakai CF sama sekali
  Future<void> _loadSpots({String? search, String? kategori}) async {
    setState(() {
      _isLoadingSpots = true;
      _errorMessage = null;
    });

    final result = await _spotApiService.getSpots(
      search: search,
      kategori: kategori,
      sort: 'google_rating', // ← item-based murni: ranking by google rating
    );

    if (!mounted) return;

    if (result['success'] == true) {
      final List<dynamic> data = result['data'] ?? [];
      setState(() {
        _spots = data.map((json) => SpotModel.fromJson(json)).toList();
        _isLoadingSpots = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'] ?? 'Gagal memuat data.';
        _isLoadingSpots = false;
      });
    }
  }

  List<SpotModel> get _filteredSpots {
    var spots = List<SpotModel>.from(_spots);

    // Filter kategori di client (data sudah sorted dari server)
    if (_selectedCategoryIndex != 0) {
      final cat = _categories[_selectedCategoryIndex].toLowerCase();
      spots = spots.where((s) => s.kategoriUtama.toLowerCase() == cat).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      spots = spots.where((s) {
        return s.namaSpot.toLowerCase().contains(q) ||
            s.kategoriUtama.toLowerCase().contains(q) ||
            s.alamat.toLowerCase().contains(q) ||
            s.kategoris.any((t) => t.toLowerCase().contains(q));
      }).toList();
    }

    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredSpots;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(AppStrings.lokasiKamu, style: TextStyle(fontSize: 11, color: AppColors.textHint)),
                            GestureDetector(
                              onTap: _loadLocation,
                              child: Row(
                                children: [
                                  _isLoadingLocation
                                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                                      : Text(_currentCity, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.textPrimary),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.white, shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
                        ),
                        child: Stack(
                          children: [
                            const Center(child: Icon(Icons.notifications_none_rounded, size: 20, color: AppColors.textPrimary)),
                            Positioned(
                              top: 8, right: 8,
                              child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      const Icon(Icons.search_rounded, color: AppColors.textHint, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            hintText: AppStrings.cariTempat,
                            hintStyle: TextStyle(fontSize: 14, color: AppColors.textHint),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(Icons.close_rounded, size: 18, color: AppColors.textHint),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Category Tabs — dari API
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _isLoadingKategoris
                    ? const SizedBox(height: 36)
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: List.generate(_categories.length, (i) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedCategoryIndex = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                                decoration: BoxDecoration(
                                  color: _selectedCategoryIndex == i ? AppColors.primary : AppColors.white,
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: _selectedCategoryIndex != i
                                      ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]
                                      : null,
                                ),
                                child: Text(
                                  _categories[i],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedCategoryIndex == i ? Colors.white : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          )),
                        ),
                      ),
              ),
            ),

            // Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _searchQuery.isNotEmpty
                          ? '${filtered.length} hasil untuk "$_searchQuery"'
                          : 'Terpopuler di Sekitarmu',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary),
                    ),
                    if (_searchQuery.isEmpty)
                      GestureDetector(
                        onTap: () {},
                        child: const Text(AppStrings.lihatSemua,
                            style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              ),
            ),

            // Loading State
            if (_isLoadingSpots)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                ),
              )

            // Error State
            else if (_errorMessage != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textHint),
                      const SizedBox(height: 12),
                      Text(_errorMessage!,
                          style: const TextStyle(fontSize: 14, color: AppColors.textHint),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      TextButton(onPressed: _loadSpots, child: const Text('Coba Lagi')),
                    ],
                  ),
                ),
              )

            // Empty State
            else if (filtered.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textHint),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Tidak ada tempat untuk "$_searchQuery"'
                            : 'Belum ada spot tersedia.',
                        style: const TextStyle(fontSize: 14, color: AppColors.textHint),
                      ),
                    ],
                  ),
                ),
              )

            // Spots List — diurutkan by google_rating dari server
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final spot = filtered[index];
                      return SpotCard(
                        spot: spot,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DetailScreen(spot: spot)),
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }
}