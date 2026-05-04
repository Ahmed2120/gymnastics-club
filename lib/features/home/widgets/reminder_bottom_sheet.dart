import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gymnastics_club/core/theme/app_colors.dart';
import 'package:gymnastics_club/widgets/main_text.dart';
import 'package:animate_do/animate_do.dart';

class ReminderBottomSheet extends StatelessWidget {
  final int currentOffset;
  final bool isEnabled;
  final Function(int minutes) onSetReminder;
  final VoidCallback onCancelReminder;

  const ReminderBottomSheet({
    super.key,
    required this.currentOffset,
    required this.isEnabled,
    required this.onSetReminder,
    required this.onCancelReminder,
  });

  static Future<void> show({
    required BuildContext context,
    required int currentOffset,
    required bool isEnabled,
    required Function(int minutes) onSetReminder,
    required VoidCallback onCancelReminder,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ReminderBottomSheet(
        currentOffset: currentOffset,
        isEnabled: isEnabled,
        onSetReminder: onSetReminder,
        onCancelReminder: onCancelReminder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        decoration: BoxDecoration(
          color: const Color(0xFF10141D).withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 32),

            FadeInDown(
              duration: const Duration(milliseconds: 400),
              child: const MainText(
                'تنبيه التدريب',
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: MainText(
                'متى تريد أن يتم تنبيهك قبل التدريب؟',
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),

            // Options
            _buildOption(
              context: context,
              title: 'قبل ساعة واحدة (60 دقيقة)',
              minutes: 60,
              isSelected: isEnabled && currentOffset == 60,
              icon: Icons.timer_outlined,
            ),
            const SizedBox(height: 16),
            _buildOption(
              context: context,
              title: 'قبل 30 دقيقة',
              minutes: 30,
              isSelected: isEnabled && currentOffset == 30,
              icon: Icons.timer_3_select_outlined,
            ),
            
            if (isEnabled) ...[
              const SizedBox(height: 32),
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                child: TextButton(
                  onPressed: () {
                    onCancelReminder();
                    Navigator.pop(context);
                  },
                  child: const MainText(
                    'إلغاء التنبيه',
                    color: AppColors.primaryCrimson,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required String title,
    required int minutes,
    required bool isSelected,
    required IconData icon,
  }) {
    return FadeInRight(
      duration: const Duration(milliseconds: 400),
      child: InkWell(
        onTap: () {
          onSetReminder(minutes);
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.primaryCrimson.withOpacity(0.15) 
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected 
                  ? AppColors.primaryCrimson.withOpacity(0.5) 
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.primaryCrimson 
                      : Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: MainText(
                  title,
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: AppColors.primaryCrimson),
            ],
          ),
        ),
      ),
    );
  }
}
