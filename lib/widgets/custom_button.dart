import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final Color? textColor;
  final Color? disabledTextColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final TextStyle? textStyle;
  final bool isLoading;
  final Widget? loadingWidget;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double? elevation;
  final BorderSide? borderSide;
  final bool enabled;
  final AlignmentGeometry? alignment;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;

  const CustomButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.textColor,
    this.disabledTextColor,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 8.0,
    this.textStyle,
    this.isLoading = false,
    this.loadingWidget,
    this.prefixIcon,
    this.suffixIcon,
    this.elevation,
    this.borderSide,
    this.enabled = true,
    this.alignment,
    this.gradient,
    this.boxShadow,
  }) : assert(text != null || child != null, 'Either text or child must be provided');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = !enabled || onPressed == null || isLoading;

    Widget buttonChild;

    if (isLoading) {
      buttonChild = loadingWidget ??
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                textColor ?? Colors.white,
              ),
            ),
          );
    } else if (child != null) {
      buttonChild = child!;
    } else {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (prefixIcon != null) ...[
            prefixIcon!,
            const SizedBox(width: 8),
          ],
          Text(
            text!,
            style: textStyle ??
                TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDisabled
                      ? (disabledTextColor ?? Colors.grey.shade400)
                      : (textColor ?? Colors.white),
                ),
          ),
          if (suffixIcon != null) ...[
            const SizedBox(width: 8),
            suffixIcon!,
          ],
        ],
      );
    }

    final buttonContent = Container(
      width: width,
      height: height ?? 50,
      alignment: alignment ?? Alignment.center,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: gradient == null
            ? (isDisabled
            ? (disabledBackgroundColor ?? Colors.grey.shade300)
            : (backgroundColor ?? theme.primaryColor))
            : null,
        gradient: !isDisabled ? gradient : null,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderSide != null ? Border.fromBorderSide(borderSide!) : null,
        boxShadow: !isDisabled && boxShadow != null ? boxShadow : null,
      ),
      child: buttonChild,
    );

    return Container(
      margin: margin,
      child: Material(
        color: Colors.transparent,
        elevation: !isDisabled && elevation != null ? elevation! : 0,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: buttonContent,
        ),
      ),
    );
  }
}

// Predefined button variants for common use cases
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double borderRadius;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.prefixIcon,
    this.suffixIcon,
    this.borderRadius = 8,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      width: width,
      borderRadius: borderRadius,
      backgroundColor: Theme.of(context).primaryColor,
      textColor: Colors.white,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double? width;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.prefixIcon,
    this.suffixIcon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      width: width,
      backgroundColor: Colors.transparent,
      textColor: Theme.of(context).primaryColor,
      borderSide: BorderSide(
        color: Theme.of(context).primaryColor,
        width: 1.5,
      ),
    );
  }
}

class OutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double? width;
  final Color? borderColor;
  final Color? textColor;

  const OutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.prefixIcon,
    this.suffixIcon,
    this.width,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = borderColor ?? Colors.grey.shade400;
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      width: width,
      backgroundColor: Colors.transparent,
      textColor: textColor ?? Colors.black87,
      borderSide: BorderSide(
        color: color,
        width: 1.5,
      ),
    );
  }
}

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? textColor;

  const CustomTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.prefixIcon,
    this.suffixIcon,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      backgroundColor: Colors.transparent,
      textColor: textColor ?? Theme.of(context).primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}