import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymnastics_club/core/utils/enums.dart';
import 'package:gymnastics_club/core/utils/extensions/size_extensions.dart';
import 'package:gymnastics_club/data/models/models/permission_model.dart';
import 'package:gymnastics_club/features/permission/permission_controller/permission_riverpod.dart';
import 'package:gymnastics_club/features/profile/profile_controller/child_riverpod.dart';
import 'package:gymnastics_club/widgets/main_textfield.dart';

import '../../../widgets/custom_button.dart';
import '../../../widgets/main_text.dart';
import '../../../widgets/select_date.dart';

class RequestPermission extends ConsumerStatefulWidget {
  const RequestPermission({super.key});

  @override
  ConsumerState<RequestPermission> createState() => _RequestPermissionState();
}

class _RequestPermissionState extends ConsumerState<RequestPermission> {
  final _reasonController = TextEditingController();
  DateTime? _selectedDate;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final childState = ref.watch(childRiverpod);
    final activeChild = childState.selectedChild;
    final permissionState = ref.watch(permissionRiverpod);

    return Scaffold(
      appBar: AppBar(
        title: const MainText('طلب إذن غياب جديد'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const MainText(
              'تاريخ الغياب',
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            12.ph,
            SelectDateWidget(
              onSelect: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),
            22.ph,
            const MainText(
              'سبب الغياب',
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            12.ph,
            MainTextField(
              controller: _reasonController,
              borderColor: Colors.black,
              maxLines: 4,
              hint: 'اكتب السبب هنا...',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى كتابة سبب الغياب';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(
          16,
        ).copyWith(bottom: 16 + MediaQuery.of(context).padding.bottom),
        child: PrimaryButton(
          text: 'إرسال الطلب',
          isLoading: permissionState.isLoading,
          borderRadius: 12,
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              if (_selectedDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى اختيار التاريخ')),
                );
                return;
              }

              if (activeChild == null) return;

              final newRequest = PermissionModel(
                id: DateTime.now().millisecondsSinceEpoch,
                childName: activeChild.name,
                date: _selectedDate!,
                reason: _reasonController.text,
                status: PermissionStatusEnum.pending,
              );

              try {
                await ref
                    .read(permissionRiverpod.notifier)
                    .submitRequest(newRequest);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إرسال الطلب بنجاح')),
                  );
                  context.pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
                }
              }
            }
          },
        ),
      ),
    );
  }
}
