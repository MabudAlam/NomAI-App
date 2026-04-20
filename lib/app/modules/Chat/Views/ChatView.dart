import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_state.dart';
import 'package:NomAi/app/modules/Chat/Controllers/ChatController.dart';
import 'package:NomAi/app/modules/Chat/Views/Components/ChatBubble.dart';
import 'package:NomAi/app/modules/Chat/Views/Components/ChatGradientBackground.dart';
import 'package:NomAi/app/modules/Chat/Views/Components/ChatHeader.dart';
import 'package:NomAi/app/modules/Chat/Views/Components/EmptyChatState.dart';
import 'package:NomAi/app/modules/Chat/Views/Components/MessageInput.dart';
import 'package:NomAi/app/modules/Chat/Views/Components/NutritionAnalysisCard.dart';
import 'package:NomAi/app/modules/Chat/Views/Components/TypingIndicator.dart';

class NomAiChatView extends StatefulWidget {
  const NomAiChatView({super.key});

  @override
  State<NomAiChatView> createState() => _NomAiChatViewState();
}

class _NomAiChatViewState extends State<NomAiChatView> {
  final ScrollController _scrollController = ScrollController();
  late final ChatController controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ChatController());
    ever(controller.messages, (_) => _scrollToBottom());
    ever(controller.isLoading, (loading) {
      if (loading) _scrollToBottom();
    });
  }

  void _initializeWithUser(UserLoaded userState) {
    if (!_isInitialized) {
      controller.setUserModel(userState.userModel);
      controller.fetchChatHistory();
      _isInitialized = true;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NomAIColors.lightBackground,
      body: ChatGradientBackground(
        child: SafeArea(
          child: BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              if (state is UserLoaded && !_isInitialized) {
                _initializeWithUser(state);
              }
              return Column(
                children: [
                  // const ChatHeader(),
                  Expanded(
                    child: Obx(() {
                      if (controller.isFetchingHistory.value) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: NomAIColors.whiteText,
                          ),
                        );
                      }
                      if (controller.messages.isEmpty) {
                        return const EmptyChatState();
                      }
                      return _buildMessagesList();
                    }),
                  ),
                  MessageInput(controller: controller),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      itemCount:
          controller.messages.length + (controller.isLoading.value ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == controller.messages.length) {
          return const TypingIndicator();
        }
        final message = controller.messages[index];
        return Column(
          children: [
            ChatBubble(
              message: message,
            ),
            if (message.nutritionData?.response != null &&
                message.nutritionData!.response!.portionSize != 0 &&
                message.nutritionData!.response!.confidenceScore! >= 0.5)
              Padding(
                padding: EdgeInsets.only(top: 0.5.h),
                child: Obx(() => NutritionAnalysisCard(
                      response: message.nutritionData!.response!,
                      onAddToLog: controller.updatingLogStatusForMessages
                              .contains(message.messageId)
                          ? null
                          : message.isAddedToLogs
                              ? null
                              : () => controller.addToLog(
                                    message.messageId,
                                    message.nutritionData!.response!,
                                  ),
                      isAlreadyAdded: message.isAddedToLogs,
                    )),
              ),
          ],
        );
      },
    );
  }
}
