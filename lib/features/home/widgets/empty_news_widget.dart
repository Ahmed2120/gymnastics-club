import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/main_text.dart';

class EmptyNewsWidget extends StatelessWidget {
  final bool isDark;
  const EmptyNewsWidget({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.05) 
              : Colors.black.withValues(alpha: 0.03),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 160,
            width: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark 
                  ? AppColors.primaryCrimson.withValues(alpha: 0.05)
                  : AppColors.primaryCrimson.withValues(alpha: 0.02),
            ),
            child: ClipOval(
              child: Opacity(
                opacity: 0.8,
                child: Image.asset(
                 isDark ? 'assets/images/no_news_dark.png' : 'assets/images/no_news.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.newspaper_rounded,
                    size: 64,
                    color: AppColors.primaryCrimson.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          MainText(
            'لا توجد أخبار حالياً',
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : Colors.black87,
          ),
          const SizedBox(height: 8),
          MainText(
            'سنقوم بإعلامك فور صدور أي جديد من النادي',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            textAlign: TextAlign.center,
            color: isDark ? Colors.white54 : Colors.grey[600],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryCrimson.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const MainText(
              'ترقبوا التحديثات 🔔',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryCrimson,
            ),
          ),
        ],
      ),
    );
  }
}
