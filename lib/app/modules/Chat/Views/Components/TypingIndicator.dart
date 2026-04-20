import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:NomAi/app/constants/colors.dart';

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 1.h, top: 0.5.h),
        padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: NomAIColors.lightSurface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(2.h),
            topRight: Radius.circular(2.h),
            bottomLeft: Radius.circular(0.5.h),
            bottomRight: Radius.circular(2.h),
          ),
          boxShadow: [
            BoxShadow(
              color: NomAIColors.blackText.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'NomAI is thinking',
              style: TextStyle(
                color: NomAIColors.blackText,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 1.w),
            DotAnimation(delay: 0),
            SizedBox(width: 0.8.w),
            DotAnimation(delay: 200),
            SizedBox(width: 0.8.w),
            DotAnimation(delay: 400),
          ],
        ),
      ),
    );
  }
}

class DotAnimation extends StatefulWidget {
  final int delay;
  const DotAnimation({super.key, this.delay = 0});

  @override
  State<DotAnimation> createState() => _DotAnimationState();
}

class _DotAnimationState extends State<DotAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 0.8.h,
          height: 0.8.h,
          decoration: BoxDecoration(
            color: NomAIColors.blackText.withValues(
              alpha: 0.3 + (_animation.value * 0.7),
            ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
