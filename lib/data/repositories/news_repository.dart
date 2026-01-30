import '../dummy_data.dart';
import '../models/models/news_model.dart';

class NewsRepositories {
  Future<List<NewsModel>> getNews({required int page, int limit = 10}) async {
    await Future.delayed(const Duration(seconds: 1));
    try {
      final startIndex = (page - 1) * limit;
      final news = newsDummyData
          .skip(startIndex)
          .take(limit)
          .map<NewsModel>((e) => NewsModel.fromJson(e))
          .toList();

      return news;
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
