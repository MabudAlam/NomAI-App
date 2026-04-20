import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/modules/Chat/Controllers/ChatController.dart';

class SendButton extends StatelessWidget {
  final ChatController controller;

  const SendButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isUploading = controller.isUploading.value;
      return GestureDetector(
        onTap: isUploading ? null : () => controller.sendMessage(),
        child: Container(
          padding: EdgeInsets.all(1.5.h),
          decoration: BoxDecoration(
            color: isUploading ? NomAIColors.greyLight : NomAIColors.blueGrey,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_upward_rounded,
            color: isUploading ? NomAIColors.grey : NomAIColors.whiteText,
            size: 18.sp,
          ),
        ),
      );
    });
  }
}