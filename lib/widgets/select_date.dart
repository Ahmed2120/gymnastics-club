import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gymnastics_club/core/utils/extensions/context_extensions.dart';
import 'package:gymnastics_club/widgets/selected_card.dart';

import '../core/costants/app_assets.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/date_converter.dart';
import 'main_text.dart';

class SelectDateWidget extends FormField<DateTime> {
  SelectDateWidget({
    super.key,
    required void Function(DateTime) onSelect,
    DateTime? initialDate,
    String? Function(DateTime?)? validator,
  }) : super(
         initialValue: initialDate,
         validator: validator,
         autovalidateMode: AutovalidateMode.onUserInteraction,
         builder: (FormFieldState<DateTime> state) {
           return _SelectDateWidgetContent(
             onSelect: onSelect,
             initialDate: initialDate,
             formFieldState: state,
           );
         },
       );
}

class _SelectDateWidgetContent extends StatefulWidget {
  const _SelectDateWidgetContent({
    required this.onSelect,
    this.initialDate,
    required this.formFieldState,
  });

  final DateTime? initialDate;
  final Function(DateTime) onSelect;
  final FormFieldState<DateTime> formFieldState;

  @override
  State<_SelectDateWidgetContent> createState() =>
      _SelectDateWidgetContentState();
}

class _SelectDateWidgetContentState extends State<_SelectDateWidgetContent> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? widget.initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: Locale(context.languageCode),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      widget.onSelect(picked);
      widget.formFieldState.didChange(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.formFieldState.hasError;
    final errorText = widget.formFieldState.errorText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectedCard(
          hasError: hasError,
          onTap: () {
            _selectDate(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MainText(
                _selectedDate == null
                    ? widget.initialDate == null
                          ? 'اضغط هنا لاختيار تاريخ ...'
                          : DateConverter.dateToReadableDate(
                              widget.initialDate.toString(),
                            )
                    : DateConverter.dateToReadableDate(
                        _selectedDate.toString(),
                      ),
                fontSize: 18,
                color: _selectedDate == null && widget.initialDate == null
                    ? AppColors.hintColor
                    : null,
              ),
              SvgPicture.asset(
                AppAssetsSvg.calendarIcon,
                colorFilter: ColorFilter.mode(
                  context.theme.primaryColor,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
        if (hasError && errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 12, left: 12),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
