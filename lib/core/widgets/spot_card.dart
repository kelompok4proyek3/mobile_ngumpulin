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
    switch (category.toUpperCase()) {
      case 'KAFE':
        return AppColors.kafeBadge;
      case 'RESTO':
        return AppColors.restoBadge;
      case 'OUTDOOR':
        return AppColors.outdoorBadge;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  child: Image.network(
                    widget.spot.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      color: AppColors.divider,
                      child: const Icon(Icons.image_not_supported,
                          color: AppColors.textHint),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: _buildBadge(
                      widget.spot.category,
                      _getCategoryColor(widget.spot.category)),
                ),
                if (widget.spot.tags.length > 1)
                  Positioned(
                    top: 12,
                    left: widget.spot.category.length * 8.0 + 24,
                    child: _buildBadge('HITS', AppColors.hitsBadge),
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
                          widget.spot.name,
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
                            widget.spot.rating.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.star,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.near_me_rounded,
                          size: 12, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        widget.spot.distance,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.spot.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
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
