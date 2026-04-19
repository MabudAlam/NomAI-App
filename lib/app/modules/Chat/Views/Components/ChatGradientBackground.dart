import 'package:flutter/material.dart';
import 'package:NomAi/app/constants/colors.dart';

class ChatGradientBackground extends StatelessWidget {
  final Widget child;

  const ChatGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            NomAIColors.blueGrey,
            NomAIColors.blueGrey.withValues(alpha: 0.9),
            NomAIColors.blueGrey.withValues(alpha: 0.8),
            NomAIColors.blueGrey.withValues(alpha: 0.7),
            NomAIColors.blueGrey.withValues(alpha: 0.6),
            NomAIColors.blueGrey.withValues(alpha: 0.5),
            NomAIColors.blueGrey.withValues(alpha: 0.4),
            NomAIColors.blueGrey.withValues(alpha: 0.3),
            NomAIColors.blueGrey.withValues(alpha: 0.2),
            NomAIColors.blueGrey.withValues(alpha: 0.1),
            NomAIColors.whiteText,
          ],
          stops: const [
            0.0,
            0.1,
            0.2,
            0.3,
            0.4,
            0.5,
            0.6,
            0.7,
            0.8,
            0.9,
            1.0,
          ],
        ),
      ),
      child: child,
    );
  }
}