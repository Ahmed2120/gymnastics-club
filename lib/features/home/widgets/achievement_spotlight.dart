import 'dart:ui' as ui;
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymnastics_club/core/theme/app_colors.dart';
import 'package:gymnastics_club/widgets/main_text.dart';
import 'package:intl/intl.dart';
import '../../achievement/achievement_controller/achievement_riverpod.dart';
import '../../profile/profile_controller/child_riverpod.dart';

class AchievementSpotlight extends ConsumerStatefulWidget {
  const AchievementSpotlight({super.key});

  @override
  ConsumerState<AchievementSpotlight> createState() => _AchievementSpotlightState();
}

class _AchievementSpotlightState extends ConsumerState<AchievementSpotlight> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() {
    final selectedChild = ref.read(childRiverpod).selectedChild;
    if (selectedChild != null) {
      ref.read(achievementRiverpod.notifier).getAchievements(selectedChild.id.toInt());
    }
  }

  @override
  Widget build(BuildContext context) {
    final achievementState = ref.watch(achievementRiverpod);

    if (achievementState.isLoading || achievementState.achievementList.isEmpty) {
      return const SizedBox.shrink();
    }

    final latest = achievementState.achievementList.first;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MainText(
                isArabic ? 'إنجازات البطل 🏆' : 'Hero Achievements 🏆',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              const Spacer(),
              ElasticIn(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.stars, color: Colors.amber, size: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InteractionWrapper(
            child: FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor,
                      const Color(0xFFE53935),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // Larger Background Icon (Opposite side of content)
                      Positioned(
                        left: isArabic ? -30 : null,
                        right: isArabic ? null : -30,
                        top: -20,
                        child: Opacity(
                          opacity: 0.1,
                          child: Icon(
                            Icons.workspace_premium,
                            size: 200,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            // Text Content
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  MainText(
                                    latest.title,
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.person, color: Colors.white, size: 12),
                                      const SizedBox(width: 4),
                                      MainText(
                                        latest.participantName ?? '',
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Directionality fix for Date
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, color: Colors.white70, size: 14),
                                      const SizedBox(width: 6),
                                      Directionality(
                                        textDirection: ui.TextDirection.ltr,
                                        child: MainText(
                                          latest.date != null ? DateFormat('dd MMM, yyyy').format(latest.date!) : '',
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            // Image or Trophy Profile
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: latest.imageUrl != null && latest.imageUrl!.isNotEmpty
                                        ? Image.network(
                                            latest.imageUrl!,
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            color: Colors.white.withOpacity(0.1),
                                            child: Pulse(
                                              child: const Icon(
                                                Icons.emoji_events,
                                                color: Colors.amber,
                                                size: 60,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
    
                      // Sparkle Particles
                      ..._buildSparkles(isArabic),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSparkles(bool isArabic) {
    return [
      _sparkle(top: 10, left: 20, delay: 0),
      _sparkle(top: 120, left: 50, delay: 300),
      _sparkle(top: 40, right: 80, delay: 600),
      _sparkle(top: 100, right: 30, delay: 900),
      _sparkle(top: 70, left: 150, delay: 1200),
      _sparkle(top: 20, right: 150, delay: 1500),
    ];
  }

  Widget _sparkle({double? top, double? left, double? right, double? bottom, required int delay}) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: FadeIn(
        delay: Duration(milliseconds: delay),
        child: Flash(
          infinite: true,
          duration: const Duration(seconds: 3),
          child: Spin(
            infinite: true,
            duration: const Duration(seconds: 10),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white54,
              size: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _InteractionWrapper extends StatefulWidget {
  final Widget child;
  const _InteractionWrapper({required this.child});

  @override
  State<_InteractionWrapper> createState() => _InteractionWrapperState();
}

class _InteractionWrapperState extends State<_InteractionWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
