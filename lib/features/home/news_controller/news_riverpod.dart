import 'package:flutter_riverpod/legacy.dart';

import '../../../core/services/init_getit.dart';
import '../../../data/repositories/child_repository.dart';
import '../../../data/repositories/news_repository.dart';
import 'news_state.dart';

final newsRiverpod = StateNotifierProvider.autoDispose<NewsRiverpod, NewsState>(
  (ref) {
    final link = ref.keepAlive();
    return NewsRiverpod();
  },
);

class NewsRiverpod extends StateNotifier<NewsState> {
  NewsRiverpod() : super(NewsState());

  final _newsRepositories = getIT<NewsRepositories>();

  Future<void> getNews({List<String>? groupIds, bool force = false}) async {
    if (state.isLoading && !force) return;
    state = state.copyWith(isLoading: true, currentPage: 1, hasMore: true);
    try {
      print('groupIds???11 $groupIds');
      final news = await _newsRepositories.getNews(page: 1, groupIds: groupIds);
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
      final news = await _newsRepositories.getNews(
        page: state.currentPage,
        groupIds: groupIds,
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
}
