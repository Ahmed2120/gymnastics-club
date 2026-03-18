import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gymnastics_club/widgets/main_text.dart';
import 'package:gymnastics_club/core/theme/app_colors.dart';

import '../../../core/utils/extensions/size_extensions.dart';

class MotivationCard extends StatelessWidget {
  const MotivationCard({super.key});

  Future<Map<String, dynamic>?> _fetchActiveQuote() async {
    try {
      final data = await Supabase.instance.client
          .from('motivation_quotes')
          .select()
          .eq('is_active', true)
          .maybeSingle();
      return data;
    } catch (e) {
      debugPrint('Error fetching motivation quote: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchActiveQuote(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 140,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryCrimson),
            ),
          );
        }

        final data = snapshot.data;
        final String quoteText = data?['quote_text'] ??
            'الجمباز يعلمك أن السقوط ليس النهاية، بل هو جزء من رحلتك للوصول إلى القمة. قف دائماً أقوى مما كنت.';
        final String author = data?['author'] ?? 'حكمة رياضية';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: CustomPaint(
            painter: _DashedBorderPainter(
              color: isDark ? AppColors.primaryCrimson.withOpacity(0.3) : const Color(0xFFFCA5A5).withOpacity(0.5),
              borderRadius: 40,
            ),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : const Color(0xFFFEF2F2).withOpacity(0.8),
                borderRadius: BorderRadius.circular(40),
                boxShadow: isDark ? null : [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: AppColors.energyGradient.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Icon(
                          Icons.format_quote_rounded,
                          color: AppColors.primaryCrimson,
                          size: 32,
                        ),
                      ],
                    ),
                    20.ph,
                    MainText(
                      quoteText,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      textAlign: TextAlign.center,
                      color: isDark ? Colors.white : const Color(0xFF374151),
                      height: 1.6,
                    ),
                    20.ph,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 20, height: 1.5, color: AppColors.primaryCrimson.withOpacity(0.3)),
                        12.pw,
                        MainText(
                          author,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryCrimson,
                          letterSpacing: 0.5,
                        ),
                        12.pw,
                        Container(width: 20, height: 1.5, color: AppColors.primaryCrimson.withOpacity(0.3)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;

  _DashedBorderPainter({required this.color, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

    double dashWidth = 8, dashSpace = 5, distance = 0;
    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
