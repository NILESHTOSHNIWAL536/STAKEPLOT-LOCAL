import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/theme_helper.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/routes/route_strides.dart';
import 'package:share_plus/share_plus.dart';

class StridesScreen extends StatefulWidget {
  const StridesScreen({super.key});

  @override
  State<StridesScreen> createState() => _StridesScreenState();
}

class _StridesScreenState extends State<StridesScreen> {
  Map<String, dynamic> data = {
    "total": 0,
    "friendRank": 0,
    "nextMilestone": 10,
    "currentStreak": 0,
    "longestStreak": 0,
  };
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadStrides();
  }

  Future<void> _loadStrides() async {
    try {
      final response = await getDataApiCall(StridesRoutes.myStrides);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            data = Map<String, dynamic>.from(body["data"] ?? {});
            loading = false;
          });
        }
      } else if (mounted) {
        setState(() => loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final total = (data["total"] ?? 0) as int;
    final nextMilestone = (data["nextMilestone"] ?? 10) as int;
    final progress =
        nextMilestone == 0 ? 0.0 : (total % nextMilestone) / nextMilestone;
    final remaining = math.max(0, nextMilestone - (total % nextMilestone));
    final points = (data["recentEvents"] as List?)?.isNotEmpty == true
        ? (data["recentEvents"][0]["points"] ?? 0)
        : 0;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: loading
            ? Center(
                child: CircularProgressIndicator(color: colors.primary),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _circleButton(
                            Icons.arrow_back, () => Navigator.pop(context)),
                        _circleButton(
                          Icons.share,
                          () => SharePlus.instance.share(
                            ShareParams(
                                text: "I have $total Strides on Stakeplot."),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 34),
                    SizedBox(
                      height: 210,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _MountainPainter(
                          mountainColor: colors.primary,
                          cutColor: colors.background,
                        ),
                      ),
                    ),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "$total",
                            style: FontManager().getTextStyle(
                              context,
                              fontSize: 43,
                              lWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _gainPill(
                            "${points >= 0 ? '+' : '-'}${points.abs()}",
                          ),
                          // _gainPill("${(data["recentEvents"] as List?)?.isNotEmpty == true ? (data["recentEvents"][0]["points"] ?? 0) : 0}"),
                        ],
                      ),
                    ),
                    Center(
                      child: Text(
                        "YOUR STRIDES",
                        style: FontManager().getTextStyle(
                          context,
                          fontSize: 22,
                          lWeight: FontWeight.w700,
                          color: colors.secondaryText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 38),
                    _infoCard(
                      icon: Icons.groups_rounded,
                      title: "#${data["friendRank"] ?? 0}",
                      subtitle: "Among your friends",
                    ),
                    const SizedBox(height: 10),
                    _milestoneCard(nextMilestone, total % nextMilestone,
                        progress, remaining),
                    const SizedBox(height: 24),
                    Text(
                      "Progress",
                      style: FontManager().getTextStyle(
                        context,
                        fontSize: 19,
                        lWeight: FontWeight.w700,
                        color: colors.onBackground,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _infoCard(
                      icon: Icons.terrain_rounded,
                      title: "${data["longestStreak"] ?? 0} Days",
                      subtitle: "Longest Stride Record",
                    ),
                    const SizedBox(height: 10),
                    _infoCard(
                      icon: Icons.local_fire_department_rounded,
                      title: "${data["currentStreak"] ?? 0} Days",
                      subtitle: "Current daily streak",
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: colors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: colors.border),
          boxShadow: context.isDarkMode
              ? []
              : const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.08),
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
                ],
        ),
        child: Icon(icon, color: colors.primary, size: 22),
      ),
    );
  }

  Widget _gainPill(String text) {
    final colors = context.appColors;
    final gainColor = colors.credit;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: gainColor.withOpacity(context.isDarkMode ? 0.14 : 0.08),
        border: Border.all(color: gainColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: gainColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _infoCard(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 34, color: colors.primary),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: colors.secondaryText),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _milestoneCard(
      int nextMilestone, int current, double progress, int remaining) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(9)),
                child: const Icon(Icons.track_changes, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Next Milestone",
                      style: TextStyle(
                        color: colors.secondaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "$nextMilestone Strides",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "$current/$nextMilestone",
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 8,
              backgroundColor: colors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation(colors.primary),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "$remaining more to unlock achievement badge",
            style: TextStyle(color: colors.secondaryText, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _MountainPainter extends CustomPainter {
  final Color mountainColor;
  final Color cutColor;

  const _MountainPainter({
    required this.mountainColor,
    required this.cutColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = mountainColor;
    final path = Path()
      ..moveTo(0, size.height * .92)
      ..lineTo(size.width * .14, size.height * .68)
      ..lineTo(size.width * .22, size.height * .72)
      ..lineTo(size.width * .47, size.height * .05)
      ..lineTo(size.width * .68, size.height * .68)
      ..lineTo(size.width * .75, size.height * .56)
      ..lineTo(size.width, size.height * .82)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);

    final snow = Paint()..color = cutColor;
    final snowPath = Path()
      ..moveTo(size.width * .47, size.height * .05)
      ..lineTo(size.width * .39, size.height * .38)
      ..lineTo(size.width * .47, size.height * .29)
      ..lineTo(size.width * .5, size.height * .48)
      ..lineTo(size.width * .57, size.height * .36)
      ..close();
    canvas.drawPath(snowPath, snow);

    for (final x in [.2, .32, .6, .78]) {
      canvas.drawLine(
        Offset(size.width * x, size.height * .78),
        Offset(size.width * (x + .1), size.height * .55),
        Paint()
          ..color = cutColor
          ..strokeWidth = 3,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MountainPainter oldDelegate) {
    return oldDelegate.mountainColor != mountainColor ||
        oldDelegate.cutColor != cutColor;
  }
}
