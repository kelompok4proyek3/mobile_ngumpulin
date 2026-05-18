import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../models/recommendation_model.dart';
import '../services/recommendation_api_service.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final _service = RecommendationApiService();
  List<RecommendationModel> _recs = [];
  bool _isLoading = true;
  bool _isPending = false;
  String? _error;

  Timer? _pollingTimer;
  int _pollCount = 0;
  static const int _maxPollCount = 12;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _isPending = false;
    });
    _pollingTimer?.cancel();

    try {
      final result = await _service.getRecommendations();
      if (!mounted) return;

      if (result.isEmpty) {
        setState(() {
          _isLoading = false;
          _isPending = true;
          _pollCount = 0;
        });
        _startPolling();
      } else {
        setState(() {
          _recs = result;
          _isLoading = false;
          _isPending = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      _pollCount++;
      if (_pollCount > _maxPollCount) {
        _pollingTimer?.cancel();
        if (mounted) {
          setState(() => _isPending = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Generate memakan waktu lebih lama, coba refresh manual.'),
            ),
          );
        }
        return;
      }

      try {
        final result = await _service.getRecommendations();
        if (!mounted) return;
        if (result.isNotEmpty) {
          _pollingTimer?.cancel();
          setState(() {
            _recs = result;
            _isPending = false;
          });
        }
      } catch (_) {}
    });
  }

  Future<void> _refresh() async {
    _pollingTimer?.cancel();
    setState(() {
      _isPending = false;
      _pollCount = 0;
    });

    try {
      final msg = await _service.refreshRecommendations();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
      setState(() => _isPending = true);
      _startPolling();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F0EB),
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F0EB),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('Coba Lagi')),
            ],
          ),
        ),
      );
    }

    if (_isPending) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F0EB),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              const Text(
                'Rekomendasi sedang disiapkan...',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Mohon tunggu, ini hanya perlu beberapa detik.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_recs.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F0EB),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Belum ada rekomendasi untukmu.',
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              ElevatedButton(
                  onPressed: _refresh, child: const Text('Generate Rekomendasi')),
            ],
          ),
        ),
      );
    }

    final top    = _recs.first;
    final others = _recs.skip(1).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _load,
          child: CustomScrollView(
            slivers: [
              // ── Header ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.menu_rounded,
                            size: 20, color: AppColors.textPrimary),
                      ),
                      const Text(AppStrings.appName,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      GestureDetector(
                        onTap: _refresh,
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.refresh_rounded,
                              size: 20, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Title ────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(AppStrings.rekomendasiTerbaik,
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                              color: AppColors.primaryLight,
                              shape: BoxShape.circle),
                          child: const Icon(Icons.location_on_rounded,
                              size: 12, color: AppColors.primary),
                        ),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text(AppStrings.cfSubtitle,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary)),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),

              // ── Top Card ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20)),
                          child: _SpotImage(
                            imageUrl: top.spot.imageUrl,
                            height: 200,
                            width: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 12, left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20)),
                            child: const Text(AppStrings.terpopuler,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ]),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(top.spot.namaSpot,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary)),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${top.matchPercent.toInt()}%',
                                        style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primary)),
                                    const Text(AppStrings.kecocokan,
                                        style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                            letterSpacing: 1)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 13, color: AppColors.textHint),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  [
                                    if (top.spot.hargaRange != null)
                                      top.spot.hargaRange!,
                                    if (top.spot.category.isNotEmpty)
                                      top.spot.category,
                                  ].join(' • '),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary),
                                ),
                              ),
                            ]),
                            const SizedBox(height: 16),
                            Row(children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {},
                                  child: const Text(AppStrings.lihatDetail),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 48, height: 48,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppColors.divider, width: 1.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.bookmark_border_rounded,
                                    color: AppColors.textSecondary),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Other Cards ──────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _SmallRecCard(rec: others[i]),
                    childCount: others.length,
                  ),
                ),
              ),

              // ── Why section ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: const [
                        Text('✨ ', style: TextStyle(fontSize: 14)),
                        Text(AppStrings.kenapaMuncul,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                      ]),
                      const SizedBox(height: 8),
                      const Text(AppStrings.kenapaMunculDesc,
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.5)),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget foto yang handle null, loading, dan error dengan benar
// ─────────────────────────────────────────────────────────────────────────────

class _SpotImage extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final double? width;
  final double iconSize;

  const _SpotImage({
    required this.imageUrl,
    required this.height,
    this.width,
    this.iconSize = 48,
  });

  @override
  Widget build(BuildContext context) {
    // Null atau kosong → langsung placeholder
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _placeholder();
    }

    return Image.network(
      imageUrl!,
      height: height,
      width: width,
      fit: BoxFit.cover,
      // Tampilkan loading indicator saat gambar sedang diunduh
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: height,
          width: width,
          color: AppColors.primaryLight,
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      // Error → placeholder
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      height: height,
      width: width,
      color: AppColors.primaryLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_mall_directory_rounded,
              size: iconSize,
              color: AppColors.primary.withOpacity(0.35)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SmallRecCard extends StatelessWidget {
  final RecommendationModel rec;
  const _SmallRecCard({required this.rec});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text('${rec.ranking}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
          ),
        ),
        const SizedBox(width: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: _SpotImage(
            imageUrl: rec.spot.imageUrl,
            height: 64,
            width: 64,
            iconSize: 28,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text(rec.spot.namaSpot,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                ),
                Text('${rec.matchPercent.toInt()}%',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
              ]),
              const SizedBox(height: 2),
              Text(
                [
                  if (rec.spot.hargaRange != null) rec.spot.hargaRange!,
                  if (rec.spot.category.isNotEmpty) rec.spot.category,
                ].join(' • '),
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textHint),
              ),
              const SizedBox(height: 6),
              if (rec.spot.tags.isNotEmpty)
                Wrap(
                  spacing: 6,
                  children: rec.spot.tags
                      .map((t) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(t,
                                style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary)),
                          ))
                      .toList(),
                ),
            ],
          ),
        ),
      ]),
    );
  }
}