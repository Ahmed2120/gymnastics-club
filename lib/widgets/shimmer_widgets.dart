import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// [Skeleton] is a primitive widget for building shimmer layouts.
class Skeleton extends StatelessWidget {
  const Skeleton({
    super.key,
    this.height,
    this.width,
    this.borderRadius = 8,
    this.shape = BoxShape.rectangle,
  });

  final double? height, width;
  final double borderRadius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.all(Radius.circular(borderRadius))
            : null,
      ),
    );
  }
}

/// [MainShimmer] provides a factory-based professional structure for loading states.
class MainShimmer extends StatelessWidget {
  const MainShimmer._({required this.child});

  final Widget child;

  /// Shimmer for Grid Statistics (Dashboard)
  factory MainShimmer.grid({required int crossAxisCount, int itemCount = 4}) {
    return MainShimmer._(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 1.5,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
        ),
        itemBuilder: (_, __) => const Skeleton(),
      ),
    );
  }

  /// Shimmer for Detailed Management Cards (Icon, Title, Subtitle, Buttons)
  factory MainShimmer.cardList({int itemCount = 4}) {
    return MainShimmer._(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, __) => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Skeleton(height: 44, width: 44, borderRadius: 22),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Skeleton(height: 18, width: 150),
                        SizedBox(height: 6),
                        Skeleton(height: 12, width: 100),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Skeleton(height: 12, width: double.infinity),
              const SizedBox(height: 6),
              const Skeleton(height: 12, width: 200),
            ],
          ),
        ),
      ),
    );
  }

  /// Shimmer for a single card (used for pagination "load more")
  factory MainShimmer.single({double height = 100, double borderRadius = 10}) {
    return MainShimmer._(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Skeleton(height: height, borderRadius: borderRadius),
      ),
    );
  }

  /// Shimmer for Statistics Cards (Attendance)
  factory MainShimmer.statCard() {
    return MainShimmer._(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Skeleton(height: 28, width: 28, borderRadius: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(height: 22, width: 60),
                SizedBox(height: 4),
                Skeleton(height: 12, width: 80),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Shimmer for Achievement Cards
  factory MainShimmer.achievementCard({int itemCount = 3}) {
    return MainShimmer._(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Skeleton(height: 60, width: 60, shape: BoxShape.circle),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(height: 20, width: 140),
                    SizedBox(height: 12),
                    Skeleton(height: 14, width: 100),
                    SizedBox(height: 12),
                    Skeleton(height: 16, width: double.infinity),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shimmer for List Items (Vertical) - Simple rectangles
  factory MainShimmer.list({int itemCount = 5, double height = 150}) {
    return MainShimmer._(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => Skeleton(height: height),
      ),
    );
  }

  /// Shimmer for a full calendar layout
  factory MainShimmer.calendar() {
    return MainShimmer._(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Skeleton(height: 20, width: 80),
                Skeleton(height: 20, width: 120),
              ],
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: 7,
              itemBuilder: (_, __) =>
                  const Center(child: Skeleton(height: 12, width: 20)),
            ),
            const SizedBox(height: 18),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: 31,
              itemBuilder: (_, __) => const Skeleton(shape: BoxShape.circle),
            ),
          ],
        ),
      ),
    );
  }

  /// Shimmer for Horizontal Card Lists (Home News/Achievements)
  factory MainShimmer.horizontalList({
    int itemCount = 3,
    double height = 300,
    double width = 300,
  }) {
    return MainShimmer._(
      child: SizedBox(
        height: height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: itemCount,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, __) => Container(
            width: width,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Skeleton(height: 20, width: 180),
                const SizedBox(height: 12),
                const Skeleton(height: 14, width: 240),
                const SizedBox(height: 8),
                const Skeleton(height: 14, width: 200),
                const Spacer(),
                Skeleton(
                  height: height * 0.5,
                  width: double.infinity,
                  borderRadius: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.white,
      period: const Duration(milliseconds: 1200),
      child: child,
    );
  }
}
