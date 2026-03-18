import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymnastics_club/core/theme/app_colors.dart';
import 'package:gymnastics_club/widgets/main_text.dart';
import '../../dashboard_controller/dashboard_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:gymnastics_club/core/routing/routes.dart';

class QuickActions extends ConsumerWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final List<_QuickActionItem> items = [
      _QuickActionItem(
        title: 'طلب إذن',
        icon: Icons.note_add_outlined,
        onTap: () => context.push(Routes.requestPermission),
      ),
      _QuickActionItem(
        title: 'تسجيل غياب',
        icon: Icons.event_busy_outlined,
        onTap: () => context.push(Routes.attendanceAndAbsence),
      ),
      _QuickActionItem(
        title: 'إنجازاتي',
        icon: Icons.emoji_events_outlined,
        onTap: () => ref.read(dashboardProvider.notifier).setIndex(2),
      ),
      _QuickActionItem(
        title: 'تواصل معنا',
        icon: Icons.support_agent_outlined,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('قريباً...')),
          );
        },
      ),
    ];

    return SizedBox(
      height: 120,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 18),
        itemBuilder: (context, index) {
          final item = items[index];
          return _QuickActionCard(item: item, isDark: isDark);
        },
      ),
    );
  }
}

class _QuickActionCard extends StatefulWidget {
  final _QuickActionItem item;
  final bool isDark;

  const _QuickActionCard({required this.item, required this.isDark});

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.item.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: widget.isDark
                    ? AppColors.darkSurface
                    : Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: widget.isDark ? 0.35 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryCrimson.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.item.icon,
                    color: AppColors.primaryCrimson,
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            MainText(
              widget.item.title,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: widget.isDark ? Colors.white70 : const Color(0xFF444444),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  _QuickActionItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}
