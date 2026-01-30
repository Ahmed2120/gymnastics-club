import 'package:flutter_riverpod/legacy.dart';

import '../../../core/services/init_getit.dart';
import '../../../data/models/models/permission_model.dart';
import '../../../data/repositories/permission_repository.dart';
import 'permission_state.dart';

final permissionRiverpod =
    StateNotifierProvider.autoDispose<PermissionRiverpod, PermissionState>(
      (_) => PermissionRiverpod(),
    );

class PermissionRiverpod extends StateNotifier<PermissionState> {
  PermissionRiverpod() : super(PermissionState());

  final _permissionRepositories = getIT<PermissionRepository>();

  Future<void> getPermissionList({String? group, String? date}) async {
    state = state.copyWith(isLoading: true, currentPage: 1, hasMore: true);
    try {
      final permissionList = await _permissionRepositories.getRequests(page: 1);
      state = state.copyWith(
        isLoading: false,
        permissionList: permissionList,
        currentPage: 2,
        hasMore: permissionList.length >= 10,
        error: '',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMorePermissions() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final permissionList = await _permissionRepositories.getRequests(
        page: state.currentPage,
      );
      state = state.copyWith(
        isLoadingMore: false,
        permissionList: [...state.permissionList, ...permissionList],
        currentPage: state.currentPage + 1,
        hasMore: permissionList.length >= 10,
        error: '',
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> submitRequest(PermissionModel request) async {
    state = state.copyWith(isLoading: true);
    try {
      await _permissionRepositories.submitRequest(request);
      state = state.copyWith(
        isLoading: false,
        permissionList: [request, ...state.permissionList],
        error: '',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}
