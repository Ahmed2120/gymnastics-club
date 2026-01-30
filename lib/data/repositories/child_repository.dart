import '../dummy_data.dart';
import '../models/models/child_model.dart';

class ChildRepository {
  Future<List<ChildModel>> getChildren() async {
    await Future.delayed(const Duration(seconds: 2));
    try {
      final children = dummyChildrenList
          .map<ChildModel>((e) => ChildModel.fromJson(e))
          .toList();

      return children;
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
