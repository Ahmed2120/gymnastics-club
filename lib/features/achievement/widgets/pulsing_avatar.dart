import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gymnastics_club/core/theme/app_colors.dart';
import 'package:gymnastics_club/widgets/main_text.dart';

class PulsingAvatar extends StatefulWidget {
  final String? imageUrl;
  final int level;
  final double radius;

  const PulsingAvatar({
    super.key,
    this.imageUrl,
    required this.level,
    this.radius = 60,
  });

  @override
  State<PulsingAvatar> createState() => _PulsingAvatarState();
}

class _PulsingAvatarState extends State<PulsingAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = AppColors.achievementGold;
    final double totalSize = (widget.radius * 2) + 60;

    return SizedBox(
      width: totalSize,
      height: totalSize,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [goldColor, Color(0xFFFFD700), goldColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white.withOpacity(0.8), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: goldColor.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Container(
                  width: widget.radius * 2,
                  height: widget.radius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF261818),
                    image: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(widget.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: widget.imageUrl == null || widget.imageUrl!.isEmpty
                      ? Icon(Icons.person_rounded, size: widget.radius, color: Colors.white30)
                      : null,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [goldColor, Color(0xFFFFCC33)],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: MainText(
                _toArabicNumber(widget.level),
                color: const Color(0xFF1A0D0D),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _toArabicNumber(int number) {
    const arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String numStr = number.toString();
    String arabicNum = numStr.split('').map((e) {
      int? val = int.tryParse(e);
      return val != null ? arabicNumbers[val] : e;
    }).join('');
    return 'مستوى $arabicNum';
  }
}
