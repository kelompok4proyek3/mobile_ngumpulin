import 'package:flutter/material.dart';
import '../../models/spot_model.dart';
import '../constants/app_colors.dart';

class SpotCard extends StatefulWidget {
  final SpotModel spot;
  final VoidCallback onTap;

  const SpotCard({super.key, required this.spot, required this.onTap});

  @override
  State<SpotCard> createState() => _SpotCardState();
}

class _SpotCardState extends State<SpotCard> {
  bool _isSaved = false;

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'kafe':
      case 'cafe':
      case 'coffee':
        return AppColors.kafeBadge;
      case 'resto':
      case 'restoran':
      case 'restaurant':
        return AppColors.restoBadge;
      case 'outdoor':
      case 'wisata':
      case 'taman':
        return AppColors.outdoorBadge;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final spot = widget.spot;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    color: AppColors.divider,
                    child: const Icon(
                      Icons.store_mall_directory_rounded,
                      size: 48,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
                // Hanya satu badge kategori, tanpa HITS
                Positioned(
                  top: 12,
                  left: 12,
                  child: _buildBadge(
                    spot.kategoriUtama,
                    _getCategoryColor(spot.kategoriUtama),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => setState(() => _isSaved = !_isSaved),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isSaved
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 18,
                        color: _isSaved ? AppColors.error : AppColors.textHint,
                      ),
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
                          spot.namaSpot,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppColors.star, size: 16),
                          const SizedBox(width: 2),
                          Text(
                            spot.avgRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.star,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${spot.reviewCount})',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 12, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          spot.alamat,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 12, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        spot.jamOperasional,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
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
                  if (spot.deskripsi != null && spot.deskripsi!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      spot.deskripsi!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (spot.hargaRange != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.attach_money_rounded,
                            size: 12, color: AppColors.textHint),
                        const SizedBox(width: 2),
                        Text(
                          spot.hargaRange!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    final displayLabel = label.isNotEmpty
        ? label[0].toUpperCase() + label.substring(1).toLowerCase()
        : label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayLabel, // <-- pakai ini, bukan label langsung
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
