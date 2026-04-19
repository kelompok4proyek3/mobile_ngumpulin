// lib/features/mylist/screens/my_list_screen.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../models/saved_spot_model.dart';
import '../../../models/spot_model.dart';
import '../services/saved_spot_api_service.dart';
import '../../detail/screens/detail_screen.dart';

class MyListScreen extends StatefulWidget {
  const MyListScreen({super.key});

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> {
  List<SavedSpotModel> _savedSpots = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  final _apiService = SavedSpotApiService();

  @override
  void initState() {
    super.initState();
    _loadSavedSpots();
  }

  Future<void> _loadSavedSpots() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _apiService.getSavedSpots();

    if (!mounted) return;

    if (result['success'] == true) {
      final List<dynamic> data = result['data'] ?? [];
      setState(() {
        _savedSpots =
            data.map((json) => SavedSpotModel.fromJson(json)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'] ?? 'Gagal memuat daftar tersimpan.';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteItem(int spotId, int index) async {
    // Optimistic: hapus dari UI dulu
    final removed = _savedSpots[index];
    setState(() => _savedSpots.removeAt(index));

    final result = await _apiService.deleteSavedSpot(spotId);
    if (!mounted) return;

    if (result['success'] != true) {
      // Rollback kalau gagal
      setState(() => _savedSpots.insert(index, removed));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Gagal menghapus.')),
      );
    }
  }

  List<SavedSpotModel> get _filtered {
    if (_searchQuery.isEmpty) return _savedSpots;
    final q = _searchQuery.toLowerCase();
    return _savedSpots.where((s) {
      return s.spot.namaSpot.toLowerCase().contains(q) ||
          s.spot.alamat.toLowerCase().contains(q) ||
          s.spot.kategoriUtama.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          AppStrings.daftarTempat,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          AppStrings.daftarSubtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    // Container(
                    //   width: 40,
                    //   height: 40,
                    //   decoration: BoxDecoration(
                    //     color: AppColors.primary,
                    //     borderRadius: BorderRadius.circular(10),
                    //   ),
                    //   child: const Icon(Icons.bookmark_rounded,
                    //       color: Colors.white, size: 20),
                    // ),
                  ],
                ),
              ),
            ),

            // Search
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: TextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            hintText: AppStrings.cariTersimpan,
                            hintStyle: TextStyle(
                                fontSize: 13, color: AppColors.textHint),
                            prefixIcon: Icon(Icons.search_rounded,
                                color: AppColors.textHint, size: 18),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.tune_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ],
                ),
              ),
            ),

            // Loading
            if (_isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )

            // Error
            else if (_errorMessage != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    children: [
                      const Icon(Icons.wifi_off_rounded,
                          size: 48, color: AppColors.textHint),
                      const SizedBox(height: 12),
                      Text(_errorMessage!,
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.textHint),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      TextButton(
                          onPressed: _loadSavedSpots,
                          child: const Text('Coba Lagi')),
                    ],
                  ),
                ),
              )

            // Empty
            else if (filtered.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    children: [
                      const Icon(Icons.bookmark_border_rounded,
                          size: 48, color: AppColors.textHint),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Tidak ada hasil untuk "$_searchQuery"'
                            : 'Belum ada tempat tersimpan.',
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.textHint),
                      ),
                    ],
                  ),
                ),
              )

            // List
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final item = filtered[i];
                      return _SavedCard(
                        savedSpot: item,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailScreen(spot: item.spot),
                            ),
                          ).then((_) => _loadSavedSpots()); // ← tambah ini
                        },
                        onDelete: () => _deleteItem(item.spot.id, i),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _SavedCard extends StatelessWidget {
  final SavedSpotModel savedSpot;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SavedCard({
    required this.savedSpot,
    required this.onTap,
    required this.onDelete,
  });

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'kafe':
        return AppColors.kafeBadge;
      case 'resto':
        return AppColors.restoBadge;
      case 'outdoor':
        return AppColors.outdoorBadge;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final SpotModel spot = savedSpot.spot;
    final String note = savedSpot.personalNote;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Placeholder karena SpotModel tidak punya imageUrl
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    color: AppColors.divider,
                    child: const Icon(
                      Icons.store_mall_directory_rounded,
                      size: 48,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          size: 16, color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          spot.namaSpot, // ← dari DB
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(spot.kategoriUtama)
                              .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          spot.kategoriUtama, // ← dari DB
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _getCategoryColor(spot.kategoriUtama),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 12, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          spot.alamat, // ← dari DB
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textHint),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 12, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        spot.jamOperasional, // ← dari DB
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textHint),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: spot.isOpen
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          spot.isOpen ? 'Buka' : 'Tutup',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: spot.isOpen ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    AppStrings.catatanPribadi,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHint,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F0EB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      note.isEmpty ? 'Tambahkan catatan...' : note,
                      style: TextStyle(
                        fontSize: 12,
                        color: note.isEmpty
                            ? AppColors.textHint
                            : AppColors.textSecondary,
                        fontStyle:
                            note.isEmpty ? FontStyle.italic : FontStyle.normal,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
