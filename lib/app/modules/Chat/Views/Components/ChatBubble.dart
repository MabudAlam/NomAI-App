import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/modules/Chat/Controllers/ChatController.dart';
import 'package:NomAi/app/components/dialogs.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.text));
    AppDialogs.showSuccessSnackbar(
      title: 'Copied',
      message: 'Copied to clipboard',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 1.2.h),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.imageUrl != null)
              Container(
                margin: EdgeInsets.only(bottom: 0.8.h),
                height: 22.h,
                width: 22.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1.5.h),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(message.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 3.5.w,
                vertical: 1.5.h,
              ),
              decoration: BoxDecoration(
                color: isUser ? NomAIColors.black : NomAIColors.lightSurface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(2.h),
                  topRight: Radius.circular(2.h),
                  bottomLeft: Radius.circular(isUser ? 2.h : 0.5.h),
                  bottomRight: Radius.circular(isUser ? 0.5.h : 2.h),
                ),
                boxShadow: [
                  BoxShadow(
                    color: NomAIColors.blackText.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isUser
                  ? Text(
                      message.text,
                      style: TextStyle(
                        color: NomAIColors.whiteText,
                        fontSize: 14.sp,
                        height: 1.4,
                      ),
                    )
                  : MarkdownBody(
                      data: message.text,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          color: NomAIColors.blackText,
                          fontSize: 14.sp,
                          height: 1.5,
                        ),
                        h1: TextStyle(
                          color: NomAIColors.blackText,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        h2: TextStyle(
                          color: NomAIColors.blackText,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        h3: TextStyle(
                          color: NomAIColors.blackText,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        listBullet: TextStyle(
                          color: NomAIColors.blackText,
                          fontSize: 14.sp,
                        ),
                        strong: TextStyle(
                          color: NomAIColors.blackText,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                        em: TextStyle(
                          color: NomAIColors.blackText,
                          fontStyle: FontStyle.italic,
                          fontSize: 14.sp,
                        ),
                        code: TextStyle(
                          color: NomAIColors.blueGrey,
                          backgroundColor:
                              NomAIColors.grey.withValues(alpha: 0.1),
                          fontSize: 12.sp,
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: NomAIColors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(1.h),
                        ),
                        codeblockPadding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 1.h,
                        ),
                      ),
                    ),
            ),
            SizedBox(height: 0.6.h),
            GestureDetector(
              onTap: () => _copyToClipboard(context),
              child: Container(
                padding: EdgeInsets.all(0.8.h),
                decoration: BoxDecoration(
                  color: NomAIColors.greyLight,
                  borderRadius: BorderRadius.circular(1.5.h),
                ),
                child: Icon(
                  Icons.copy_outlined,
                  size: 16.sp,
                  color: NomAIColors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
