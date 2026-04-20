import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:NomAi/app/modules/Chat/Controllers/ChatController.dart';
import 'package:NomAi/app/modules/Chat/Views/Components/ImagePreviewWidget.dart';
import 'package:NomAi/app/modules/Chat/Views/Components/ImagePickerButton.dart';
import 'package:NomAi/app/modules/Chat/Views/Components/UploadingIndicator.dart';

class ImagePreviewColumn extends StatelessWidget {
  final ChatController controller;

  const ImagePreviewColumn({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() {
          if (controller.isUploading.value) {
            return const UploadingIndicator();
          }
          if (controller.selectedImage.value != null) {
            return ImagePreviewWidget(controller: controller);
          }
          return SizedBox(width: 6.h, height: 6.h);
        }),
        SizedBox(height: 1.h),
        ImagePickerButton(controller: controller),
      ],
    );
  }
}