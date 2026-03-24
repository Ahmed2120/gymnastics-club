import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/utils/enums.dart';
import '../../../../data/models/models/permission_model.dart';
import '../../../../widgets/main_text.dart';

class RequestWidget extends StatelessWidget {
  const RequestWidget({
    super.key,
    required this.permissionModel,
    this.isLoading = false,
  });

  final PermissionModel permissionModel;
  final bool isLoading;

  // ── Status helpers ──────────────────────────────────────────────────────────

  Color _statusColor(PermissionStatusEnum status) {
    switch (status) {
      case PermissionStatusEnum.accepted:
        return const Color(0xFF16A34A);
      case PermissionStatusEnum.rejected:
        return const Color(0xFFDC2626);
      case PermissionStatusEnum.pending:
        return const Color(0xFFD97706);
    }
  }

  Color _statusBg(PermissionStatusEnum status, bool isDark) {
    switch (status) {
      case PermissionStatusEnum.accepted:
        return isDark ? const Color(0xFF052E16) : const Color(0xFFDCFCE7);
      case PermissionStatusEnum.rejected:
        return isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2);
      case PermissionStatusEnum.pending:
        return isDark ? const Color(0xFF431407) : const Color(0xFFFEF3C7);
    }
  }

  String _statusText(PermissionStatusEnum status) {
    switch (status) {
      case PermissionStatusEnum.accepted:
        return 'مقبول';
      case PermissionStatusEnum.rejected:
        return 'مرفوض';
      case PermissionStatusEnum.pending:
        return 'قيد المراجعة';
    }
  }

  IconData _statusIcon(PermissionStatusEnum status) {
    switch (status) {
      case PermissionStatusEnum.accepted:
        return Icons.check_circle_rounded;
      case PermissionStatusEnum.rejected:
        return Icons.cancel_rounded;
      case PermissionStatusEnum.pending:
        return Icons.hourglass_top_rounded;
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final status = permissionModel.status;
    final accentColor = _statusColor(status);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        // Subtle left accent border
        border: Border(
          right: BorderSide(color: accentColor, width: 4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _statusBg(status, isDark),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_statusIcon(status), color: accentColor, size: 22),
                ),
                const SizedBox(width: 12),

                // Title + child name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MainText(
                        'طلب إذن غياب',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.person_outline_rounded,
                              size: 13,
                              color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: MainText(
                              permissionModel.childName,
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusBg(status, isDark),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: MainText(
                    _statusText(status),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            Divider(color: (isDark ? Colors.white : Colors.black).withOpacity(0.06)),
            const SizedBox(height: 12),

            // Date row
            _InfoRow(
              icon: Icons.calendar_today_rounded,
              label: 'التاريخ',
              value: permissionModel.date != null
                  ? DateFormat('d MMMM yyyy', 'ar').format(permissionModel.date!)
                  : 'غير محدد',
              isDark: isDark,
            ),
            const SizedBox(height: 8),

            // Reason row
            _InfoRow(
              icon: Icons.notes_rounded,
              label: 'السبب',
              value: permissionModel.reason,
              isDark: isDark,
            ),

            // Rejection note
            if (status == PermissionStatusEnum.rejected && 
                permissionModel.rejectionReason != null && 
                permissionModel.rejectionReason!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _statusBg(status, isDark),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: accentColor, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: MainText(
                        permissionModel.rejectionReason!,
                        fontSize: 12,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Loading overlay for status change
            if (isLoading) ...[
              const SizedBox(height: 10),
              const Center(
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Info Row Helper ──────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.grey[400] : Colors.grey[700];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: textColor),
        const SizedBox(width: 6),
        MainText(
          '$label:  ',
          fontSize: 13,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
        Expanded(
          child: MainText(
            value,
            fontSize: 13,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    );
  }
}
