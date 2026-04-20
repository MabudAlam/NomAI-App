import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/modules/Chat/Controllers/ChatController.dart';

class ImagePickerButton extends StatelessWidget {
  final ChatController controller;

  const ImagePickerButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: EdgeInsets.all(1.5.h),
        decoration: BoxDecoration(
          color: NomAIColors.lightSurface,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.camera_alt,
          color: NomAIColors.blackText,
          size: 18.sp,
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: NomAIColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(2.h)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 1.h),
            Container(
              width: 5.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: NomAIColors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(0.3.h),
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: Icon(Icons.photo_library, color: NomAIColors.blackText),
              title: Text('Gallery',
                  style: TextStyle(color: NomAIColors.blackText)),
              onTap: () {
                Navigator.pop(context);
                controller.pickImageFromGallery();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: NomAIColors.blackText),
              title: Text('Camera',
                  style: TextStyle(color: NomAIColors.blackText)),
              onTap: () {
                Navigator.pop(context);
                controller.pickImageFromCamera();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}