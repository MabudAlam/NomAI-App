import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:NomAi/app/constants/colors.dart';

class UploadingIndicator extends StatelessWidget {
  const UploadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6.h,
      height: 6.h,
      decoration: BoxDecoration(
        color: NomAIColors.lightSurface,
        borderRadius: BorderRadius.circular(1.5.h),
      ),
      child: Center(
        child: SizedBox(
          width: 2.5.h,
          height: 2.5.h,
          child: CircularProgressIndicator(
            strokeWidth: 0.3.h,
            color: NomAIColors.grey,
          ),
        ),
      ),
    );
  }
}