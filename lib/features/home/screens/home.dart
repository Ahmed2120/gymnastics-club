import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/costants/app_assets.dart';
import '../../../core/costants/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../../../widgets/main_text.dart';
import '../../../data/models/models/news_model.dart';
import '../news_controller/news_riverpod.dart';
import '../../profile/profile_controller/child_riverpod.dart';
import '../../schedule/schedule_controller/schedule_riverpod.dart';
import '../widgets/quick_actions.dart';
import '../widgets/training_countdown.dart';
import '../widgets/achievement_spotlight.dart';
import '../widgets/motivation_card.dart';
import '../widgets/animated_like_button.dart';
import '../../../widgets/full_screen_viewer.dart';
import '../widgets/news_details_bottom_sheet.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchNews();
    _fetchChildData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(newsRiverpod.notifier).loadMoreNews();
    }
  }

  void _fetchNews({bool force = false}) {
    Future.microtask(() {
      final children = ref.read(childRiverpod).childrenList;
      final groupIds = children.map((c) => c.groupId).toList();
      ref.read(newsRiverpod.notifier).getNews(groupIds: groupIds, force: force);
    });
  }

  void _fetchChildData() {
    Future.microtask(() {
      final child = ref.read(childRiverpod).selectedChild;
      if (child != null) {
        ref.read(scheduleRiverpod.notifier).getSchedule(child.groupId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(childRiverpod, (previous, next) {
      if (previous?.selectedChild?.id != next.selectedChild?.id) {
        _fetchChildData();
      }
      if ((previous == null || previous.childrenList.isEmpty) &&
          next.childrenList.isNotEmpty) {
        _fetchNews(force: true);
      }
    });

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8F9FA),
      body: Consumer(
        builder: (context, ref, child) {
          final newsState = ref.watch(newsRiverpod);
          final childState = ref.watch(childRiverpod);
          final user = childState.selectedChild;
          final newsList = newsState.newsList;

          bool isImportant(NewsModel news) {
            final type = news.type?.toLowerCase() ?? '';
            return type == 'warning' ||
                type == 'تنبيه مهم' ||
                type == 'تنلبه مهم' ||
                type == 'تعديل جدول';
          }

          // Search the entire list for the most recent important news
          final featuredNews = newsList.where((news) => isImportant(news)).firstOrNull;
          final showFeaturedAtTop = featuredNews != null;

          return RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: () async {
              await ref.read(childRiverpod.notifier).getChildren();
              _fetchNews(force: true);
              _fetchChildData();
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBackground : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
                          blurRadius: 25,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                        child: Row(
                          children: [
                            // ── 1. Avatar (Left) ──
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: isDark ? AppColors.energyGradient : null,
                                border: isDark ? null : Border.all(
                                  color: AppColors.primaryColor.withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark ? AppColors.darkBackground : Colors.white,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    if (user?.imageUrl != null) {
                                      FullScreenImageViewer.open(
                                        context,
                                        NetworkImage(user!.imageUrl!),
                                        'profile_avatar_header',
                                      );
                                    }
                                  },
                                  child: Hero(
                                    tag: 'profile_avatar_header',
                                    child: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: isDark ? AppColors.darkSurface : AppColors.primaryColor.withOpacity(0.05),
                                      backgroundImage: user?.imageUrl != null
                                          ? NetworkImage(user!.imageUrl!)
                                          : const AssetImage(AppAssets.userPlaceholder)
                                              as ImageProvider,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            // ── 2. Greeting (Center) ──
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      MainText(
                                        user?.name != null
                                            ? 'مرحباً، ${user!.name}'
                                            : 'مرحباً يا بطل',
                                        color: isDark ? Colors.white : Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                      const SizedBox(width: 6),
                                      const MainText('👋', fontSize: 18),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  MainText(
                                    'جاهز للتدريب اليوم؟',
                                    color: isDark ? Colors.white54 : Colors.grey[600],
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ],
                              ),
                            ),

                            // ── 3. Logo (Right) ──
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? AppColors.darkSurface : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.12),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  AppIcons.logo,
                                  height: 44,
                                  width: 44,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── 2. Quick Actions ──
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: QuickActions(),
                  ),
                ),

                // ── 3. Featured Important News (Top Priority) ──
                if (showFeaturedAtTop)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                    sliver: SliverToBoxAdapter(
                      child: _TapWrapper(
                        child: _buildLargeNewsCard(featuredNews, isDark, isFeatured: true),
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),

                // ── 7. Upcoming Training Section ──
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MainText(
                          'التدريبات القادمة',
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        const SizedBox(height: 20),
                        const TrainingCountdown(),
                      ],
                    ),
                  ),
                ),

                // ── 4. Recent Achievement Spotlight ──
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 32),
                    child: AchievementSpotlight(),
                  ),
                ),

                // ── 5. News Section Header ──
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MainText(
                          'أخبار النادي',
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ],
                    ),
                  ),
                ),

                // ── 6. Horizontal News Carousel ──
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 400,
                    child: newsState.isLoading
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: MainShimmer.single(height: 400),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: newsState.newsList.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: _buildLargeNewsCard(
                                    newsState.newsList[index], isDark),
                              );
                            },
                          ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),

                // ── 8. Motivation Card ──
                const SliverToBoxAdapter(child: MotivationCard()),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLargeNewsCard(NewsModel news, bool isDark, {bool isFeatured = false}) {
    final bool hasImage = news.imageUrl != null && news.imageUrl!.isNotEmpty;
    final type = news.type?.toLowerCase() ?? '';
    final isWarning = type == 'warning' ||
        type == 'تنبيه مهم' ||
        type == 'تنلبه مهم' ||
        type == 'تعديل جدول';

    return Container(
      width: isFeatured ? double.infinity : 320,
      height: 360,
      margin: EdgeInsets.only(bottom: isFeatured ? 0 : 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image Section ──
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (!hasImage) return;
                      FullScreenImageViewer.open(
                        context,
                        CachedNetworkImageProvider(news.imageUrl!),
                        'news_${news.id}',
                      );
                    },
                    child: Hero(
                      tag: 'news_${news.id}',
                      child: hasImage
                          ? CachedNetworkImage(
                              imageUrl: news.imageUrl!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Image.asset(
                                AppAssets.newsPlaceholder,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              AppAssets.newsPlaceholder,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  // Heart Overlay (Top Left)
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _buildLikeButton(news, isSmall: true),
                    ),
                  ),
                  // Warning Badge Overlay if featured
                  if (isWarning)
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkBackground.withValues(alpha: 0.9) : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: AppColors.primaryCrimson, size: 14),
                            const SizedBox(width: 4),
                            MainText(
                              news.type ?? 'تنبيه مهم',
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryCrimson,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Content Section ──
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category/Type (if not warning)
                  if (!isWarning || !hasImage)
                    MainText(
                      news.type ?? 'مسابقات',
                      color: AppColors.primaryCrimson,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  if (!isWarning || !hasImage) const SizedBox(height: 8),
                  // Title
                  MainText(
                    news.title,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    height: 1.3,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  const SizedBox(height: 12),
                  // Snippet + Read More
                  _NewsContentPreview(news: news, isDark: isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLikeButton(NewsModel news, {bool isSmall = false}) {
    return AnimatedLikeButton(
      isLiked: news.isLiked,
      likesCount: news.likesCount,
      isSmall: isSmall,
      onTap: () => ref.read(newsRiverpod.notifier).toggleLike(news.id),
    );
  }
}

// ── Truncated text preview with "اقرأ المزيد" that opens bottom sheet ──
class _NewsContentPreview extends StatelessWidget {
  final NewsModel news;
  final bool isDark;

  const _NewsContentPreview({required this.news, required this.isDark});

  @override
  Widget build(BuildContext context) {
    const int threshold = 75;
    final isLong = news.newsContent.length > threshold;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MainText(
          isLong
              ? '${news.newsContent.substring(0, threshold)}...'
              : news.newsContent,
          fontSize: 15,
          color: isDark ? Colors.grey[400] : const Color(0xFF555555),
          height: 1.6,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (isLong)
          GestureDetector(
            onTap: () => NewsDetailsBottomSheet.show(context, news),
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MainText(
                    'اقرأ المزيد',
                    color: AppColors.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_downward_rounded,
                    size: 14,
                    color: AppColors.primaryColor,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ── Tap scale wrapper ──
class _TapWrapper extends StatefulWidget {
  final Widget child;
  const _TapWrapper({required this.child});

  @override
  State<_TapWrapper> createState() => _TapWrapperState();
}

class _TapWrapperState extends State<_TapWrapper>
    with SingleTickerProviderStateMixin {
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
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
