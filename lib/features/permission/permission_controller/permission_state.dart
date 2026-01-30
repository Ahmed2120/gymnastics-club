import '../../../data/models/models/permission_model.dart';

class PermissionState {
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final bool changeStatusLoading;
  final int permissionStatusId;
  final int currentPage;
  final List<PermissionModel> permissionList;
  final String error;

  PermissionState({
    this.permissionList = const [],
    this.error = '',
    this.currentPage = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.changeStatusLoading = false,
    this.permissionStatusId = -1,
  });

  PermissionState copyWith({
    List<PermissionModel>? permissionList,
    String? error,
    int? permissionStatusId,
    int? currentPage,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    bool? changeStatusLoading,
  }) {
    return PermissionState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      changeStatusLoading: changeStatusLoading ?? this.changeStatusLoading,
      permissionList: permissionList ?? this.permissionList,
      error: error ?? this.error,
      permissionStatusId: permissionStatusId ?? this.permissionStatusId,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
