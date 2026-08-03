import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/costants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/models/achievement_model.dart';
import '../../../widgets/main_text.dart';
import '../../profile/profile_controller/child_riverpod.dart';
import '../achievement_controller/achievement_riverpod.dart';

class PlayerPortfolioPage extends ConsumerStatefulWidget {
  const PlayerPortfolioPage({super.key});

  @override
  ConsumerState<PlayerPortfolioPage> createState() => _PlayerPortfolioPageState();
}

class _PlayerPortfolioPageState extends ConsumerState<PlayerPortfolioPage> {
  @override
  void initState() {
    super.initState();
    // Force Landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    // Hide system UI overlay for full-screen immersive view
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Revert orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedChild = ref.watch(childRiverpod).selectedChild;
    final achievements = ref.watch(achievementRiverpod).achievementList;

    // Filter achievements
    final goldCount = _getCount(achievements, 'gold');
    final silverCount = _getCount(achievements, 'silver');

    // Get the most recent achievement years for the medals
    final goldYear = _getMostRecentYear(achievements, 'gold');
    final silverYear = _getMostRecentYear(achievements, 'silver');

    // Get tournament/participation dates
    final participationDates = achievements
        .where((a) => a.date != null)
        .map((a) => DateFormat('d/M/yy').format(a.date!))
        .take(6)
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Premium Custom Painted Background
          Positioned.fill(
            child: CustomPaint(
              painter: PortfolioBackgroundPainter(),
            ),
          ),

          // 2. Stars overlays (like in the photo)
          const Positioned(
            left: 40,
            top: 30,
            child: Icon(Icons.star, color: Colors.white30, size: 14),
          ),
          const Positioned(
            left: 20,
            top: 60,
            child: Icon(Icons.star, color: Colors.white24, size: 18),
          ),
          const Positioned(
            left: 50,
            bottom: 30,
            child: Icon(Icons.star, color: Colors.white12, size: 12),
          ),
          // Stars on the top right
          Positioned(
            right: MediaQuery.of(context).size.width * 0.42,
            top: 25,
            child: Row(
              textDirection: TextDirection.ltr,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.star, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Icon(Icons.star, color: AppColors.primaryCrimson, size: 16),
                SizedBox(width: 8),
                Icon(Icons.star, color: AppColors.primaryCrimson, size: 12),
              ],
            ),
          ),

