import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/costants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/models/news_model.dart';
import '../../../core/utils/date_converter.dart';
import '../../../widgets/main_text.dart';
import '../../../widgets/full_screen_viewer.dart';
import '../news_controller/news_riverpod.dart';
import 'animated_like_button.dart';

/// A premium draggable bottom sheet that displays full news details.
class NewsDetailsBottomSheet extends StatelessWidget {
  final NewsModel news;

  const NewsDetailsBottomSheet({super.key, required this.news});

  /// Opens the bottom sheet with a smooth slide-up animation.
  static void show(BuildContext context, NewsModel news) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => NewsDetailsBottomSheet(news: news),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool hasImage = news.imageUrl != null && news.imageUrl!.isNotEmpty;
    final type = news.type?.toLowerCase() ?? '';
    final isWarning = type == 'warning' ||
        type == 'تنبيه مهم' ||
        type == 'تنلبه مهم' ||
        type == 'تعديل جدول';

    return DraggableScrollableSheet(
      initialChildSize: hasImage ? 0.85 : 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBackground : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 30,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.zero,
              children: [
                // ── Drag Handle ──
                _buildDragHandle(isDark),

                // ── Image ──
                _buildImage(context, isDark),

                // ── Content ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type badge
                      _buildTypeBadge(isDark, isWarning),
                      const SizedBox(height: 14),

                      // Title
                      MainText(
                        news.title,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1.4,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      const SizedBox(height: 8),

                      // Date & duration row
                      _buildMetaRow(isDark),
                      const SizedBox(height: 20),

                      // Divider
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              (isDark ? Colors.white12 : Colors.black12),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Full content
                      MainText(
                        news.newsContent,
                        fontSize: 16,
                        color: isDark ? Colors.grey[300] : const Color(0xFF444444),
                        height: 1.8,
                      ),
                      const SizedBox(height: 28),

                      // Like button row
                      _buildLikeRow(isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Drag Handle ───
  Widget _buildDragHandle(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 6),
        child: Container(
          width: 40,
          height: 4.5,
          decoration: BoxDecoration(
            color: isDark ? Colors.white24 : Colors.grey[350],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ─── Image Section ───
  Widget _buildImage(BuildContext context, bool isDark) {
    final hasValidImage = news.imageUrl != null && news.imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (!hasValidImage) return; // Disallow full-screening the placeholder
        FullScreenImageViewer.open(
          context,
          CachedNetworkImageProvider(news.imageUrl!),
          'news_detail_${news.id}',
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        constraints: const BoxConstraints(maxHeight: 280),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? Colors.black26 : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Hero(
            tag: 'news_detail_${news.id}',
            child: hasValidImage
                ? CachedNetworkImage(
                    imageUrl: news.imageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Image.asset(
                      AppAssets.newsPlaceholder,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    AppAssets.newsPlaceholder,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
      ),
    );
  }

  // ─── Type Badge ───
  Widget _buildTypeBadge(bool isDark, bool isWarning) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isWarning
            ? AppColors.primaryCrimson.withValues(alpha: 0.12)
            : (isDark
                ? AppColors.primaryCrimson.withValues(alpha: 0.15)
                : AppColors.primaryCrimson.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isWarning) ...[
            const Icon(Icons.warning_amber_rounded,
                color: AppColors.primaryCrimson, size: 14),
            const SizedBox(width: 6),
          ],
          MainText(
            news.type ?? 'أخبار',
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryCrimson,
          ),
        ],
      ),
    );
  }

  // ─── Meta Row (date + duration) ───
  Widget _buildMetaRow(bool isDark) {
    return Row(
      children: [
        Icon(
          Icons.calendar_today_rounded,
          size: 14,
          color: isDark ? Colors.white38 : Colors.grey[500],
        ),
        const SizedBox(width: 6),
        MainText(
          DateConverter.formatNewsDate(news.publishDate),
          fontSize: 12,
          color: isDark ? Colors.white38 : Colors.grey[500],
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }

  // ─── Like Row ───
  Widget _buildLikeRow(bool isDark) {
    return Consumer(
      builder: (context, ref, _) {
        // Re-read the latest news state so the like count updates live.
        final latestList = ref.watch(newsRiverpod).newsList;
        final latestNews = latestList.firstWhere(
          (n) => n.id == news.id,
          orElse: () => news,
        );

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MainText(
                'هل أعجبك هذا الخبر؟',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : Colors.grey[600],
              ),
              AnimatedLikeButton(
                isLiked: latestNews.isLiked,
                likesCount: latestNews.likesCount,
                isSmall: false,
                onTap: () =>
                    ref.read(newsRiverpod.notifier).toggleLike(news.id),
              ),
            ],
          ),
        );
      },
    );
  }
}
