import 'package:NomAi/app/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:NomAi/app/constants/colors.dart';

class ChatHeader extends StatelessWidget {
  const ChatHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      child: Row(
        children: [
          Image.asset(
            'assets/png/logo.png',
            width: 5.h,
            height: 5.h,
          ),
          SizedBox(width: 2.w),
          Text(
            AppConstants.appName,
            style: TextStyle(
              color: NomAIColors.whiteText,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
