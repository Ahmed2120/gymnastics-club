import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymnastics_club/core/utils/extensions/size_extensions.dart';

import '../../../core/routing/routes.dart';
import '../../../core/utils/enums.dart';
import '../../../widgets/main_text.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../../profile/profile_controller/child_riverpod.dart';
import '../permission_controller/permission_riverpod.dart';
import 'components/request_widget.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

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
      final childName = ref.read(childRiverpod).selectedChild?.name;
      if (childName != null) {
        ref
            .read(permissionRiverpod.notifier)
            .getPermissionList(childName: childName);
      }
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
      final childName = ref.read(childRiverpod).selectedChild?.name;
      if (childName != null) {
        ref
            .read(permissionRiverpod.notifier)
            .loadMorePermissions(childName: childName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: MainText('الطلبات'), centerTitle: true),
      body: Column(
        children: [
          _buildFilterBar(),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                final childName = ref.read(childRiverpod).selectedChild?.name;
                if (childName != null) {
                  await ref
                      .read(permissionRiverpod.notifier)
                      .getPermissionList(childName: childName);
                }
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
          color: colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.4),
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceVariant.withOpacity(isDark ? 0.4 : 1),
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
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
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
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
