import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUploading ? NomAIColors.greyLight : NomAIColors.blueGrey,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.send,
            color: isUploading ? NomAIColors.grey : NomAIColors.whiteText,
            size: 22,
          ),
        ),
      );
    });
  }
}