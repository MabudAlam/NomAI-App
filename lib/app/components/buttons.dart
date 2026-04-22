import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/utility/haptic_service.dart';

class PrimaryButton extends StatelessWidget {
  final String tile;
  final void Function() onPressed;

  const PrimaryButton({super.key, required this.tile, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await HapticService.light();
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: NomAIColors.darkPrimary,
        foregroundColor: NomAIColors.lightPrimary,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(tile),
    );
  }
}

class PrimaryButtonWithIcon extends StatelessWidget {
  final String tile;
  final IconData icon;
  final void Function() onPressed;
  final double? width;
  final bool isLoading;

  const PrimaryButtonWithIcon({
    super.key,
    required this.tile,
    required this.icon,
    required this.onPressed,
    this.width,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 30.w,
      height: 5.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 0.8.h,
            offset: Offset(0, 0.25.h),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () async {
                await HapticService.light();
                onPressed();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: NomAIColors.black,
          foregroundColor: NomAIColors.whiteText,
          minimumSize: Size(0, 5.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.w),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 3.w,
                height: 3.w,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 0.5.w,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 5.w),
                  SizedBox(width: 1.w),
                  Text(
                    tile,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class DisabledButton extends StatelessWidget {
  final String tile;
  final IconData? icon;

  const DisabledButton({super.key, required this.tile, this.icon});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor: NomAIColors.greyLight,
        disabledForegroundColor: NomAIColors.blackText.withValues(alpha: 0.4),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 8),
          ],
          Text(tile),
        ],
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? disabledBackgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final Widget? loadingWidget;
  final bool hasElevation;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 56,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.borderRadius = 16,
    this.padding,
    this.textStyle,
    this.loadingWidget,
    this.hasElevation = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: hasElevation
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            )
          : null,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () async {
                await HapticService.light();
                onPressed?.call();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? NomAIColors.black,
          foregroundColor: foregroundColor ?? Colors.white,
          disabledBackgroundColor: disabledBackgroundColor ?? NomAIColors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
          padding: padding ?? EdgeInsets.zero,
        ),
        child: isLoading
            ? loadingWidget ??
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: foregroundColor ?? Colors.white,
                    strokeWidth: 2,
                  ),
                )
            : Text(
                text,
                style: textStyle ??
                    TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
              ),
      ),
    );
  }
}