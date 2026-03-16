import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gymnastics_club/core/theme/app_colors.dart';
import 'package:gymnastics_club/widgets/main_text.dart';

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
              child: Center(child: CircularProgressIndicator())
           );
        }

        final data = snapshot.data;
        final String quoteText = data?['quote_text'] ?? 'النجاح ليس صدفة، بل هو عمل شاق ومثابرة وتعلم وتضحية، وقبل كل شيء، حب لما تفعله.';
        final String authorText = data?['author'] ?? 'بيليه';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                 color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark 
                      ? Colors.white.withOpacity(0.05) 
                      : Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(isDark ? 0.1 : 0.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.format_quote, 
                      color: AppColors.primaryColor.withOpacity(0.8), 
                      size: 32
                    ),
                    const SizedBox(height: 16),
                    MainText(
                      quoteText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.center,
                      color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 1, 
                          width: 24, 
                          color: AppColors.primaryColor.withOpacity(0.3)
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: MainText(
                            authorText,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor.withOpacity(0.7),
                          ),
                        ),
                        Container(
                          height: 1, 
                          width: 24, 
                          color: AppColors.primaryColor.withOpacity(0.3)
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}
