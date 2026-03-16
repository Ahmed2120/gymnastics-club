import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/services/init_getit.dart';
import '../../../data/models/models/news_model.dart';
import '../../../data/repositories/news_repository.dart';
import '../../auth/auth_provider.dart';
import 'news_state.dart';

final newsRiverpod = StateNotifierProvider.autoDispose<NewsRiverpod, NewsState>(
  (ref) {
    final link = ref.keepAlive();
    return NewsRiverpod(ref);
  },
);

class NewsRiverpod extends StateNotifier<NewsState> {
  final Ref ref;
  NewsRiverpod(this.ref) : super(NewsState());

  final _newsRepositories = getIT<NewsRepositories>();

  Future<void> getNews({List<String>? groupIds, bool force = false}) async {
    if (state.isLoading && !force) return;
    state = state.copyWith(isLoading: true, currentPage: 1, hasMore: true);
    try {
      final phone = ref.read(authProvider).phoneNumber;
      final news = await _newsRepositories.getNews(page: 1, groupIds: groupIds, phone: phone);
      // Sort news: Priority first (higher number = higher priority), then by date
      news.sort((a, b) {
        final pCompare = (b.priority ?? 0).compareTo(a.priority ?? 0);
        if (pCompare != 0) return pCompare;
        return b.publishDate.compareTo(a.publishDate);
      });
      state = state.copyWith(
        isLoading: false,
        newsList: news,
        currentPage: 2,
        hasMore: news.length >= 10,
        error: '',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> loadMoreNews({List<String>? groupIds}) async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final phone = ref.read(authProvider).phoneNumber;
      final news = await _newsRepositories.getNews(
        page: state.currentPage,
        groupIds: groupIds,
        phone: phone,
      );
      state = state.copyWith(
        isLoadingMore: false,
        newsList: [...state.newsList, ...news],
        currentPage: state.currentPage + 1,
        hasMore: news.length >= 10,
        error: '',
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> toggleLike(int newsId) async {
    try {
      // Optimistic update
      final newsIndex = state.newsList.indexWhere((n) => n.id == newsId);
      if (newsIndex != -1) {
        final currentNews = state.newsList[newsIndex];
        final updatedNews = NewsModel(
          id: currentNews.id,
          title: currentNews.title,
          newsContent: currentNews.newsContent,
          type: currentNews.type,
          groupId: currentNews.groupId,
          publishDate: currentNews.publishDate,
          newsDuration: currentNews.newsDuration,
          imageUrl: currentNews.imageUrl,
          priority: currentNews.priority,
          likesCount: currentNews.isLiked ? currentNews.likesCount - 1 : currentNews.likesCount + 1,
          isLiked: !currentNews.isLiked,
        );

        final newList = [...state.newsList];
        newList[newsIndex] = updatedNews;
        state = state.copyWith(newsList: newList);
      }

      final phone = ref.read(authProvider).phoneNumber;
      if (phone == null) throw Exception('Unauthorized: No phone number found');

      final result = await _newsRepositories.toggleLike(newsId, phone);
      
      // Update with server result to be sure
      if (result['success'] == true) {
        final serverIsLiked = result['is_liked'];
        final serverLikesCount = result['likes_count'];
        
        final newsIndex = state.newsList.indexWhere((n) => n.id == newsId);
        if (newsIndex != -1) {
          final currentNews = state.newsList[newsIndex];
          if (currentNews.isLiked != serverIsLiked || currentNews.likesCount != serverLikesCount) {
             final updatedNews = NewsModel(
              id: currentNews.id,
              title: currentNews.title,
              newsContent: currentNews.newsContent,
              type: currentNews.type,
              groupId: currentNews.groupId,
              publishDate: currentNews.publishDate,
              newsDuration: currentNews.newsDuration,
              imageUrl: currentNews.imageUrl,
              priority: currentNews.priority,
              likesCount: serverLikesCount,
              isLiked: serverIsLiked,
            );

            final newList = [...state.newsList];
            newList[newsIndex] = updatedNews;
            state = state.copyWith(newsList: newList);
          }
        }
      }
    } catch (e) {
      print('Failed to toggle like: $e');
      // Revert handle or error state if needed
    }
  }
}
