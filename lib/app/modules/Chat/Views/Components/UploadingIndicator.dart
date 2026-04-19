import 'package:flutter/material.dart';
import 'package:NomAi/app/constants/colors.dart';

class UploadingIndicator extends StatelessWidget {
  const UploadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: NomAIColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: NomAIColors.grey,
          ),
        ),
      ),
    );
  }
}