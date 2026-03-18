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
  ConsumerState<AchievementSpotlight> createState() =>
      _AchievementSpotlightState();
}

class _AchievementSpotlightState
    extends ConsumerState<AchievementSpotlight> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  void _fetchData() {
    final selectedChild = ref.read(childRiverpod).selectedChild;
    if (selectedChild != null) {
      ref
          .read(achievementRiverpod.notifier)
          .getAchievements(selectedChild.id.toInt());
    }
  }

  @override
  Widget build(BuildContext context) {
    final achievementState = ref.watch(achievementRiverpod);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (achievementState.achievementList.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayAchievement = achievementState.achievementList.first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.stars_rounded, color: Color(0xFFFFD700), size: 18),
              ),
              const SizedBox(width: 12),
              MainText(
                'أحدث الإنجازات',
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF1E2833),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _TapWrapper(
            child: FadeInUp(
              duration: const Duration(milliseconds: 700),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
                    width: 1.5,
                  ),
                  boxShadow: isDark ? null : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -30,
                        top: -30,
                        child: Opacity(
                          opacity: isDark ? 0.05 : 0.02,
                          child: const Icon(
                            Icons.workspace_premium,
                            size: 200,
                            color: Color(0xFFFFD700),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFD700), Color(0xFFDAA520)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD700).withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.emoji_events_outlined,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),

                            const SizedBox(width: 20),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MainText(
                                    displayAchievement.participantName ?? '',
                                    color: const Color(0xFFDAA520),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                  const SizedBox(height: 6),
                                  MainText(
                                    displayAchievement.title,
                                    color: isDark ? Colors.white : const Color(0xFF1E2833),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),
                                  if (displayAchievement.date != null)
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today_rounded, size: 12, color: isDark ? Colors.white38 : Colors.grey),
                                        const SizedBox(width: 6),
                                        MainText(
                                          DateFormat('d MMMM', 'ar').format(displayAchievement.date!),
                                          color: isDark ? Colors.white38 : const Color(0xFF7A869A),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ..._buildSparkles(),
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

  List<Widget> _buildSparkles() {
    return [
      _sparkle(top: 10, left: 24, delay: 0),
      _sparkle(top: 120, left: 55, delay: 350),
      _sparkle(top: 40, right: 90, delay: 700),
      _sparkle(top: 100, right: 35, delay: 1050),
    ];
  }

  Widget _sparkle({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required int delay,
  }) {
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
          child: const Icon(
            Icons.auto_awesome,
            color: Color(0xFFFFD700),
            size: 14,
          ),
        ),
      ),
    );
  }
}

class _TapWrapper extends StatefulWidget {
  final Widget child;
  const _TapWrapper({required this.child});

  @override
  State<_TapWrapper> createState() => _TapWrapperState();
}

class _TapWrapperState extends State<_TapWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _s;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _s = Tween<double>(begin: 1.0, end: 0.97).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _c.forward(),
      onTapUp: (_) => _c.reverse(),
      onTapCancel: () => _c.reverse(),
      child: ScaleTransition(scale: _s, child: widget.child),
    );
  }
}
