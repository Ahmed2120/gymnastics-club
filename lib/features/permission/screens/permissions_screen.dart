import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/enums.dart';
import '../../../widgets/main_text.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../../profile/profile_controller/child_riverpod.dart';
import '../permission_controller/permission_riverpod.dart';
import 'components/request_widget.dart';
import '../../../widgets/custom_back_button.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  PermissionStatusEnum? _selectedFilter;

  late AnimationController _headerAnimController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();
    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _headerFade =
        CurvedAnimation(parent: _headerAnimController, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _headerAnimController, curve: Curves.easeOut));

    Future.microtask(() async {
      final childName = ref.read(childRiverpod).selectedChild?.name;
      if (childName != null) {
        ref.read(permissionRiverpod.notifier).getPermissionList(
              childName: childName,
              status: _selectedFilter?.name,
            );
      }
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final childName = ref.read(childRiverpod).selectedChild?.name;
      if (childName != null) {
        ref.read(permissionRiverpod.notifier).loadMorePermissions(
              childName: childName,
              status: _selectedFilter?.name,
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const CustomBackButton(),
        title: MainText(
          'طلبات الغياب',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppColors.lightText,
        ),
      ),
      body: Column(
        children: [
          FadeTransition(
            opacity: _headerFade,
            child: SlideTransition(
              position: _headerSlide,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      _filterChip('الكل', null, isDark),
                      _filterChip('قيد الانتظار',
                          PermissionStatusEnum.pending, isDark),
                      _filterChip(
                          'مقبول', PermissionStatusEnum.accepted, isDark),
                      _filterChip(
                          'مرفوض', PermissionStatusEnum.rejected, isDark),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              color: AppColors.primaryCrimson,
              onRefresh: () async {
                final childName =
                    ref.read(childRiverpod).selectedChild?.name;
                if (childName != null) {
                  await ref
                      .read(permissionRiverpod.notifier)
                      .getPermissionList(
                        childName: childName,
                        status: _selectedFilter?.name,
                      );
                }
              },
              child: Consumer(
                builder: (context, ref, _) {
                  final permissionState = ref.watch(permissionRiverpod);

                  if (permissionState.isLoading) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: MainShimmer.cardList(),
                    );
                  }

                  if (permissionState.error.isNotEmpty) {
                    return Center(
                      child: MainText(
                        permissionState.error,
                        color: AppColors.primaryCrimson,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }

                  final filteredList = permissionState.permissionList;

                  if (filteredList.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 80,
                                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200],
                              ),
                              const SizedBox(height: 24),
                              MainText(
                                'لا توجد طلبات في هذا القسم',
                                color: isDark ? Colors.white24 : Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
                    itemCount: filteredList.length +
                        (permissionState.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == filteredList.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: MainShimmer.single(height: 120),
                        );
                      }
                      final item = filteredList[index];
                      return _AnimatedCard(
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: RequestWidget(
                            permissionModel: item,
                            isLoading: permissionState.changeStatusLoading &&
                                permissionState.permissionStatusId == item.id,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16, right: 8),
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.primaryCrimson,
          foregroundColor: Colors.white,
          elevation: 12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: const Icon(Icons.add_rounded, size: 28),
          label: const MainText('طلب جديد', color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
          onPressed: () => context.push(Routes.requestPermission),
        ),
      ),
    );
  }

  Widget _filterChip(
      String label, PermissionStatusEnum? status, bool isDark) {
    final isSelected = _selectedFilter == status;
    return GestureDetector(
      onTap: () {
        if (_selectedFilter == status) return;
        setState(() => _selectedFilter = status);
        
        final childName = ref.read(childRiverpod).selectedChild?.name;
        if (childName != null) {
          ref.read(permissionRiverpod.notifier).getPermissionList(
                childName: childName,
                status: status?.name,
              );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(left: 12, bottom: 4),
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primaryCrimson 
              : (isDark ? AppColors.darkSurface : Colors.white),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
             color: isSelected ? Colors.transparent : (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFE5E5E5)),
             width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryCrimson.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ]
              : [],
        ),
        child: MainText(
          label,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
        ),
      ),
    );
  }
}

class _AnimatedCard extends StatefulWidget {
  final Widget child;
  final int index;

  const _AnimatedCard({required this.child, required this.index});

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(
      Duration(milliseconds: 70 * (widget.index.clamp(0, 10))),
      () {
        if (mounted) _ctrl.forward();
      },
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
