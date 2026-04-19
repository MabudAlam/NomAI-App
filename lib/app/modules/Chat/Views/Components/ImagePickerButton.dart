import 'package:flutter/material.dart';
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: NomAIColors.lightSurface,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.camera_alt,
          color: NomAIColors.blackText,
          size: 22,
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: NomAIColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: NomAIColors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}