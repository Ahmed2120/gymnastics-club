import 'package:flutter/material.dart';
import 'package:gymnastics_club/core/utils/extensions/size_extensions.dart';
import 'package:gymnastics_club/widgets/main_textfield.dart';

import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_drop_down.dart';
import '../../../widgets/main_text.dart';
import '../../../widgets/selected_card.dart';

class RequestPermission extends StatelessWidget {
  RequestPermission({super.key});

  final _reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: MainText('طلب إذن غياب جديد'),
    centerTitle: true,
    ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          MainText('اسم الطفل', fontSize: 18, fontWeight: FontWeight.w700,),
          12.ph,
          CustomDropdown(),
          22.ph,
          MainText('تاريخ الغياب', fontSize: 18, fontWeight: FontWeight.w700,),
          12.ph,
          SelectedCard(
            onTap: (){},
            child: MainText('28 أكتوبر 2024 📅'),
          ),
          22.ph,
          MainText('سبب الغياب', fontSize: 18, fontWeight: FontWeight.w700,),
          12.ph,
          MainTextField(
            controller: _reasonController,
            borderColor: Colors.black,
            maxLines: 3,
            hint: 'اكتب السبب هنا...',
          ),

        ],
      ),
      bottomNavigationBar:  Padding(
        padding: EdgeInsets.all(16).copyWith(bottom: 16 + MediaQuery.of(context).padding.bottom),
        child: PrimaryButton(
          text: 'إرسال الطلب',
          borderRadius: 12,
          onPressed: (){
          },
        ),
      ),
    );
  }
}
