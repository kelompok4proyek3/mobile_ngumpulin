// lib/features/detail/screens/detail_screen.dart
import '../../../../core/widgets/no_connection_widget.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/spot_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../mylist/services/saved_spot_api_service.dart';
import '../services/rating_api_service.dart';
import '../../../core/widgets/rating_dialog.dart';

class DetailScreen extends StatefulWidget {
  final SpotModel spot;
  const DetailScreen({super.key, required this.spot});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // ── Save state ─────────────────────────────────────────────────────────────
  bool _isSaved = false;
  bool _isLoadingSave = false;
  bool _isCheckingSaved = true;
  final _savedSpotService = SavedSpotApiService();
  String? _ratingError;

  // ── Rating state ───────────────────────────────────────────────────────────
  final _ratingService = RatingApiService();
  bool _isLoadingRatings = true;
  double _avgScore = 0;
  int _totalRating = 0;
  Map<int, int> _distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
  List<Map<String, dynamic>> _ratings = [];

  @override
  void initState() {
    super.initState();
    _checkSavedStatus();
    _loadRatings();
  }

  Future<void> _checkSavedStatus() async {
    final isSaved = await _savedSpotService.checkIsSaved(widget.spot.id);
    if (mounted) {
      setState(() {
        _isSaved = isSaved;
        _isCheckingSaved = false;
      });
    }
  }

