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
    return Image.asset(
      'assets/images/defualt-user.png',
      width: width,
      height: height,
      fit: fit,
    );
  }

  int? _toInt(double? v) => v == null ? null : v.toInt();
}

/// Circular avatar wrapper for consistent profile pictures.
class AppNetworkAvatar extends StatelessWidget {
  final String? url;
  final double size;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const AppNetworkAvatar({
    super.key,
    this.url,
    this.size = 56,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = errorWidget ??
        Image.asset(
          'assets/images/defualt-user.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        );

    final isCircular = borderRadius == null;

    if (url == null || url!.isEmpty) {
      return isCircular
          ? ClipOval(child: fallback)
          : ClipRRect(borderRadius: borderRadius!, child: fallback);
    }

    return isCircular
        ? ClipOval(
            child: CachedNetworkImage(
              imageUrl: url!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              memCacheWidth: size.toInt(),
              memCacheHeight: size.toInt(),
              placeholder: (context, _) =>
                  _Shimmer(width: size, height: size, circular: true),
              errorWidget: (context, url, _) => fallback,
            ),
          )
        : ClipRRect(
            borderRadius: borderRadius!,
            child: CachedNetworkImage(
              imageUrl: url!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              memCacheWidth: size.toInt(),
              memCacheHeight: size.toInt(),
              placeholder: (context, _) =>
                  _Shimmer(width: size, height: size, borderRadius: borderRadius),
              errorWidget: (context, url, _) => fallback,
            ),
          );
  }
}

class _Shimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final bool circular;
  final BorderRadius? borderRadius;

  const _Shimmer({
    this.width,
    this.height,
    this.circular = false,
    this.borderRadius,
  });

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
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}
