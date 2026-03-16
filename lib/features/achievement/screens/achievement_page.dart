import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymnastics_club/core/theme/app_colors.dart';
import 'package:gymnastics_club/features/achievement/achievement_controller/achievement_riverpod.dart';
import 'package:gymnastics_club/features/profile/profile_controller/child_riverpod.dart';

import '../../../data/models/models/achievement_model.dart';
import '../../../widgets/main_text.dart';
import '../../../widgets/shimmer_widgets.dart';

class AchievementPage extends ConsumerStatefulWidget {
  const AchievementPage({super.key});

  @override
  ConsumerState<AchievementPage> createState() => _AchievementPageState();
}

class _AchievementPageState extends ConsumerState<AchievementPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _headerAnimController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _headerFade = CurvedAnimation(
      parent: _headerAnimController,
      curve: Curves.easeOut,
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerAnimController,
      curve: Curves.easeOut,
    ));
    _pulseScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _headerAnimController.forward();
    _fetchData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final child = ref.read(childRiverpod).selectedChild;
      if (child != null) {
        ref.read(achievementRiverpod.notifier).loadMoreAchievements(child.id);
      }
    }
  }

  void _fetchData() {
    Future.microtask(() {
      final child = ref.read(childRiverpod).selectedChild;
      if (child != null) {
        ref.read(achievementRiverpod.notifier).getAchievements(child.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(childRiverpod, (previous, next) {
      if (previous?.selectedChild?.id != next.selectedChild?.id) {
        _fetchData();
      }
    });

    final achievementState = ref.watch(achievementRiverpod);
    final achievements = achievementState.achievementList;

    return Scaffold(
      body: Stack(
        children: [
          const SparkleEffect(),
          RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: () async => _fetchData(),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // 1. Hero HUD Header
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _headerFade,
                child: SlideTransition(
                  position: _headerSlide,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Decorative Glass Element
                        Positioned(
                          top: -60,
                          left: -60,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                        ),
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                            child: Column(
                              children: [
                                // Child Profile Section
                                Consumer(
                                  builder: (context, ref, child) {
                                    final selectedChild = ref.watch(childRiverpod).selectedChild;
                                    final xp = (_getCount(achievements, 'gold') * 10) + (_getCount(achievements, 'silver') * 5) + (_getCount(achievements, 'bronze') * 2);
                                    
                                    String rank;
                                    if (xp >= 70) {
                                      rank = 'بطل النخبة 💎';
                                    } else if (xp >= 30) {
                                      rank = 'محترف جمباز 🏆';
                                    } else {
                                      rank = 'نجم صاعد ✨';
                                    }

                                    return Column(
                                      children: [
                                        Row(
                                          children: [
                                            ScaleTransition(
                                              scale: _pulseScale,
                                              child: Container(
                                                padding: const EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.white.withOpacity(0.1),
                                                      blurRadius: 15,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                                                ),
                                                child: CircleAvatar(
                                                  radius: 35,
                                                  backgroundColor: Colors.white24,
                                                  backgroundImage: selectedChild?.imageUrl != null
                                                      ? NetworkImage(selectedChild!.imageUrl!)
                                                      : null,
                                                  child: selectedChild?.imageUrl == null
                                                      ? const Icon(Icons.person, color: Colors.white, size: 40)
                                                      : null,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  MainText(
                                                    selectedChild?.name ?? 'البطل',
                                                    color: Colors.white,
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: MainText(
                                                      rank,
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),
                                // Medal Stats HUD
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildStatItem('ذهب', _getCount(achievements, 'gold'), const Color(0xFFFFD700)),
                                      _buildStatDivider(),
                                      _buildStatItem('فضة', _getCount(achievements, 'silver'), const Color(0xFFC0C0C0)),
                                      _buildStatDivider(),
                                      _buildStatItem('برونز', _getCount(achievements, 'bronze'), const Color(0xFFCD7F32)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 2. Achievements List
            if (achievementState.isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: MainShimmer.achievementCard(),
                ),
              )
            else if (achievements.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 72,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      MainText(
                        'لا يوجد إنجازات لهذا البطل حالياً',
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == achievements.length) {
                        return achievementState.isLoadingMore
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: MainShimmer.single(height: 100),
                              )
                            : const SizedBox.shrink();
                      }
                      final item = achievements[index];
                      return _AchievementCard(
                        item: item,
                        index: index,
                        isDark: isDark,
                      );
                    },
                    childCount: achievements.length +
                        (achievementState.isLoadingMore ? 1 : 0),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    ],
  ),
);
}

  int _getCount(List<AchievementModel> achievements, String type) {
    return achievements.where((a) {
      final t = a.championType?.toLowerCase() ?? '';
      if (type == 'gold') return t == 'gold' || t == 'ذهب';
      if (type == 'silver') return t == 'silver' || t == 'فضة';
      if (type == 'bronze') return t == 'bronze' || t == 'برونز';
      return false;
    }).length;
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        MainText(
          count.toString(),
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.5), blurRadius: 4, spreadRadius: 1),
                ],
              ),
            ),
            const SizedBox(width: 6),
            MainText(
              label,
              color: Colors.white60,
              fontSize: 12,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white12,
    );
  }
}

// ─── Achievement Card Widget ───────────────────────────────────────────────────

class _AchievementCard extends StatefulWidget {
  final AchievementModel item;
  final int index;
  final bool isDark;

  const _AchievementCard({
    required this.item,
    required this.index,
    required this.isDark,
  });

  @override
  State<_AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<_AchievementCard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _clickController;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;
  late Animation<double> _scale;
  late Animation<double> _rotate; // Added for 3D effect

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700), // Slightly longer for 3D
    );
    _clickController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _opacity = CurvedAnimation(parent: _fadeController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut));
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _scale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.elasticOut),
    );
    _rotate = Tween<double>(begin: 0.15, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    // Tap scale animation
    _clickController.addListener(() {}); // Ensure it rebuilds if needed

    // Stagger based on index
    final delay = Duration(milliseconds: 80 * (widget.index.clamp(0, 6)));
    Future.delayed(delay, () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _clickController.dispose();
    super.dispose();
  }

  Color _getMedalColor(String? championType) {
    switch (championType?.toLowerCase()) {
      case 'gold':
      case 'ذهب':
        return const Color(0xFFFFD700);
      case 'silver':
      case 'فضة':
        return const Color(0xFFC0C0C0);
      case 'bronze':
      case 'برونز':
        return const Color(0xFFCD7F32);
      default:
        return const Color(0xFF7C6AF7);
    }
  }

  IconData _getMedalIcon(String? championType) {
    switch (championType?.toLowerCase()) {
      case 'gold':
      case 'ذهب':
      case 'silver':
      case 'فضة':
      case 'bronze':
      case 'برونز':
        return Icons.emoji_events_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isDark = widget.isDark;
    final hasImage = item.imageUrl != null && item.imageUrl!.isNotEmpty;
    final medalColor = _getMedalColor(item.championType);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: GestureDetector(
            onTapDown: (_) => _clickController.forward(),
            onTapUp: (_) {
              _clickController.reverse();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AchievementDetailScreen(item: item, isDark: isDark),
                ),
              );
            },
            onTapCancel: () => _clickController.reverse(),
            child: AnimatedBuilder(
              animation: _fadeController,
              builder: (context, child) {
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // Perspective
                    ..rotateX(_rotate.value) // Flip-up effect
                    ..scale(_scale.value), // Use the elastic scale animation
                  alignment: Alignment.center,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 1.0, end: 0.97).animate(
                      CurvedAnimation(parent: _clickController, curve: Curves.easeOut),
                    ),
                    child: child,
                  ),
                );
              },
              child: Hero(
                tag: 'achievement_${item.id}',
                child: Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: medalColor.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: medalColor.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Achievement Image (if available)
                        if (hasImage)
                          Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: item.imageUrl!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  height: 200,
                                  color: isDark
                                      ? const Color(0xFF2A2A2A)
                                      : Colors.grey[100],
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              ),
                              // Medal Type Badge on Image
                              Positioned(
                                top: 16,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: medalColor.withOpacity(0.5), width: 1),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.stars, color: medalColor, size: 14),
                                      const SizedBox(width: 4),
                                      MainText(
                                        item.championType ?? '',
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                        // Card Body
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MainText(
                                      item.title,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.person, size: 12, color: AppColors.primaryColor.withOpacity(0.6)),
                                        const SizedBox(width: 4),
                                        MainText(
                                          item.participantName ?? '',
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        if (item.date != null)
                                          _InfoBadge(
                                            icon: Icons.calendar_today_rounded,
                                            text: DateFormat('d MMMM yyyy', 'ar').format(item.date!),
                                            isDark: isDark,
                                          ),
                                        const SizedBox(width: 12),
                                        if (item.venue != null && item.venue!.isNotEmpty)
                                          _InfoBadge(
                                            icon: Icons.pin_drop_rounded,
                                            text: item.venue!,
                                            isDark: isDark,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: medalColor.withOpacity(0.1),
                                ),
                                child: Icon(
                                  _getMedalIcon(item.championType),
                                  color: medalColor,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;

  const _InfoBadge({required this.icon, required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey),
          const SizedBox(width: 6),
          MainText(text, fontSize: 11, color: Colors.grey),
        ],
      ),
    );
  }
}

class AchievementDetailScreen extends StatelessWidget {
  final AchievementModel item;
  final bool isDark;

  const AchievementDetailScreen({super.key, required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final medalColor = _getMedalColor(item.championType);
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F6FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF1A1A1A) : AppColors.primaryColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'achievement_${item.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (item.imageUrl != null)
                      CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: medalColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: medalColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.emoji_events, color: medalColor, size: 18),
                            const SizedBox(width: 8),
                            MainText(
                              item.championType?.toUpperCase() ?? 'AWARD',
                              color: medalColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {}, // Simulated Share
                        icon: const Icon(Icons.ios_share, color: AppColors.primaryColor),
                        tooltip: 'Share Achievement',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  MainText(
                    item.title,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 40),
                  _DetailRow(icon: Icons.calendar_today, label: 'التاريخ', value: item.date != null ? DateFormat('d MMMM yyyy', 'ar').format(item.date!) : '-'),
                  _DetailRow(icon: Icons.location_on, label: 'المكان', value: item.venue ?? '-'),
                  _DetailRow(icon: Icons.person, label: 'المشارك', value: item.participantName ?? '-'),
                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.verified_user_rounded, color: Colors.green, size: 48),
                        const SizedBox(height: 16),
                        MainText(
                          'شهادة إنجاز معتمدة',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 8),
                        MainText(
                          'تم توثيق هذا الإنجاز بنجاح في سجلات النادي',
                          color: Colors.grey,
                          fontSize: 14,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMedalColor(String? type) {
    final t = type?.toLowerCase() ?? '';
    if (t == 'gold' || t == 'ذهب') return const Color(0xFFFFD700);
    if (t == 'silver' || t == 'فضة') return const Color(0xFFC0C0C0);
    if (t == 'bronze' || t == 'برونز') return const Color(0xFFCD7F32);
    return Colors.blue;
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MainText(label, color: Colors.grey, fontSize: 12),
              const SizedBox(height: 4),
              MainText(value, fontSize: 16, fontWeight: FontWeight.bold),
            ],
          ),
        ],
      ),
    );
  }
}

class SparkleEffect extends StatefulWidget {
  const SparkleEffect({super.key});

  @override
  State<SparkleEffect> createState() => _SparkleEffectState();
}

class _SparkleEffectState extends State<SparkleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = List.generate(20, (index) => Particle());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        for (var p in _particles) {
          p.update();
        }
        return CustomPaint(
          painter: ParticlePainter(_particles),
          child: Container(),
        );
      },
    );
  }
}

class Particle {
  double x = 0;
  double y = 0;
  double size = 0;
  double velocity = 0;
  double opacity = 0;

  Particle() {
    reset();
  }

  void reset() {
    final random = DateTime.now().microsecondsSinceEpoch;
    x = (random % 400).toDouble() / 400;
    y = 1.0;
    size = (random % 3 + 1).toDouble();
    velocity = (random % 10 + 5).toDouble() / 10000;
    opacity = (random % 50 + 10).toDouble() / 100;
  }

  void update() {
    y -= velocity;
    if (y < 0) reset();
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    for (var p in particles) {
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        paint..color = Colors.white.withOpacity(p.opacity),
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
