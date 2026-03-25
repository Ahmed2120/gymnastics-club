import 'package:flutter/material.dart';
import 'package:gymnastics_club/core/theme/app_colors.dart';
import 'package:gymnastics_club/widgets/main_text.dart';

class AchievementStatsHUD extends StatelessWidget {
  final int goldCount;
  final int silverCount;
  final int bronzeCount;

  const AchievementStatsHUD({
    super.key,
    required this.goldCount,
    required this.silverCount,
    required this.bronzeCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCapsuleCard(
          label: 'ذهبية',
          count: goldCount,
          medalColor: AppColors.achievementGold,
          icon: Icons.emoji_events_rounded,
          isDark: isDark,
        ),
        const SizedBox(width: 16),
        _buildCapsuleCard(
          label: 'فضية',
          count: silverCount,
          medalColor: const Color(0xFFC0C0C0),
          icon: Icons.military_tech_rounded,
          isDark: isDark,
        ),
        const SizedBox(width: 16),
        _buildCapsuleCard(
          label: 'برونزية',
          count: bronzeCount,
          medalColor: const Color(0xFFCD7F32),
          icon: Icons.stars_rounded,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildCapsuleCard({
    required String label,
    required int count,
    required Color medalColor,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      width: 100,
      height: 180,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFEEEEEE),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: medalColor,
              boxShadow: [
                BoxShadow(
                  color: medalColor.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const Spacer(),
          MainText(
            _formatCount(count),
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF212121),
          ),
          const SizedBox(height: 4),
          MainText(
            label,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white54 : Colors.grey[600],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatCount(int number) {
    if (number == 0) return '..';
    return number.toString().padLeft(2, '0');
  }
}
