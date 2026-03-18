import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymnastics_club/core/theme/app_colors.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CustomBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onPressed ?? () {
          if (context.canPop()) {
            context.pop();
          }
        },
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark 
                ? AppColors.primaryCrimson.withOpacity(0.15) 
                : AppColors.primaryCrimson.withOpacity(0.08),
          ),
          child: Center(
            child: Icon(
              // In RTL Arabic, "back" is often an arrow pointing right.
              // We'll use arrow_forward_ios_rounded to match the screenshot.
              Icons.arrow_back_ios_new_outlined,
              color: AppColors.primaryCrimson,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}
