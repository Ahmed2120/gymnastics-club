// import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainTextField extends StatefulWidget {
  final String? hint;
  final String? label;
  final TextStyle? textStyle;
  final TextStyle? lableStyle;
  final Widget? prefixIcon;
  final Widget? suffix;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? maxLength;
  final int? minLines;
  final bool isDense;
  final EdgeInsetsGeometry? contentPadding;
  final bool readOnly;
  final bool enabled;
  final FocusNode? currentFocusNode;
  final bool unFocusWhenTapOutside;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool isPassword;
  final BoxConstraints? prefixIconConstraints;
  final bool isPhone;
  final String? initialCode;
  final String? helperText;
  final String? autofillHints;
  final bool autofocus;

  // Border properties
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
  final InputBorder? disabledBorder;
  final InputBorder? border;
  final double? borderRadius;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final Color? filledColor;
  final double? borderWidth;

  const MainTextField({
    super.key,
    this.hint,
    this.label,
    this.textStyle,
    this.prefixIcon,
    this.suffix,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.maxLength,
    this.isDense = true,
    this.contentPadding,
    this.readOnly = false,
    this.enabled = true,
    this.currentFocusNode,
    this.unFocusWhenTapOutside = false,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.validator,
    this.isPassword = false,
    this.isPhone = false,
    this.initialCode,
    this.helperText,
    this.prefixIconConstraints,
    this.autofillHints,
    this.autofocus = false,
    this.lableStyle,
    this.minLines,
    // Border parameters
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.disabledBorder,
    this.border,
    this.borderRadius,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderWidth,
    this.filledColor,
  });

  @override
  State<MainTextField> createState() => _MainTextFieldState();
}

class _MainTextFieldState extends State<MainTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  InputBorder _buildBorder({Color? color}) {
    final radius = widget.borderRadius ?? 8.0;
    final width = widget.borderWidth ?? 1.0;
    final borderColor = color ?? widget.borderColor ?? Colors.grey.shade300;

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(
        color: borderColor,
        width: width,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.label!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        TextFormField(
          autofillHints:
          widget.autofillHints != null ? [widget.autofillHints!] : null,
          controller: widget.controller,
          focusNode: widget.currentFocusNode,
          style: widget.textStyle ??
              const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          obscureText: _obscureText,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          autofocus: widget.autofocus,
          onTap: widget.onTap,
          minLines: widget.minLines,
          onTapOutside: (event) {
            FocusScope.of(context).unfocus();
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: widget.filledColor ?? (isDark ? Colors.grey.shade900 : Colors.white),
            label: widget.label != null
                ? Text(
              widget.label!,
              style: widget.lableStyle,
            )
                : null,
            helperText: widget.helperText,
            prefixIconConstraints: widget.prefixIconConstraints,
            isDense: widget.isDense,
            contentPadding: widget.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            prefixIcon: widget.prefixIcon != null
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: widget.prefixIcon,
            )
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
              onPressed: () =>
                  setState(() => _obscureText = !_obscureText),
              icon: Icon(
                _obscureText
                    ? CupertinoIcons.eye_slash
                    : CupertinoIcons.eye,
                size: 20,
              ),
            )
                : widget.suffixIcon,
            suffix: widget.suffix,
            hintText: widget.hint,
            hintStyle: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w400,
            ),
            counterText: '',
            // Border configurations
            border: widget.border ?? _buildBorder(),
            enabledBorder: widget.enabledBorder ?? _buildBorder(),
            focusedBorder: widget.focusedBorder ??
                _buildBorder(color: widget.focusedBorderColor ?? Theme.of(context).primaryColor),
            errorBorder: widget.errorBorder ??
                _buildBorder(color: widget.errorBorderColor ?? Colors.red),
            focusedErrorBorder: widget.focusedErrorBorder ??
                _buildBorder(color: widget.errorBorderColor ?? Colors.red),
            disabledBorder: widget.disabledBorder ??
                _buildBorder(color: Colors.grey.shade200),
          ),
        ),
      ],
    );
  }
}
