import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gymnastics_club/widgets/main_text.dart';

class FullScreenImageViewer extends StatefulWidget {
  final ImageProvider imageProvider;
  final String heroTag;

  const FullScreenImageViewer({
    super.key,
    required this.imageProvider,
    required this.heroTag,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();

  /// Helper method to open the viewer with a smooth transition
  static void open(
    BuildContext context,
    ImageProvider imageProvider,
    String heroTag,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor:
            Colors.transparent, // Important for drag-to-dismiss reveal
        pageBuilder: (context, animation, secondaryAnimation) {
          return FullScreenImageViewer(
            imageProvider: imageProvider,
            heroTag: heroTag,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer>
    with SingleTickerProviderStateMixin {
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  late AnimationController _snapController;
  late Animation<Offset> _snapAnimation;
  final TransformationController _transformationController =
      TransformationController();

  // Thresholds
  static const double _dismissThreshold = 180.0;
  static const double _maxDragForOpacity = 400.0;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _snapController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _startDragging() {
    final double scale = _transformationController.value.getMaxScaleOnAxis();
    if (scale <= 1.05) {
      _snapController.stop();
      setState(() => _isDragging = true);
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_isDragging) return;

    // Check for velocity or distance threshold
    final double velocity = details.velocity.pixelsPerSecond.distance;
    final double distance = _dragOffset.distance;

    if (distance > _dismissThreshold || velocity > 1000) {
      _dismiss();
    } else {
      _snapBack();
    }
  }

  void _dismiss() {
    Navigator.of(context).pop();
  }

  void _snapBack() {
    _snapAnimation = _snapController.drive(
      Tween<Offset>(begin: _dragOffset, end: Offset.zero),
    );
    _snapController.forward(from: 0).then((_) {
      setState(() {
        _dragOffset = Offset.zero;
        _isDragging = false;
      });
    });

    // Also reset state during animation
    _snapController.addListener(() {
      if (_snapController.isAnimating) {
        setState(() {
          _dragOffset = _snapAnimation.value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate scale and opacity based on drag distance
    final double distance = _dragOffset.distance;
    final double opacity = max(0.0, 1.0 - (distance / _maxDragForOpacity));
    final double scaleTransition = max(
      0.85,
      1.0 - (distance / (_maxDragForOpacity * 2)),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background Dimmer
          Positioned.fill(
            child: Opacity(
              opacity: opacity,
              child: Container(color: Colors.black),
            ),
          ),

          // The Image with InteractiveViewer and Drag Gesture
          Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragUpdate: _onDragUpdate,
              onVerticalDragEnd: _onDragEnd,
              onHorizontalDragUpdate: _onDragUpdate,
              onHorizontalDragEnd: _onDragEnd,
              onVerticalDragStart: (_) => _startDragging(),
              onHorizontalDragStart: (_) => _startDragging(),
              child: Transform.translate(
                offset: _dragOffset,
                child: Transform.scale(
                  scale: scaleTransition,
                  child: Hero(
                    tag: widget.heroTag,
                    child: InteractiveViewer(
                      transformationController: _transformationController,
                      minScale: 1.0,
                      maxScale: 4.0,
                      panEnabled: !_isDragging,
                      scaleEnabled: !_isDragging,
                      child: Image(
                        image: widget.imageProvider,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                          child: Icon(Icons.broken_image_rounded,
                              size: 64, color: Colors.white24),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Tools Overlay (Close button and hints)
          // Hide when dragging for cleaner look
          if (!_isDragging) ...[
            // Close Button
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: 20,
              child: GestureDetector(
                onTap: _dismiss,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
