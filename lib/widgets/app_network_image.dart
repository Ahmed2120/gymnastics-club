import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A performant, memory-optimized image widget that:
/// - Caches images to disk so they don't re-download.
/// - Restricts decoded image size to reduce GPU memory usage.
/// - Shows a shimmer while loading.
/// - Gracefully falls back to [errorWidget] on failure.
class AppNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? errorWidget;

  final int? memCacheWidth;
  final int? memCacheHeight;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _defaultError();

    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: memCacheWidth ?? _toInt(width),
      memCacheHeight: memCacheHeight ?? _toInt(height),
      placeholder: (context, _) => _Shimmer(width: width, height: height),
      errorWidget: (context, url, error) => errorWidget ?? _defaultError(),
    );
  }

  Widget _defaultError() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: const Icon(Icons.person, color: Colors.grey),
    );
  }

  int? _toInt(double? v) => v == null ? null : v.toInt();
}

/// Circular avatar wrapper for consistent profile pictures.
class AppNetworkAvatar extends StatelessWidget {
  final String? url;
  final double size;
  final Widget? errorWidget;

  const AppNetworkAvatar({
    super.key,
    this.url,
    this.size = 56,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = errorWidget ??
        Container(
          width: size,
          height: size,
          color: Colors.grey.shade200,
          child: Icon(Icons.person, size: size * 0.6, color: Colors.grey),
        );

    if (url == null || url!.isEmpty) return ClipOval(child: fallback);

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        memCacheWidth: size.toInt(),
        memCacheHeight: size.toInt(),
        placeholder: (context, _) => _Shimmer(width: size, height: size, circular: true),
        errorWidget: (context, url, _) => fallback,
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final bool circular;

  const _Shimmer({this.width, this.height, this.circular = false});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          shape: circular ? BoxShape.circle : BoxShape.rectangle,
        ),
      ),
    );
  }
}
