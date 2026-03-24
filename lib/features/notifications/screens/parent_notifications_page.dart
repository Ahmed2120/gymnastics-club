import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gymnastics_club/core/theme/app_colors.dart';
import 'package:gymnastics_club/widgets/main_text.dart';
import '../../auth/auth_provider.dart';

class ParentNotificationsPage extends ConsumerWidget {
  const ParentNotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phone = ref.watch(authProvider).phoneNumber;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const MainText('الإشعارات', fontSize: 20, fontWeight: FontWeight.bold),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: phone == null
          ? const Center(child: MainText('يرجى تسجيل الدخول'))
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: Supabase.instance.client
                  .from('parent_notifications')
                  .stream(primaryKey: ['id'])
                  .eq('parent_phone', phone)
                  .order('created_at'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const MainText('لا توجد إشعارات حالياً', color: Colors.grey),
                      ],
                    ),
                  );
                }

                // Sort by created_at descending (newest first)
                final notifications = snapshot.data!.toList();
                notifications.sort((a, b) => b['created_at'].compareTo(a['created_at']));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final n = notifications[index];
                    final bool isRead = n['is_read'] ?? false;
                    final String type = n['type'] ?? 'general';
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      child: ListTile(
                        onTap: () async {
                          if (!isRead) {
                            await Supabase.instance.client
                                .from('parent_notifications')
                                .update({'is_read': true})
                                .eq('id', n['id']);
                          }
                        },
                        leading: _buildIcon(type),
                        title: MainText(
                          n['title'] ?? '',
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                          fontSize: 16,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            MainText(
                              n['message'] ?? '',
                              fontSize: 14,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatDate(n['created_at']),
                              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                        trailing: !isRead
                            ? const CircleAvatar(radius: 4, backgroundColor: Colors.red)
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) return 'الآن';
      if (difference.inMinutes < 60) return 'منذ ${difference.inMinutes} دقيقة';
      if (difference.inHours < 24) return 'منذ ${difference.inHours} ساعة';
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  Widget _buildIcon(String type) {
    IconData iconData;
    Color color;

    switch (type) {
      case 'permission':
        iconData = Icons.assignment_turned_in_rounded;
        color = Colors.blue;
        break;
      case 'achievement':
        iconData = Icons.emoji_events_rounded;
        color = Colors.amber;
        break;
      case 'schedule':
        iconData = Icons.calendar_month_rounded;
        color = Colors.green;
        break;
      case 'news':
        iconData = Icons.campaign_rounded;
        color = Colors.red;
        break;
      default:
        iconData = Icons.notifications_rounded;
        color = AppColors.primaryColor;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: 24),
    );
  }
}
