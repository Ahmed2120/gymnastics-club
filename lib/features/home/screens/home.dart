import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/costants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_converter.dart';
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'صباح الخير';
    } else if (hour >= 12 && hour < 17) {
      return 'طاب يومك';
    } else if (hour >= 17 && hour < 21) {
      return 'مساء الخير';
    } else {
      return 'ليلة سعيدة';
    }
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
      body: Consumer(
        builder: (context, ref, child) {
          final newsState = ref.watch(newsRiverpod);
          final childState = ref.watch(childRiverpod);
          final user = childState.selectedChild;

          final newsList = newsState.newsList;
          final firstNews = newsList.isNotEmpty ? newsList.first : null;

          // Helper to check if news is "Important" or "Schedule Change"
          bool isImportant(NewsModel? news) {
            if (news == null) return false;
            final type = news.type?.toLowerCase() ?? '';
            return type == 'warning' || 
                   type == 'تنبيه مهم' || 
                   type == 'تنلبه مهم' || 
                   type == 'تعديل جدول';
          }

          final showFeaturedAtTop = isImportant(firstNews);

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(childRiverpod.notifier).getChildren();
              _fetchNews(force: true);
              _fetchChildData();
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // 1. Curved Dark Navy Header with HUD style
                SliverToBoxAdapter(
                  child: Container(
                    height: 200,
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
                        // Decorative Glass Circle
                        Positioned(
                          top: -50,
                          right: -50,
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
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                                  ),
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.white24,
                                    backgroundImage: user?.imageUrl != null
                                        ? NetworkImage(user!.imageUrl!)
                                        : const AssetImage(AppAssets.userPlaceholder) as ImageProvider,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      MainText(
                                        user?.name != null ? 'مرحباً يا بطل، ${user!.name}' : 'مرحباً يا بطل',
                                        color: Colors.white,
                                        fontSize: 20,
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
                                          '${_getGreeting()} 👋',
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.notifications_none,
                                        color: Colors.white, size: 26),
                                    onPressed: () {},
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

                // 2. Quick Actions Strip
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: QuickActions(),
                  ),
                ),

                // 3. Achievement Spotlight
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: AchievementSpotlight(),
                  ),
                ),

                // 4. Featured News at Top (if important)
                if (showFeaturedAtTop)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: _InteractionWrapper(
                        child: _buildFeaturedCard(firstNews!, isDark),
                      ),
                    ),
                  ),

                // 3. Upcoming Training (Schedule)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const MainText(
                          'التدريبات القادمة',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 16),
                        _buildUpcomingTraining(ref, isDark),
                        const SizedBox(height: 24),
                        if (newsState.newsList.length > (showFeaturedAtTop ? 1 : 0))
                          const MainText(
                            'آخر الأخبار',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        if (newsState.newsList.length > (showFeaturedAtTop ? 1 : 0))
                          const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // 4. Featured News below Schedule (if NOT important)
                if (!showFeaturedAtTop && newsState.newsList.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _InteractionWrapper(
                          child: _buildFeaturedCard(newsState.newsList.first, isDark),
                        ),
                      ),
                    ),
                  ),

                if (newsState.isLoading)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: MainShimmer.single(height: 250),
                    ),
                  ),

                // 5. Side News List
                SliverPadding(
                   padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == 0 && newsState.newsList.isNotEmpty) {
                          return const SizedBox.shrink();
                        }
                        // Adjust index because we skip the first one for featured card
                        final newsIndex = index;
                        if (newsIndex >= newsState.newsList.length) {
                          return newsState.isLoadingMore
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: MainShimmer.single(height: 80),
                                )
                              : const SizedBox.shrink();
                        }
                        return _InteractionWrapper(
                          child: _buildSmallNewsItem(newsState.newsList[newsIndex], isDark),
                        );
                      },
                      childCount: newsState.newsList.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 40),
                ),

                // 8. Motivation Card
                const SliverToBoxAdapter(
                  child: MotivationCard(),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedCard(NewsModel news, bool isDark) {
    final type = news.type?.toLowerCase() ?? '';
    final isWarning = type == 'warning' || 
                      type == 'تنبيه مهم' || 
                      type == 'تنلبه مهم' || 
                      type == 'تعديل جدول';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.imageUrl != null && news.imageUrl!.isNotEmpty)
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: news.imageUrl!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 220,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 220,
                      color: Colors.grey[200],
                      child: const Icon(Icons.error),
                    ),
                  ),
                  if (isWarning)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            MainText(
                              type == 'تعديل جدول' ? 'تعديل جدول' : 'تنبيه',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MainText(
                    news.title,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: MainText(
                          news.newsContent,
                          fontSize: 14,
                          color: Colors.grey[600],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildLikeButton(news),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTraining(WidgetRef ref, bool isDark) {
    return const TrainingCountdown();
  }


  Widget _buildSmallNewsItem(NewsModel news, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            if (news.imageUrl != null && news.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: news.imageUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.newspaper, color: Colors.grey),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MainText(
                    news.title,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MainText(
                        DateConverter.timeAgoSinceDate(news.publishDate),
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      _buildLikeButton(news, isSmall: true),
                    ],
                  ),
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
