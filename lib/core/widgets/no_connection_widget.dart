import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class NoConnectionWidget extends StatelessWidget {
  /// Pesan utama yang ditampilkan. Default: pesan koneksi generik.
  final String? message;

  /// Judul opsional. Default: 'Tidak Ada Koneksi'.
  final String? title;

  /// Callback ketika tombol "Coba Lagi" ditekan. Wajib diisi.
  final VoidCallback onRetry;

  /// Label tombol retry. Default: 'Coba Lagi'.
  final String retryLabel;

  /// Padding vertikal widget (useful untuk error di tengah list).
  final double verticalPadding;

  const NoConnectionWidget({
    super.key,
    required this.onRetry,
    this.message,
    this.title,
    this.retryLabel = 'Coba Lagi',
    this.verticalPadding = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ikon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              size: 34,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Judul
          Text(
            title ?? 'Tidak Ada Koneksi',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),

          // Pesan
          Text(
            message ??
                'Periksa koneksi internetmu,\nlalu coba lagi.',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Tombol retry
          SizedBox(
            height: 42,
            child: ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(
                retryLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}