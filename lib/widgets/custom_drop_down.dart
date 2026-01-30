import 'package:flutter/material.dart';

import 'main_text.dart';

class CustomDropdown<T> extends FormField<T> {
  CustomDropdown({
    super.key,
    required List<T> items,
    required String Function(T) getText,
    String? hint,
    required void Function(T) onChange,
    T? initialValue,
    String? Function(T?)? validator,
  }) : super(
         initialValue: initialValue,
         validator: validator,
         autovalidateMode: AutovalidateMode.onUserInteraction,
         builder: (FormFieldState<T> state) {
           return _CustomDropdownWidget<T>(
             items: items,
             getText: getText,
             hint: hint,
             onChange: onChange,
             initialValue: initialValue,
             formFieldState: state,
           );
         },
       );
}

class _CustomDropdownWidget<T> extends StatefulWidget {
  const _CustomDropdownWidget({
    super.key,
    required this.items,
    required this.getText,
    this.hint,
    required this.onChange,
    this.initialValue,
    required this.formFieldState,
  });

  final String? hint;
  final T? initialValue;
  final List<T> items;
  final String Function(T) getText;
  final void Function(T) onChange;
  final FormFieldState<T> formFieldState;

  @override
  State<_CustomDropdownWidget<T>> createState() =>
      _CustomDropdownWidgetState<T>();
}

class _CustomDropdownWidgetState<T> extends State<_CustomDropdownWidget<T>> {
  T? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.formFieldState.hasError;
    final errorText = widget.formFieldState.errorText;

    return Directionality(
      // To make it RTL for Arabic
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasError ? Colors.red : Colors.grey.shade300,
                width: hasError ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: selectedValue,
                hint: widget.hint == null ? null : MainText(widget.hint!),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                isExpanded: true,
                items: widget.items.map((T value) {
                  return DropdownMenuItem<T>(
                    value: value,
                    child: MainText(
                      widget.getText(value),
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedValue = newValue;
                  });
                  if (newValue != null) {
                    widget.onChange(newValue);
                  }
                  widget.formFieldState.didChange(newValue);
                },
              ),
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
      ),
    );
  }
}
