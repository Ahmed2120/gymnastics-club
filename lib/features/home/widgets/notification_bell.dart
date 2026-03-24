import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/auth_provider.dart';

class NotificationBell extends ConsumerStatefulWidget {
  final IconData iconData;
  final Color? color;

  const NotificationBell({super.key, required this.iconData, this.color});

  @override
  ConsumerState<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends ConsumerState<NotificationBell> {
  int _unreadCount = 0;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
  }

  void _setupStream(String? phone) {
    if (phone == null || _subscription != null) return;

    final stream = Supabase.instance.client
        .from('parent_notifications')
        .stream(primaryKey: ['id'])
        .eq('parent_phone', phone);

    _subscription = stream.listen((List<Map<String, dynamic>> data) {
      if (mounted) {
        setState(() {
          _unreadCount = data.where((n) => n['is_read'] == false).length;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phone = ref.watch(authProvider).phoneNumber;
    if (phone != null && _subscription == null) {
      _setupStream(phone);
    }
    Widget icon = Icon(
      widget.iconData,
      color: widget.color ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
    );

    if (_unreadCount > 0) {
      return Badge(
        label: Text(_unreadCount.toString()),
        backgroundColor: Colors.red,
        child: icon,
      );
    }

    return icon;
  }
}
