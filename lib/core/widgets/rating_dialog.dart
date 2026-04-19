// lib/features/detail/widgets/rating_dialog.dart
//
// Dialog beri rating yang terhubung ke API.
// Dipakai di DetailScreen dengan: showRatingDialog(context, spotId)

import 'package:flutter/material.dart';
import '../../features/detail/services/rating_api_service.dart';
import '../../../core/constants/app_colors.dart';

// ── Fungsi helper — panggil ini dari DetailScreen ──────────────────────────
Future<bool> showRatingDialog(BuildContext context, int spotId) async {
  final service = RatingApiService();

  // Cek dulu apakah user sudah pernah rating spot ini
  final myRatingData = await service.getMyRating(spotId);
  final existingScore = (myRatingData['has_rated'] == true)
      ? (myRatingData['data']['score'] as int)
      : 0;

  if (!context.mounted) return false;

  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _RatingSheet(
      spotId: spotId,
      existingScore: existingScore,
      service: service,
    ),
  );

  return result == true;
}

// ── Bottom Sheet ────────────────────────────────────────────────────────────
class _RatingSheet extends StatefulWidget {
  final int spotId;
  final int existingScore;
  final RatingApiService service;

  const _RatingSheet({
    required this.spotId,
    required this.existingScore,
    required this.service,
  });

  @override
  State<_RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<_RatingSheet> {
  late int _selectedScore;
  bool _isLoading = false;

  // Label deskripsi per bintang
  final _labels = {
    0: 'Pilih bintang',
    1: 'Sangat Buruk 😞',
    2: 'Kurang Memuaskan 😕',
    3: 'Cukup 😐',
    4: 'Bagus! 😊',
    5: 'Luar Biasa! 🤩',
  };

  @override
  void initState() {
    super.initState();
    _selectedScore = widget.existingScore;
  }

  Future<void> _submit() async {
    if (_selectedScore == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih bintang terlebih dahulu'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await widget.service.submitRating(
      widget.spotId,
      _selectedScore,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.pop(context, true); // true = sinyal ke DetailScreen untuk reload
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(result['message'] ?? 'Rating berhasil dikirim'),
            ],
          ),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal mengirim rating'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.existingScore > 0;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            isUpdate ? 'Perbarui Rating' : 'Beri Rating',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isUpdate
                ? 'Rating sebelumnya: ${widget.existingScore} bintang'
                : 'Bagaimana pengalamanmu di sini?',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Bintang
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final starNum = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _selectedScore = starNum),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    starNum <= _selectedScore
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: starNum <= _selectedScore ? 48 : 40,
                    color: starNum <= _selectedScore
                        ? AppColors.star
                        : AppColors.divider,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),

          // Label bintang
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _labels[_selectedScore] ?? '',
              key: ValueKey(_selectedScore),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _selectedScore > 0
                    ? AppColors.primary
                    : AppColors.textHint,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Tombol submit
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading || _selectedScore == 0 ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.divider,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(
                      isUpdate ? 'Perbarui Rating' : 'Kirim Rating',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          // Tombol hapus rating (kalau sudah pernah rating)
          if (isUpdate) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() => _isLoading = true);
                      final result = await widget.service
                          .deleteMyRating(widget.spotId);
                      setState(() => _isLoading = false);
                      if (!mounted) return;
                      Navigator.pop(context, true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              result['message'] ?? 'Rating dihapus'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
              icon: const Icon(Icons.delete_outline_rounded,
                  size: 16, color: AppColors.error),
              label: const Text(
                'Hapus Rating',
                style: TextStyle(
                    color: AppColors.error,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ],
      ),
    );
  }
}