import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/modules/Chat/Controllers/ChatController.dart';

class ImagePreviewWidget extends StatelessWidget {
  final ChatController controller;

  const ImagePreviewWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final image = controller.selectedImage.value!;

    return Stack(
      children: [
        Container(
          width: 8.h,
          height: 8.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1.5.h),
            image: DecorationImage(
              image: _getImage(image),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: -0.8.h,
          right: -0.8.h,
          child: GestureDetector(
            onTap: () => controller.clearSelectedImage(),
            child: Container(
              padding: EdgeInsets.all(0.5.h),
              decoration: const BoxDecoration(
                color: NomAIColors.darkPrimary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 12.sp,
                color: NomAIColors.whiteText,
              ),
            ),
          ),
        ),
      ],
    );
  }

  ImageProvider _getImage(XFile image) {
    if (kIsWeb) {
      return NetworkImage(image.path);
    } else {
      return FileImage(File(image.path));
    }
  }
}
