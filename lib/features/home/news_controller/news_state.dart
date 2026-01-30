import '../../../data/models/models/news_model.dart';

class NewsState {
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final bool deleteLoading;
  final int deleteId;
  final int currentPage;
  final List<NewsModel> newsList;
  final String error;

  NewsState({
    this.newsList = const [],
    this.error = '',
    this.currentPage = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.deleteLoading = false,
    this.deleteId = -1,
  });

  NewsState copyWith({
    List<NewsModel>? newsList,
    String? error,
    int? currentPage,
    bool? isLoading,
    bool? deleteLoading,
    int? deleteId,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return NewsState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      newsList: newsList ?? this.newsList,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      deleteId: deleteId ?? this.deleteId,
      deleteLoading: deleteLoading ?? this.deleteLoading,
    );
  }
}
