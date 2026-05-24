import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavData(Icons.home_rounded, Icons.home_outlined, AppStrings.home),
    _NavData(Icons.auto_awesome_rounded, Icons.auto_awesome_outlined, AppStrings.rekomendasi),
    _NavData(Icons.bookmark_rounded, Icons.bookmark_outline_rounded, AppStrings.list),
    _NavData(Icons.person_rounded, Icons.person_outline_rounded, AppStrings.profil),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final selected = currentIndex == i;
              return _NavItem(
                icon: selected ? item.iconFilled : item.iconOutline,
                label: item.label,
                isSelected: selected,
                onTap: () => onTap(i),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavData {
  final IconData iconFilled;
  final IconData iconOutline;
  final String label;
  const _NavData(this.iconFilled, this.iconOutline, this.label);
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pill indicator + icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected ? AppColors.primary : AppColors.textHint,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textHint,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}