import 'dart:math' as math;

import 'package:NomAi/app/components/buttons.dart';
import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/modules/Scanner/controller/scanner_controller.dart';
import 'package:NomAi/app/utility/haptic_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class WaterTrackerCard extends StatelessWidget {
  final String userId;

  const WaterTrackerCard({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final sc = Get.find<ScannerController>();

    return Obx(() {
      final consumed = sc.consumedWater.value;
      final goal = sc.maximumWater.value;
      final progress = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
      final exceededLimit = goal > 0 && consumed > goal;
      final valueText = goal > 0 ? '$consumed/$goal' : '$consumed';

      return Expanded(
        child: Bounceable(
          onTap: () async {
            await HapticService.light();
            _showWaterSheet(context, sc);
          },
          child: Material(
            color: NomAIColors.whiteText,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: NomAIColors.whiteText,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.water_drop_rounded,
                        color:
                            exceededLimit ? Colors.red : NomAIColors.waterColor,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Water',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.8.h),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: valueText,
                          style: TextStyle(
                            color: exceededLimit ? Colors.red : Colors.black,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' mL',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 0.8.h),
                  LinearProgressIndicator(
                    value: goal > 0 ? progress : 0,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      exceededLimit ? Colors.red : NomAIColors.waterColor,
                    ),
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  void _showWaterSheet(BuildContext context, ScannerController sc) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _WaterBottomSheet(userId: userId, sc: sc),
    );
  }
}

class _WaterBottomSheet extends StatelessWidget {
  final String userId;
  final ScannerController sc;

  const _WaterBottomSheet({required this.userId, required this.sc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 4.h),
      decoration: BoxDecoration(
        color: NomAIColors.whiteText,
        borderRadius: BorderRadius.vertical(top: Radius.circular(7.w)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 11.w,
                height: 0.6.h,
                decoration: BoxDecoration(
                  color: NomAIColors.black.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              SizedBox(height: 2.4.h),
              Text(
                'Hydration',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: 0.8.h),
              Text(
                'Track today\'s water intake',
                style: TextStyle(
                  fontSize: 11.2.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
              SizedBox(height: 2.4.h),
              Obx(() {
                final consumed = sc.consumedWater.value;
                final goal = sc.maximumWater.value;
                final progress =
                    goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
                return _WaterDetailGauge(
                  consumed: consumed,
                  goal: goal,
                  progress: progress,
                );
              }),
              SizedBox(height: 2.6.h),
              Row(
                children: [
                  Expanded(child: _buildPresetButton(context, '+150 mL', 150)),
                  SizedBox(width: 2.5.w),
                  Expanded(child: _buildPresetButton(context, '+250 mL', 250)),
                  SizedBox(width: 2.5.w),
                  Expanded(child: _buildPresetButton(context, '+350 mL', 350)),
                ],
              ),
              SizedBox(height: 1.2.h),
              Row(
                children: [
                  Expanded(child: _buildPresetButton(context, '+500 mL', 500)),
                  SizedBox(width: 2.5.w),
                  Expanded(child: _buildPresetButton(context, '+750 mL', 750)),
                  SizedBox(width: 2.5.w),
                  Expanded(child: _buildPresetButton(context, '+1 L', 1000)),
                ],
              ),
              SizedBox(height: 2.4.h),
              _CustomWaterField(userId: userId),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetButton(BuildContext context, String label, int amount) {
    return SizedBox(
      height: 5.3.h,
      child: PrimaryButton(
        tile: label,
        onPressed: () async {
          await HapticService.selection();
          await _add(context, amount);
        },
      ),
    );
  }

  Future<void> _add(BuildContext context, int ml) async {
    if (userId.isEmpty) return;
    if (sc.maximumWater.value <= 0) {
      Get.snackbar(
        'No Goal',
        'Set water goal in Settings',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    await sc.addWater(userId, ml);
    await HapticService.success();
    if (context.mounted) Navigator.pop(context);
  }
}

class _WaterDetailGauge extends StatelessWidget {
  final int consumed;
  final int goal;
  final double progress;

  const _WaterDetailGauge({
    required this.consumed,
    required this.goal,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final size = 62.w;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _WaterGaugePainter(progress: progress),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F8FC),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: SizedBox(
                    width: 12.w,
                    height: 14.w,
                    child: CustomPaint(
                      painter: _WaterDropPainter(progress: progress),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 1.6.h),
              Text(
                '$consumed',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF20242C),
                  height: 1,
                ),
              ),
              SizedBox(height: 0.6.h),
              Text(
                goal > 0 ? '/$goal mL' : 'Goal not set',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: const Color(0xFF7A818E),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WaterGaugePainter extends CustomPainter {
  final double progress;

  const _WaterGaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = size.width * 0.1;
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = math.pi * 0.75;
    const sweepAngle = math.pi * 1.5;

    final trackPaint = Paint()
      ..color = const Color(0xFFE8EEF4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF48B6FF),
          Color(0xFF7FD1FF),
        ],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle * progress,
        false,
        progressPaint,
      );
    }

    final tickPaint = Paint()
      ..color = const Color(0xFFD1D8E2)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i <= 10; i++) {
      final angle = startAngle + (sweepAngle / 10) * i;
      final outer = Offset(
        center.dx + math.cos(angle) * (radius - strokeWidth * 0.15),
        center.dy + math.sin(angle) * (radius - strokeWidth * 0.15),
      );
      final inner = Offset(
        center.dx + math.cos(angle) * (radius - strokeWidth * 0.55),
        center.dy + math.sin(angle) * (radius - strokeWidth * 0.55),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaterGaugePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _WaterDropPainter extends CustomPainter {
  final double progress;

  const _WaterDropPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final dropPath = _buildDropPath(size);
    canvas.drawShadow(dropPath, const Color(0x12000000), 8, false);

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFB7E6FF),
          Color(0xFF4EB5FF),
          Color(0xFF239AE8),
        ],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = const Color(0xFF7ABFE8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35;

    canvas.drawPath(dropPath, fillPaint);
    canvas.drawPath(dropPath, strokePaint);

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.32)
      ..style = PaintingStyle.fill;
    final highlightPath = Path()
      ..moveTo(size.width * 0.42, size.height * 0.16)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.34,
        size.width * 0.28,
        size.height * 0.58,
      )
      ..quadraticBezierTo(
        size.width * 0.34,
        size.height * 0.42,
        size.width * 0.48,
        size.height * 0.28,
      )
      ..close();
    canvas.drawPath(highlightPath, highlightPaint);
  }

  Path _buildDropPath(Size size) {
    final w = size.width;
    final h = size.height;

    return Path()
      ..moveTo(w * 0.5, h * 0.04)
      ..cubicTo(w * 0.74, h * 0.22, w * 0.9, h * 0.45, w * 0.86, h * 0.67)
      ..cubicTo(w * 0.82, h * 0.86, w * 0.67, h * 0.98, w * 0.5, h * 0.98)
      ..cubicTo(w * 0.33, h * 0.98, w * 0.18, h * 0.86, w * 0.14, h * 0.67)
      ..cubicTo(w * 0.1, h * 0.45, w * 0.26, h * 0.22, w * 0.5, h * 0.04)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _WaterDropPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _CustomWaterField extends StatefulWidget {
  final String userId;

  const _CustomWaterField({required this.userId});

  @override
  State<_CustomWaterField> createState() => _CustomWaterFieldState();
}

class _CustomWaterFieldState extends State<_CustomWaterField> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sc = Get.find<ScannerController>();

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Custom amount',
              suffixText: 'mL',
              filled: true,
              fillColor: const Color(0xFFF6F9FC),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFDCE5EF)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: NomAIColors.waterColor),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFDCE5EF)),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        SizedBox(
          height: 5.6.h,
          width: 24.w,
          child: PrimaryButton(
            tile: 'Add',
            onPressed: () async {
              await HapticService.selection();
              final ml = int.tryParse(_ctrl.text);
              if (ml == null || ml <= 0) {
                Get.snackbar(
                  'Invalid',
                  'Enter a valid amount',
                  snackPosition: SnackPosition.BOTTOM,
                );
                await HapticService.error();
                return;
              }
              if (widget.userId.isEmpty) return;
              if (sc.maximumWater.value <= 0) {
                Get.snackbar(
                  'No Goal',
                  'Set water goal in Settings',
                  snackPosition: SnackPosition.BOTTOM,
                );
                await HapticService.error();
                return;
              }
              await sc.addWater(widget.userId, ml);
              await HapticService.success();
              _ctrl.clear();
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }
}
