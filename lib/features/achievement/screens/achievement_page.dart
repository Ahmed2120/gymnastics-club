import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymnastics_club/core/theme/app_colors.dart';
import 'package:gymnastics_club/features/achievement/achievement_controller/achievement_riverpod.dart';
import 'package:gymnastics_club/features/profile/profile_controller/child_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/models/models/achievement_model.dart';
import '../../../widgets/main_text.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../widgets/achievement_stats_hud.dart';
import '../widgets/pulsing_avatar.dart';
import '../../../widgets/custom_app_bar_button.dart';

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

  @override
  void initState() {
    super.initState();
    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

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

    _headerAnimController.forward();
    _fetchData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
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
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: MainText(
          "إنجازات البطل",
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppColors.lightText,
        ),
      ),
      body: Stack(
        children: [
          const SparkleEffect(),
          RefreshIndicator(
            color: AppColors.primaryCrimson,
            onRefresh: () async => _fetchData(),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _headerFade,
                    child: SlideTransition(
                      position: _headerSlide,
                      child: SafeArea(
                        child: Column(
                          children: [

                            const SizedBox(height: 20),

                            Consumer(
                              builder: (context, ref, child) {
                                final selectedChild = ref.watch(childRiverpod).selectedChild;
                                final achievements = ref.watch(achievementRiverpod).achievementList;

                                final goldCount = _getCount(achievements, 'gold');
                                final silverCount = _getCount(achievements, 'silver');
                                final bronzeCount = _getCount(achievements, 'bronze');


                                return Column(
                                  children: [
                                    PulsingAvatar(
                                      imageUrl: selectedChild?.imageUrl,
                                      level: selectedChild?.level ?? '',
                                      radius: 65,
                                    ),
                                    const SizedBox(height: 20),
                                    MainText(
                                      selectedChild?.name ?? 'Ø§Ù„Ø¨Ø·Ù„',
                                      color: isDark ? Colors.white : AppColors.lightText,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                    ),
                                    const SizedBox(height: 24),

                                    AchievementStatsHUD(
                                      goldCount: goldCount,
                                      silverCount: silverCount,
                                      bronzeCount: bronzeCount,
                                    ),
                                    const SizedBox(height: 32),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                if (achievementState.isLoading)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: MainShimmer.achievementCard(),
                    ),
                  )
                else if (achievements.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.emoji_events_outlined,
                            size: 80,
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200],
                          ),
                          const SizedBox(height: 24),
                          MainText(
                            "لا يوجد إنجازات لهذا البطل حالياً",
                            color: isDark ? Colors.white24 : Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == achievements.length) {
                            return achievementState.isLoadingMore
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 24),
                                    child: MainShimmer.single(height: 120),
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
      if (type == 'gold') return t == 'gold' || t == '???';
      if (type == 'silver') return t == 'silver' || t == '???';
      if (type == 'bronze') return t == 'bronze' || t == '?????';
      return false;
    }).length;
  }
}

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
  late Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
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
      case '???':
        return AppColors.achievementGold;
      case 'silver':
      case '???':
        return const Color(0xFFC0C0C0);
      case 'bronze':
      case '?????':
        return const Color(0xFFCD7F32);
      default:
        return AppColors.primaryCrimson;
    }
  }

  IconData _getMedalIcon(String? championType) {
    switch (championType?.toLowerCase()) {
      case 'gold':
      case '???':
      case 'silver':
      case '???':
      case 'bronze':
      case '?????':
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
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;

    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
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
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(_rotate.value)
                    ..scale(_scale.value),
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
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
                      width: 1.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                  color: isDark ? const Color(0xFF1E1414) : Colors.grey[100],
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryCrimson),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 16,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(color: medalColor.withOpacity(0.5), width: 1.5),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.stars_rounded, color: medalColor, size: 16),
                                      const SizedBox(width: 6),
                                      MainText(
                                        item.championType ?? '',
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: medalColor.withOpacity(0.12),
                                      border: Border.all(color: medalColor.withOpacity(0.2), width: 1),
                                    ),
                                    child: Icon(
                                      _getMedalIcon(item.championType),
                                      color: medalColor,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        MainText(
                                          item.title,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: isDark ? Colors.white : Colors.black87,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Icon(Icons.person_rounded, size: 14, color: AppColors.primaryCrimson.withOpacity(0.6)),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: MainText(
                                                item.participantName ?? '',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: isDark ? Colors.white54 : Colors.grey[600],
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  if (item.date != null)
                                    Expanded(
                                      child: _InfoBadge(
                                        icon: Icons.calendar_today_rounded,
                                        text: DateFormat('d MMMM yyyy', 'ar').format(item.date!),
                                        isDark: isDark,
                                      ),
                                    ),
                                  if (item.date != null && item.venue != null && item.venue!.isNotEmpty)
                                    const SizedBox(width: 12),
                                  if (item.venue != null && item.venue!.isNotEmpty)
                                    Expanded(
                                      child: _InfoBadge(
                                        icon: Icons.location_on_rounded,
                                        text: item.venue!,
                                        isDark: isDark,
                                      ),
                                    ),
                                ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryCrimson.withOpacity(0.5)),
          const SizedBox(width: 8),
          Flexible(
            child: MainText(
              text, 
              fontSize: 12, 
              color: isDark ? Colors.white38 : Colors.grey[600],
              fontWeight: FontWeight.w700,
            ),
          ),
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
    final bgColor = isDark ? AppColors.darkBackground : const Color(0xFFF5F6FA);
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            expandedHeight: 320,
            leadingWidth: 72,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              child: CustomAppBarButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onPressed: () => Navigator.pop(context),
                iconColor: AppColors.primaryCrimson,
                backgroundColor: AppColors.primaryCrimson.withOpacity(0.12),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                child: CustomAppBarButton(
                  icon: Icons.share_rounded,
                  onPressed: () {},
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 80, bottom: 16, right: 16),
              title: MainText(
                'تفاصيل الإنجاز',
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
              background: Hero(
                tag: 'achievement_${item.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 100,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: medalColor.withOpacity(0.5), width: 1.2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stars_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            MainText(
                              item.championType ?? '',
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
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

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.08),
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: medalColor.withOpacity(0.12),
                                  border: Border.all(color: medalColor.withOpacity(0.3), width: 1),
                                ),
                                child: Icon(Icons.emoji_events_rounded, color: medalColor, size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MainText(
                                      item.title,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                    const SizedBox(height: 6),
                                    MainText(
                                      item.participantName ?? '',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white54 : Colors.grey[600],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _InfoBadge(
                                icon: Icons.calendar_today_rounded,
                                text: item.date != null
                                    ? DateFormat('d MMMM yyyy', 'ar').format(item.date!)
                                    : '-',
                                isDark: isDark,
                              ),
                              if (item.venue != null && item.venue!.isNotEmpty)
                                _InfoBadge(
                                  icon: Icons.location_on_rounded,
                                  text: item.venue!,
                                  isDark: isDark,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.08),
                        width: 1.3,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryCrimson.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.location_on_rounded, color: AppColors.primaryCrimson, size: 22),
                            ),
                            const SizedBox(width: 12),
                            MainText(
                              'المكان',
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        MainText(
                          item.venue ?? '?? ???? ??? ???? ???? ???????.',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : Colors.grey[700],
                        ),
                        const SizedBox(height: 20),
                        _DetailRow(
                          icon: Icons.verified_rounded,
                          label: 'نوع الميدالية',
                          value: (item.championType ?? 'إنجاز').toUpperCase(),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.08),
                        width: 1.3,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.verified_user_rounded, color: Colors.green, size: 48),
                        ),
                        const SizedBox(height: 18),
                        MainText(
                          'شهادة إنجاز معتمدة',
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        const SizedBox(height: 10),
                        MainText(
                          'تم توثيق هذا الإنجاز في سجلات النادي، فخراً بك يا بطل!',
                          color: isDark ? Colors.white54 : Colors.grey[600],
                          fontSize: 14,
                          textAlign: TextAlign.center,
                          fontWeight: FontWeight.w700,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMedalColor(String? type) {
    if (type == 'gold' || type == 'ذهب') return AppColors.achievementGold;
    if (type == 'silver' || type == 'فضة') return const Color(0xFFC0C0C0);
    if (type == 'bronze' || type == 'برونز') return const Color(0xFFCD7F32);
    return AppColors.primaryCrimson;
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _DetailRow({required this.icon, required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryCrimson.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primaryCrimson, size: 24),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MainText(label, color: isDark ? Colors.white38 : Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w700),
              const SizedBox(height: 6),
              MainText(value, fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87),
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
        return CustomPaint(
          painter: SparklePainter(_particles),
          size: Size.infinite,
        );
      },
    );
  }
}

class Particle {
  double x = 0;
  double y = 0;
  double size = 0;
  double speed = 0;
  double opacity = 0;
  final _random = Random();

  Particle() {
    reset();
  }

  void reset() {
    x = _random.nextDouble();
    y = _random.nextDouble() + 1.0;
    size = _random.nextDouble() * 3 + 1;
    speed = _random.nextDouble() * 0.002 + 0.001;
    opacity = _random.nextDouble() * 0.5 + 0.2;
  }

  void update() {
    y -= speed;
    if (y < -0.1) reset();
  }
}

class SparklePainter extends CustomPainter {
  final List<Particle> particles;

  SparklePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var p in particles) {
      p.update();
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        paint..color = Colors.white.withOpacity(p.opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}



