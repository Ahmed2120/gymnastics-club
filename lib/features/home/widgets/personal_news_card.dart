import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gymnastics_club/core/theme/app_colors.dart';
import '../../../../widgets/main_text.dart';
import '../../../../data/models/models/news_model.dart';
import './news_details_bottom_sheet.dart';

class ImportantAlertCard extends StatefulWidget {
  final NewsModel news;
  final bool isDark;

  const ImportantAlertCard({
    super.key,
    required this.news,
    required this.isDark,
  });

  @override
  State<ImportantAlertCard> createState() => _ImportantAlertCardState();
}

class _ImportantAlertCardState extends State<ImportantAlertCard> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryCrimson.withValues(alpha: 0.2 * _pulseController.value),
                blurRadius: 15 * _pulseController.value,
                spreadRadius: 2 * _pulseController.value,
              ),
            ],
          ),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () => NewsDetailsBottomSheet.show(context, widget.news),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isDark 
                ? [const Color(0xFF2D0A0E), const Color(0xFF1A1A1A)]
                : [const Color(0xFFFFF2F3), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primaryCrimson.withValues(alpha: 0.8),
              width: 2.0,
            ),
          ),
          child: Stack(
            children: [
              // Decorative background elements
              Positioned(
                right: -20,
                top: -20,
                child: Icon(
                  Icons.report_problem_outlined,
                  size: 100,
                  color: AppColors.primaryCrimson.withValues(alpha: 0.05),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryCrimson,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryCrimson.withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              const MainText(
                                'تنبيه إداري مُلزم',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const MainText(
                          'عاجل',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryCrimson,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.primaryCrimson,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MainText(
                            widget.news.newsContent,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: widget.isDark ? Colors.white : Colors.black87,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const MainText(
                          'اضغط للتفاصيل',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryCrimson,
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primaryCrimson),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
