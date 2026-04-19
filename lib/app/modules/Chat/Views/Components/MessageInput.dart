import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      padding: EdgeInsets.fromLTRB(12, 8, 12, 12),
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
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller.textController,
                    decoration: InputDecoration(
                      hintText: 'Message...',
                      hintStyle: TextStyle(color: NomAIColors.grey),
                      filled: true,
                      fillColor: NomAIColors.lightSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: TextStyle(color: NomAIColors.blackText),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => controller.sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                SendButton(controller: controller),
              ],
            ),
          ],
        );
      }),
    );
  }
}