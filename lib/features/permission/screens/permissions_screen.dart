import 'package:animate_do/animate_do.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymnastics_club/core/utils/extensions/size_extensions.dart';

import '../../../core/routing/routes.dart';
import '../../../core/utils/enums.dart';
import '../../../widgets/main_text.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../permission_controller/permission_riverpod.dart';
import 'components/request_widget.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  final ScrollController _scrollController = ScrollController();
  PermissionStatusEnum? _selectedFilter;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      ref.read(permissionRiverpod.notifier).getPermissionList();
    });
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
      ref.read(permissionRiverpod.notifier).loadMorePermissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: MainText('الطلبات'), centerTitle: true),
      body: Column(
        children: [
          _buildFilterBar(),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(permissionRiverpod.notifier).getPermissionList();
              },
              child: Consumer(
                builder: (context, ref, _) {
                  final permissionState = ref.watch(permissionRiverpod);

                  if (permissionState.isLoading) {
                    return MainShimmer.cardList();
                  } else if (permissionState.error.isNotEmpty) {
                    return Center(
                      child: MainText(permissionState.error.toString()),
                    );
                  }

                  final filteredList = _selectedFilter == null
                      ? permissionState.permissionList
                      : permissionState.permissionList
                            .where((item) => item.status == _selectedFilter)
                            .toList();

                  // Use AnimatedSwitcher for smooth transition between "No Data" and "List"
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: filteredList.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 200),
                              Center(
                                key: ValueKey('empty'),
                                child: MainText('لا توجد طلبات في هذا القسم'),
                              ),
                            ],
                          )
                        : ListView.separated(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            key: ValueKey(_selectedFilter),
                            // Forces re-animation on filter change
                            padding: const EdgeInsets.all(16),
                            itemCount:
                                filteredList.length +
                                (permissionState.isLoadingMore ? 1 : 0),
                            separatorBuilder: (context, index) => 12.ph,

                            itemBuilder: (context, index) {
                              if (index == filteredList.length) {
                                return MainShimmer.single(height: 120);
                              }
                              final item = filteredList[index];
                              return FadeInUp(
                                duration: const Duration(milliseconds: 300),
                                delay: Duration(milliseconds: 50 * index),
                                child: RequestWidget(
                                  permissionModel: item,
                                  isLoading:
                                      permissionState.changeStatusLoading &&
                                      permissionState.permissionStatusId ==
                                          item.id,
                                ),
                              );
                            },
                          ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF667eea),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667eea).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.add, color: Colors.white, size: 24),
          onPressed: () {
            context.push(Routes.requestPermission);
          },
        ),
      ),
    );
  }

  Widget statusChip(PermissionStatus status) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: statusBackgroundColor(status),
      ),
      child: MainText(
        statusText(status),
        color: statusColor(status),
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Color statusColor(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.approved:
        return Colors.green;
      case PermissionStatus.rejected:
        return Colors.red;
      case PermissionStatus.pending:
        return Color(0xFF856404);
    }
  }

  Color statusBackgroundColor(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.approved:
        return Color(0xFFd4edda);
      case PermissionStatus.rejected:
        return Color(0xFFf8d7da);
      case PermissionStatus.pending:
        return Color(0xFFfff3cd);
    }
  }

  String statusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.approved:
        return 'مقبول';
      case PermissionStatus.rejected:
        return 'مرفوض';
      case PermissionStatus.pending:
        return 'قيد المراجعة';
    }
  }

  Widget _buildFilterBar() {
    return Container(
      height: 60,
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _smoothFilterButton('الكل', null),
            _smoothFilterButton('قيد الانتظار', PermissionStatusEnum.pending),
            _smoothFilterButton('مقبول', PermissionStatusEnum.accepted),
            _smoothFilterButton('مرفوض', PermissionStatusEnum.rejected),
          ],
        ),
      ),
    );
  }

  Widget _smoothFilterButton(String label, PermissionStatusEnum? status) {
    final isSelected = _selectedFilter == status;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

enum PermissionStatus { rejected, approved, pending }
