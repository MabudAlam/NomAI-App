import 'package:NomAi/app/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/modules/Chat/Controllers/ChatController.dart';
import 'package:NomAi/app/modules/Chat/Views/Components/ImagePickerButton.dart';
import 'package:NomAi/app/modules/Chat/Views/Components/ImagePreviewColumn.dart';
import 'package:NomAi/app/modules/Chat/Views/Components/SendButton.dart';

class MessageInput extends StatelessWidget {
  final ChatController controller;

  const MessageInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(3.w, 1.h, 3.w, 1.5.h),
      child: Obx(() {
        final hasImage = controller.selectedImage.value != null ||
            controller.isUploading.value;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (hasImage)
                  ImagePreviewColumn(controller: controller)
                else
                  ImagePickerButton(controller: controller),
                SizedBox(width: 2.w),
                Expanded(
                  child: TextField(
                    controller: controller.textController,
                    maxLines: 1,
                    maxLength: AppConstants.chatMessageMaxLength,
                    decoration: InputDecoration(
                      hintText: 'Message...',
                      hintStyle: TextStyle(color: NomAIColors.grey),
                      filled: true,
                      fillColor: NomAIColors.lightSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3.h),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.5.h,
                      ),
                      counterText: '',
                    ),
                    style: TextStyle(color: NomAIColors.blackText),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => controller.sendMessage(),
                  ),
                ),
                SizedBox(width: 2.w),
                SendButton(controller: controller),
              ],
            ),
          ],
        );
      }),
    );
  }
}
