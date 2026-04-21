import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:NomAi/app/constants/colors.dart';

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: NomAIColors.greyLight,
      highlightColor: NomAIColors.whiteText,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: NomAIColors.greyLight,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerCircle extends StatelessWidget {
  final double size;

  const ShimmerCircle({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: NomAIColors.greyLight,
      highlightColor: NomAIColors.whiteText,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: NomAIColors.greyLight,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class ShimmerText extends StatelessWidget {
  final double width;
  final double height;

  const ShimmerText({
    super.key,
    this.width = double.infinity,
    this.height = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: NomAIColors.greyLight,
      highlightColor: NomAIColors.whiteText,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: NomAIColors.greyLight,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class ShimmerChip extends StatelessWidget {
  final double width;
  final double height;

  const ShimmerChip({
    super.key,
    this.width = 60,
    this.height = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: NomAIColors.greyLight,
      highlightColor: NomAIColors.whiteText,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: NomAIColors.greyLight,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double? height;

  const ShimmerCard({
    super.key,
    this.margin,
    this.padding,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NomAIColors.greyLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Shimmer.fromColors(
        baseColor: NomAIColors.greyLight,
        highlightColor: NomAIColors.whiteText,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Container(height: 18, color: NomAIColors.greyLight)),
                Container(
                    width: 60,
                    height: 24,
                    decoration: BoxDecoration(
                      color: NomAIColors.greyLight,
                      borderRadius: BorderRadius.circular(8),
                    )),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 14, color: NomAIColors.greyLight),
            const SizedBox(height: 8),
            Container(width: 200, height: 14, color: NomAIColors.greyLight),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                    width: 60,
                    height: 24,
                    decoration: BoxDecoration(
                      color: NomAIColors.greyLight,
                      borderRadius: BorderRadius.circular(6),
                    )),
                const SizedBox(width: 8),
                Container(
                    width: 60,
                    height: 24,
                    decoration: BoxDecoration(
                      color: NomAIColors.greyLight,
                      borderRadius: BorderRadius.circular(6),
                    )),
                const SizedBox(width: 8),
                Container(
                    width: 60,
                    height: 24,
                    decoration: BoxDecoration(
                      color: NomAIColors.greyLight,
                      borderRadius: BorderRadius.circular(6),
                    )),
                const SizedBox(width: 8),
                Container(
                    width: 60,
                    height: 24,
                    decoration: BoxDecoration(
                      color: NomAIColors.greyLight,
                      borderRadius: BorderRadius.circular(6),
                    )),
              ],
            ),
            if (height != null) ...[
              const SizedBox(height: 12),
              Container(height: height, color: NomAIColors.greyLight),
            ],
          ],
        ),
      ),
    );
  }
}

class ShimmerMealCard extends StatelessWidget {
  const ShimmerMealCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: NomAIColors.greyLight,
      highlightColor: NomAIColors.whiteText,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: NomAIColors.greyLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 18,
                    decoration: BoxDecoration(
                      color: NomAIColors.greyLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: NomAIColors.greyLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 14,
              decoration: BoxDecoration(
                color: NomAIColors.greyLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 200,
              height: 14,
              decoration: BoxDecoration(
                color: NomAIColors.greyLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: NomAIColors.greyLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: NomAIColors.greyLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: NomAIColors.greyLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: NomAIColors.greyLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsets? padding;

  const ShimmerList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 120,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: itemCount,
      itemBuilder: (context, index) => const ShimmerMealCard(),
    );
  }
}

class ShimmerDaySelector extends StatelessWidget {
  const ShimmerDaySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Shimmer.fromColors(
              baseColor: NomAIColors.greyLight,
              highlightColor: NomAIColors.whiteText,
              child: Container(
                width: 60,
                height: 24,
                decoration: BoxDecoration(
                  color: NomAIColors.greyLight,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ShimmerChatBubble extends StatelessWidget {
  final bool isUser;
  final double width;

  const ShimmerChatBubble({
    super.key,
    this.isUser = false,
    this.width = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Shimmer.fromColors(
        baseColor: NomAIColors.greyLight,
        highlightColor: NomAIColors.whiteText,
        child: Container(
          margin: EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * width,
          ),
          decoration: BoxDecoration(
            color: isUser ? NomAIColors.black : NomAIColors.greyLight,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 14,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isUser
                      ? Colors.white.withOpacity(0.2)
                      : NomAIColors.greyLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 14,
                width: 150,
                decoration: BoxDecoration(
                  color: isUser
                      ? Colors.white.withOpacity(0.2)
                      : NomAIColors.greyLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 14,
                width: 100,
                decoration: BoxDecoration(
                  color: isUser
                      ? Colors.white.withOpacity(0.2)
                      : NomAIColors.greyLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShimmerChatList extends StatelessWidget {
  final int messageCount;

  const ShimmerChatList({
    super.key,
    this.messageCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      itemCount: messageCount,
      itemBuilder: (context, index) {
        final isUser = index % 2 == 0;
        return ShimmerChatBubble(isUser: isUser);
      },
    );
  }
}

class ShimmerNutritionCard extends StatelessWidget {
  const ShimmerNutritionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: NomAIColors.greyLight,
      highlightColor: NomAIColors.whiteText,
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: NomAIColors.greyLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: NomAIColors.greyLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 150,
                        decoration: BoxDecoration(
                          color: NomAIColors.greyLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                4,
                (index) => Container(
                  width: 60,
                  height: 40,
                  decoration: BoxDecoration(
                    color: NomAIColors.greyLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerChatWithNutrition extends StatelessWidget {
  final int messageCount;
  final List<int> nutritionIndices;

  const ShimmerChatWithNutrition({
    super.key,
    this.messageCount = 6,
    this.nutritionIndices = const [2, 4],
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      itemCount: messageCount + nutritionIndices.length,
      itemBuilder: (context, index) {
        if (nutritionIndices.contains(index)) {
          return const ShimmerNutritionCard();
        }
        final isUser = index % 2 == 0;
        return ShimmerChatBubble(isUser: isUser);
      },
    );
  }
}
