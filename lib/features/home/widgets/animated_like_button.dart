import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AnimatedLikeButton extends StatefulWidget {
  final bool isLiked;
  final int likesCount;
  final VoidCallback onTap;
  final bool isSmall;

  const AnimatedLikeButton({
    super.key,
    required this.isLiked,
    required this.likesCount,
    required this.onTap,
    this.isSmall = false,
  });

  @override
  State<AnimatedLikeButton> createState() => _AnimatedLikeButtonState();
}

class _AnimatedLikeButtonState extends State<AnimatedLikeButton> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _particlesController;
  late List<ParticleModel> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _particles = List.generate(8, (index) => _createParticle());
  }

  ParticleModel _createParticle() {
    final angle = _random.nextDouble() * 2 * pi;
    final distance = 20.0 + _random.nextDouble() * 30.0;
    return ParticleModel(
      angle: angle,
      distance: distance,
      size: 4.0 + _random.nextDouble() * 4.0,
    );
  }

  @override
  void didUpdateWidget(AnimatedLikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLiked && !oldWidget.isLiked) {
      _triggerAnimation();
    }
  }

  void _triggerAnimation() {
    _pulseController.forward().then((_) => _pulseController.reverse());
    _particlesController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double iconSize = widget.isSmall ? 18 : 24;

    return GestureDetector(
      onTap: () {
        widget.onTap();
        if (!widget.isLiked) {
          _triggerAnimation();
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Particles
          ...List.generate(_particles.length, (index) {
            final p = _particles[index];
            return AnimatedBuilder(
              animation: _particlesController,
              builder: (context, child) {
                final progress = _particlesController.value;
                if (progress == 0 || progress == 1) return const SizedBox.shrink();

                final currentDist = p.distance * progress;
                final opacity = 1.0 - progress;
                
                return Transform.translate(
                  offset: Offset(
                    cos(p.angle) * currentDist,
                    sin(p.angle) * currentDist,
                  ),
                  child: Opacity(
                    opacity: opacity,
                    child: Icon(
                      Icons.favorite,
                      color: AppColors.primaryColor,
                      size: p.size * (1 - progress * 0.5),
                    ),
                  ),
                );
              },
            );
          }),

          // Pulse Heart
          ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.4).animate(
              CurvedAnimation(parent: _pulseController, curve: Curves.easeOutBack),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: widget.isLiked ? AppColors.primaryColor : Colors.grey,
                  size: iconSize,
                ),
                if (widget.likesCount > 0) ...[
                  const SizedBox(width: 6),
                  Text(
                    widget.likesCount.toString(),
                    style: TextStyle(
                      fontSize: widget.isSmall ? 12 : 14,
                      color: widget.isLiked ? AppColors.primaryColor : Colors.grey,
                      fontWeight: widget.isLiked ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ParticleModel {
  final double angle;
  final double distance;
  final double size;

  ParticleModel({
    required this.angle,
    required this.distance,
    required this.size,
  });
}
