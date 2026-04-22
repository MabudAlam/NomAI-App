import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/modules/Auth/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:NomAi/app/modules/Scanner/controller/scanner_controller.dart';
import 'package:NomAi/app/modules/Scanner/views/scan_mode.dart';

class NomAICamera extends StatefulWidget {
  const NomAICamera({super.key});

  @override
  State<NomAICamera> createState() => _NomAICameraState();
}

class _NomAICameraState extends State<NomAICamera> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (image == null) return;

    if (mounted) {
      Navigator.pop(context);
    }

    final scannerController = Get.find<ScannerController>();
    final authBloc = context.read<AuthenticationBloc>();

    scannerController.processNutritionQueryRequest(
      authBloc.state.user!.uid,
      image,
      ScanMode.food,
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Scan Image'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: NomAIColors.blackText,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose how to capture your meal image',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Use Camera'),
              style: ElevatedButton.styleFrom(
                backgroundColor: NomAIColors.blackText,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.upload_file),
              label: const Text('Select File'),
              style: OutlinedButton.styleFrom(
                foregroundColor: NomAIColors.blackText,
                side: const BorderSide(color: Colors.black),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
