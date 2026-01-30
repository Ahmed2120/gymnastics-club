import '../dummy_data.dart';
import '../models/models/permission_model.dart';

class PermissionRepository {
  Future<List<PermissionModel>> getRequests({
    int page = 1,
    int limit = 10,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    try {
      final startIndex = (page - 1) * limit;
      final requests = dummyPermissionList
          .skip(startIndex)
          .take(limit)
          .map<PermissionModel>((e) => PermissionModel.fromJson(e))
          .toList();

      return requests;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> submitRequest(PermissionModel request) async {
    await Future.delayed(const Duration(seconds: 1));
    try {
      (dummyPermissionList as List).add(request.toJson());
    } catch (e, s) {
      print(e);
      print(s);
      rethrow;
    }
  }
}