  // ── Load ratings dari API ──────────────────────────────────────────────────
  Future<void> _loadRatings() async {
    setState(() {
      _isLoadingRatings = true;
      _ratingError = null;
    });
    try {
      final result = await _ratingService.getRatingsBySpot(widget.spot.id);
      if (!mounted) return;

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        final dist = (data['distribution'] as Map<String, dynamic>?) ?? {};
        setState(() {
          _avgScore = (data['avg_score'] as num?)?.toDouble() ?? 0;
          _totalRating = (data['total_rating'] as int?) ?? 0;
          _distribution = {
            5: (dist['5'] as int?) ?? 0,
            4: (dist['4'] as int?) ?? 0,
            3: (dist['3'] as int?) ?? 0,
            2: (dist['2'] as int?) ?? 0,
            1: (dist['1'] as int?) ?? 0
          };
          _ratings =
              List<Map<String, dynamic>>.from((data['ratings'] as List?) ?? []);
        });
      } else {
        setState(
            () => _ratingError = result['message'] ?? 'Gagal memuat ulasan.');
      }
    } catch (_) {
      if (mounted) setState(() => _ratingError = 'Tidak ada koneksi internet.');
    } finally {
      if (mounted) setState(() => _isLoadingRatings = false);
    }
  }

  Future<void> _toggleSave() async {
    if (_isLoadingSave) return;
    setState(() => _isLoadingSave = true);
    try {
      final result = _isSaved
          ? await _savedSpotService.deleteSavedSpot(widget.spot.id)
          : await _savedSpotService.saveSpot(widget.spot.id);

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() => _isSaved = !_isSaved);
        _showSnack(
          _isSaved ? 'Spot disimpan ke daftar!' : 'Spot dihapus dari daftar.',
          color: _isSaved ? AppColors.primary : AppColors.textSecondary,
        );
      } else {
        _showSnack(result['message'] ?? 'Gagal, coba lagi.',
            color: AppColors.error);
      }
    } catch (_) {
      if (mounted)
        _showSnack('Tidak ada koneksi internet.', color: AppColors.error);
    } finally {
      if (mounted) setState(() => _isLoadingSave = false);
    }
  }

  Future<void> _openGoogleMaps() async {
    final lat = widget.spot.lokasiLat;
    final lng = widget.spot.lokasiLng;

    if (lat == null || lng == null) {
      _showSnack('Koordinat lokasi tidak tersedia');
      return;
    }

    final q = Uri.encodeComponent(widget.spot.namaSpot);
    final uris = [
      Uri.parse('geo:$lat,$lng?q=$lat,$lng($q)'),
      Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng'),
    ];

    for (final uri in uris) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }

    if (mounted)
      _showSnack('Tidak dapat membuka Google Maps', color: AppColors.error);
  }

  void _showSnack(String msg, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final spot = widget.spot;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar ─────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.width * 9 / 16,
            pinned: true,
            backgroundColor: AppColors.white,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1), blurRadius: 8)
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 16, color: AppColors.textPrimary),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1), blurRadius: 8)
                  ],
                ),
                child: const Icon(Icons.share_outlined,
                    size: 16, color: AppColors.textPrimary),
              ),
            ],
            centerTitle: true,
            title: const Text(AppStrings.detailTempat),
            flexibleSpace: FlexibleSpaceBar(
              background: widget.spot.imageUrl != null
                  ? Image.network(
                      widget.spot.imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: AppColors.primaryLight,
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stack) => Container(
                        color: AppColors.primaryLight,
                        child: const Center(
                          child: Icon(Icons.storefront_rounded,
                              size: 80, color: AppColors.primary),
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.primaryLight,
                      child: const Center(
                        child: Icon(Icons.storefront_rounded,
                            size: 80, color: AppColors.primary),
                      ),
                    ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFFF5F0EB),
              child: Column(
                children: [
                  _buildInfoCard(spot),
                  _buildLokasiCard(spot),
                  const SizedBox(height: 16),
                  _buildRatingCard(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Info Card ─────────────────────────────────────────────────────────────
  Widget _buildInfoCard(SpotModel spot) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  spot.namaSpot,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      _avgScore > 0 ? _avgScore.toStringAsFixed(1) : '-',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary),
                    ),
                    const Text('RATING',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${spot.kategoriUtama} • ${spot.isOpen ? AppStrings.terbuka : AppStrings.tutup}',
            style: const TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.payments_outlined,
                  size: 14, color: AppColors.textHint),
              const SizedBox(width: 6),
              Text(spot.hargaRange ?? '-',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(width: 16),
              const Icon(Icons.access_time_outlined,
                  size: 14, color: AppColors.textHint),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${AppStrings.buka} ${spot.jamBuka ?? '-'} - ${spot.jamTutup ?? '-'}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isCheckingSaved ? null : _toggleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isSaved ? AppColors.primary : AppColors.primaryLight,
                    foregroundColor:
                        _isSaved ? Colors.white : AppColors.primary,
                    elevation: 0,
                    minimumSize: const Size(0, 44),
                  ),
                  icon: _isLoadingSave
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primary),
                        )
                      : Icon(
                          _isSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          size: 16),
                  label: Text(
                    _isSaved ? 'Tersimpan' : AppStrings.simpanKeList,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  // ← FIXED: pakai showRatingDialog + _loadRatings
                  onPressed: () async {
                    final rated =
                        await showRatingDialog(context, widget.spot.id);
                    if (rated) _loadRatings();
                  },
                  style:
                      OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
                  icon: const Icon(Icons.star_border_rounded, size: 16),
                  label: const Text(AppStrings.beriRating,
                      style: TextStyle(fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Lokasi Card ───────────────────────────────────────────────────────────
  Widget _buildLokasiCard(SpotModel spot) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(AppStrings.lokasi,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(spot.alamat,
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _openGoogleMaps,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  Container(
                    height: 140,
                    width: double.infinity,
                    color: const Color(0xFFE5E0D8),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(double.infinity, 140),
                          painter: _MapGridPainter(),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.location_on_rounded,
                                  color: Colors.white, size: 20),
                            ),
                            Container(
                                width: 2, height: 8, color: AppColors.primary),
                            Container(
                              width: 8,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        if (spot.lokasiLat != null && spot.lokasiLng != null)
                          Positioned(
                            bottom: 6,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${spot.lokasiLat!.toStringAsFixed(4)}, ${spot.lokasiLng!.toStringAsFixed(4)}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.map_rounded,
                              size: 14, color: AppColors.primary),
                          SizedBox(width: 6),
                          Text(AppStrings.bukaGoogleMaps,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Rating Card ─────────────────────────────────────────────────────────
  Widget _buildRatingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(AppStrings.ulasanPengguna,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          if (_isLoadingRatings)
            const Center(
                child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(color: AppColors.primary),
            ))
          else if (_ratingError != null)
            // ← error state inline di dalam card (bukan full-screen)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  const Icon(Icons.wifi_off_rounded,
                      size: 32, color: AppColors.textHint),
                  const SizedBox(height: 8),
                  Text(_ratingError!,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textHint),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _loadRatings,
                    icon: const Icon(Icons.refresh_rounded, size: 14),
                    label: const Text('Muat Ulang',
                        style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            )
          else if (_totalRating == 0)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Belum ada ulasan. Jadilah yang pertama!',
                    style: TextStyle(fontSize: 13, color: AppColors.textHint)),
              ),
            )
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      _avgScore.toStringAsFixed(1),
                      style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          height: 1),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < _avgScore.floor()
                              ? Icons.star_rounded
                              : i < _avgScore
                                  ? Icons.star_half_rounded
                                  : Icons.star_outline_rounded,
                          size: 16,
                          color: AppColors.star,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Berdasarkan $_totalRating ulasan',
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textHint)),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [5, 4, 3, 2, 1].map((star) {
                      final count = _distribution[star] ?? 0;
                      final pct = _totalRating > 0 ? count / _totalRating : 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text('$star',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textHint)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  minHeight: 6,
                                  backgroundColor: AppColors.divider,
                                  valueColor: const AlwaysStoppedAnimation(
                                      AppColors.primary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider),
            ..._ratings.map((r) => _RatingItem(data: r)),
          ],
          const SizedBox(height: 8),
          Center(
            child: GestureDetector(
              onTap: () {},
              child: const Text(AppStrings.lihatSemuaUlasan,
                  style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Rating Item ────────────────────────────────────────────────────────────────
class _RatingItem extends StatelessWidget {
  final Map<String, dynamic> data;
  const _RatingItem({required this.data});

  @override
  Widget build(BuildContext context) {
    final user = (data['user'] as Map<String, dynamic>?) ?? {};
    final score = (data['score'] as int?) ?? 0;
    final name = (user['name'] as String?) ?? 'Pengguna';
    final fotoUrl = user['foto_profile'] as String?;
    final timeAgo = (data['created_at'] as String?) ?? '';
    final reviewText = data['review_text'] as String?;
    // Baca foto_urls sebagai array; fallback ke foto_url kalau masih single
    final reviewFotos = (data['foto_urls'] as List?)
            ?.map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList() ??
        (data['foto_url'] != null ? [data['foto_url'].toString()] : []);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: avatar + nama + bintang ──────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withOpacity(0.15),
                    backgroundImage:
                        fotoUrl != null ? NetworkImage(fotoUrl) : null,
                    child: fotoUrl == null
                        ? Text(initial,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                fontSize: 13))
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      Text(timeAgo,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textHint)),
                    ],
                  ),
                ],
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < score ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 13,
                    color: AppColors.star,
                  ),
                ),
              ),
            ],
          ),

          // ── Review text ───────────────────────────────────────────────
          if (reviewText != null && reviewText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              reviewText,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],

          // ── Foto review ───────────────────────────────────────────────
          if (reviewFotos.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: reviewFotos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final url = reviewFotos[i];
                  return GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        backgroundColor: Colors.transparent,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(url, fit: BoxFit.contain),
                        ),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        url,
                        height: 160,
                        width: reviewFotos.length == 1 ? double.infinity : 200,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) => progress == null
                            ? child
                            : Container(
                                height: 160,
                                width: reviewFotos.length == 1
                                    ? double.infinity
                                    : 200,
                                color: AppColors.primaryLight,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: AppColors.primary),
                                ),
                              ),
                        errorBuilder: (_, __, ___) => Container(
                          height: 160,
                          width: 200,
                          color: AppColors.primaryLight,
                          child: const Center(
                            child: Icon(Icons.broken_image_outlined,
                                color: AppColors.textHint),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 10),
          const Divider(color: AppColors.divider, height: 1),
        ],
      ),
    );
  }
}

// ── Map Grid Painter ────────────────────────────────────────────────────────────
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4CFC8)
      ..strokeWidth = 0.8;
    for (double y = 0; y < size.height; y += 22) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width; x += 36) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    final road = Paint()
      ..color = const Color(0xFFC8C3BC)
      ..strokeWidth = 4;
    canvas.drawLine(Offset(0, size.height * 0.4),
        Offset(size.width, size.height * 0.4), road);
    canvas.drawLine(Offset(size.width * 0.35, 0),
        Offset(size.width * 0.35, size.height), road);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