          // 3. Gymnast Silhouette Icons on the far right (like the photo)
          Positioned(
            right: 20,
            top: 0,
            bottom: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.sports_gymnastics, color: Colors.white.withValues(alpha: 0.15), size: 30),
                Icon(Icons.emoji_events, color: Colors.white.withValues(alpha: 0.15), size: 30),
                Icon(Icons.star, color: Colors.white.withValues(alpha: 0.15), size: 30),
              ],
            ),
          ),

          // 4. Main Contents Layout
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Row(
                textDirection: TextDirection.ltr,
                children: [
                  // --- LEFT SIDE: Achievements & Awards Card ---
                  Expanded(
                    flex: 6,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB).withValues(alpha: 0.95), // Light silver/gray
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white, width: 3.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header "الإنجازات والجوائز"
                            const Center(
                              child: MainText(
                                "الإنجازات والجوائز",
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // The 3 columns (Gold, Silver, Tournaments)
                            Row(
                              textDirection: TextDirection.ltr,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // Gold Medals Column
                                Expanded(
                                  child: _buildMedalColumn(
                                    title: "ميداليات ذهبية",
                                    color: AppColors.achievementGold,
                                    year: goldYear,
                                    count: goldCount,
                                    isGold: true,
                                  ),
                                ),
                                Container(
                                  width: 1.5,
                                  height: 80,
                                  color: Colors.black12,
                                ),
                                // Silver Medals Column
                                Expanded(
                                  child: _buildMedalColumn(
                                    title: "ميداليات فضية",
                                    color: const Color(0xFFC0C0C0),
                                    year: silverYear,
                                    count: silverCount,
                                    isGold: false,
                                  ),
                                ),
                                Container(
                                  width: 1.5,
                                  height: 80,
                                  color: Colors.black12,
                                ),
                                // Participation Column
                                Expanded(
                                  child: _buildParticipationColumn(participationDates),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // --- RIGHT SIDE: Logo, Header and Player Photo ---
                  Expanded(
                    flex: 5,
                    child: Stack(
                      children: [
                        // A. Middle section: Logo and Name
                        Positioned(
                          left: 0,
                          right: 145, // Leave space for photo on the right
                          top: 0,
                          bottom: 0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Circular Gymnastics Club Logo
                              Container(
                                width: 85,
                                height: 85,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black,
                                  border: Border.all(color: AppColors.primaryCrimson, width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryCrimson.withValues(alpha: 0.5),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Image.asset(
                                      AppAssets.logoTransparent,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.sports_gymnastics, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              // "بروفايل اللاعب" subheader
                              MainText(
                                "بروفايل اللاعب",
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withValues(alpha: 0.9),
                                shadows: const [
                                  Shadow(
                                    color: Colors.black87,
                                    offset: Offset(1, 1),
                                    blurRadius: 3,
                                  )
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Player Name
                              MainText(
                                selectedChild?.name ?? 'البطل الرياضي',
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                maxLines: 2,
                                textAlign: TextAlign.right,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black,
                                    offset: Offset(2, 2),
                                    blurRadius: 6,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),

                        // B. Far Right: Player Photo
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Hero(
                              tag: 'player_portfolio_avatar',
                              child: Container(
                                width: 130,
                                height: 180, // Fixed size to prevent stretching
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryCrimson.withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: selectedChild?.imageUrl != null && selectedChild!.imageUrl!.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: selectedChild.imageUrl!,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: Colors.grey[900],
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.primaryCrimson,
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Image.asset(
                                          AppAssets.userPlaceholder,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Image.asset(
                                        AppAssets.userPlaceholder,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ],
              ),
            ),
          ),

          // 5. Floating Glassmorphic Close Button (Top-Left)
          Positioned(
            left: 16,
            top: 16,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.5),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedalColumn({
    required String title,
    required Color color,
    required String year,
    required int count,
    required bool isGold,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MainText(
          title,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF374151),
        ),
        const SizedBox(height: 6),
        if (count > 0)
          // The Medal Badge representation
          Stack(
            alignment: Alignment.center,
            children: [
              // Ribbon
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.rotate(
                        angle: -pi / 6,
                        child: Container(
                          width: 14,
                          height: 18,
                          color: AppColors.primaryCrimson,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Transform.rotate(
                        angle: pi / 6,
                        child: Container(
                          width: 14,
                          height: 18,
                          color: AppColors.primaryCrimson,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
              // Medal Circle
              Positioned(
                bottom: 0,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isGold
                          ? [const Color(0xFFFFF275), const Color(0xFFE5A900)]
                          : [const Color(0xFFFFFFFF), const Color(0xFF9E9E9E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Center(
                    child: MainText(
                      "$count",
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isGold ? const Color(0xFF6B4500) : const Color(0xFF374151),
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          // Disabled/No medals look
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.05),
              border: Border.all(color: Colors.black12, width: 1),
            ),
            child: const Icon(Icons.lock_outline_rounded, color: Colors.black26, size: 18),
          ),
        const SizedBox(height: 4),
        MainText(
          count > 0 && year.isNotEmpty ? "أحدثها $year" : "$count مَيْدالِيَات",
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ],
    );
  }

  Widget _buildParticipationColumn(List<String> dates) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const MainText(
          "المشاركة في بطولات",
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF374151),
        ),
        const SizedBox(height: 4),
        if (dates.isNotEmpty)
          SizedBox(
            height: 52,
            width: 100,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 1.5,
              ),
              itemCount: min(dates.length, 6),
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black12, width: 0.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.emoji_events_rounded, color: AppColors.primaryCrimson, size: 10),
                      FittedBox(
                        child: MainText(
                          dates[index],
                          fontSize: 6,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        else
          Container(
            height: 52,
            alignment: Alignment.center,
            child: const MainText(
              "لا يوجد مشاركات",
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.black38,
            ),
          ),
      ],
    );
  }

  int _getCount(List<AchievementModel> achievements, String type) {
    return achievements.where((a) {
      final t = a.championType?.toLowerCase() ?? '';
      if (type == 'gold') return t == 'gold' || t == 'ذهبية' || t == 'ذهب';
      if (type == 'silver') return t == 'silver' || t == 'فضية' || t == 'فضة';
      if (type == 'bronze') return t == 'bronze' || t == 'برونزية' || t == 'برونز';
      return false;
    }).length;
  }

  String _getMostRecentYear(List<AchievementModel> achievements, String type) {
    final filtered = achievements.where((a) {
      final t = a.championType?.toLowerCase() ?? '';
      if (type == 'gold') return t == 'gold' || t == 'ذهبية' || t == 'ذهب';
      if (type == 'silver') return t == 'silver' || t == 'فضية' || t == 'فضة';
      return false;
    }).toList();

    if (filtered.isEmpty) return '';

    // Sort by date descending
    filtered.sort((a, b) {
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return b.date!.compareTo(a.date!);
    });

    final newestDate = filtered.first.date;
    if (newestDate != null) {
      return newestDate.year.toString();
    }
    return '';
  }
}

// Background painter to paint red radial gradient and metallic silver bands
class PortfolioBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // 1. Radial crimson gradient background (deep red -> dark red)
    final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final bgGradient = RadialGradient(
      center: const Alignment(0.3, 0.0), // Center towards the right where the logo/gymnast is
      radius: 1.2,
      colors: [
        const Color(0xFFD32F2F), // Bright crimson
        const Color(0xFF7F0000), // Rich dark red
        const Color(0xFF3E0000), // Darkest red/almost black on edges
      ],
      stops: const [0.0, 0.6, 1.0],
    );
    paint.shader = bgGradient.createShader(bgRect);
    canvas.drawRect(bgRect, paint);

    // 2. Main diagonal metallic band
    final metallicGradient = const LinearGradient(
      colors: [
        Color(0xFFEAEAEA),
        Color(0xFFB5B5B5),
        Color(0xFFE2E2E2),
        Color(0xFF919191),
      ],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    );

    final metallicRect = Rect.fromLTWH(size.width * 0.4, 0, size.width * 0.4, size.height);
    final metalPaint = Paint()
      ..shader = metallicGradient.createShader(metallicRect);

    // Path for major metallic stripe (slanting)
    final path1 = Path()
      ..moveTo(size.width * 0.52, size.height)
      ..lineTo(size.width * 0.63, size.height)
      ..lineTo(size.width * 0.88, 0)
      ..lineTo(size.width * 0.77, 0)
      ..close();
    canvas.drawPath(path1, metalPaint);

    // Path for thin accent metallic stripe
    final path2 = Path()
      ..moveTo(size.width * 0.47, size.height)
      ..lineTo(size.width * 0.50, size.height)
      ..lineTo(size.width * 0.75, 0)
      ..lineTo(size.width * 0.72, 0)
      ..close();
    canvas.drawPath(path2, metalPaint);

    // 3. Highlight borders (dark/light) along metallic slants
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Dark outline for main band
    strokePaint.color = Colors.black87;
    canvas.drawLine(Offset(size.width * 0.52, size.height), Offset(size.width * 0.77, 0), strokePaint);
    canvas.drawLine(Offset(size.width * 0.63, size.height), Offset(size.width * 0.88, 0), strokePaint);

    // Red glowing line
    strokePaint.color = AppColors.primaryCrimson;
    strokePaint.strokeWidth = 1.5;
    canvas.drawLine(Offset(size.width * 0.51, size.height), Offset(size.width * 0.76, 0), strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
