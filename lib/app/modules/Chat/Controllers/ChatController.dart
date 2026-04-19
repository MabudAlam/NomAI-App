import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:NomAi/app/components/dialogs.dart';
import 'package:NomAi/app/constants/enums.dart';
import 'package:NomAi/app/constants/urls.dart';
import 'package:NomAi/app/models/AI/nutrition_input.dart';
import 'package:NomAi/app/models/AI/nutrition_output.dart' as nutrition_out;
import 'package:NomAi/app/models/AI/nutrition_record.dart';
import 'package:NomAi/app/models/Auth/user.dart';
import 'package:NomAi/app/models/Chat/ChatGetModelResponse.dart';
import 'package:NomAi/app/models/Chat/LogStatusResponse.dart';
import 'package:NomAi/app/models/Chat/ChatPostModel.dart';
import 'package:NomAi/app/modules/Scanner/controller/scanner_controller.dart';
import 'package:NomAi/app/modules/Scanner/views/scan_view.dart';
import 'package:NomAi/app/repo/nutrition_record_repo.dart';
import 'package:NomAi/app/repo/storage_service.dart';
import 'package:NomAi/app/utility/image_utility.dart';
import 'package:NomAi/app/utility/registry_service.dart';

class ChatController extends GetxController {
  final textController = Get.put(TextEditingController());
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isFetchingHistory = true.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString uploadedImageUrl = ''.obs;
  final RxBool isUploading = false.obs;
  final RxSet<String> updatingLogStatusForMessages = <String>{}.obs;

  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();

  UserModel? _userModel;

  String? get _userId => _userModel?.userId;
  List<String> get _dietaryPreferences => _getDietaryPreferences();
  List<String> get _allergies => _userModel?.userInfo?.selectedAllergies ?? [];
  List<String> get _selectedGoals => _getSelectedGoals();

  List<String> _getDietaryPreferences() {
    final diet = _userModel?.userInfo?.selectedDiet;
    if (diet == null || diet.isEmpty) return [];
    return [diet.toLowerCase()];
  }

  List<String> _getSelectedGoals() {
    final goal = _userModel?.userInfo?.selectedGoal;
    switch (goal) {
      case HealthMode.weightLoss:
        return ['weight-loss'];
      case HealthMode.muscleGain:
        return ['muscle-gain'];
      case HealthMode.maintainWeight:
        return ['maintain-weight'];
      case HealthMode.none:
      default:
        return [];
    }
  }

  void setUserModel(UserModel userModel) {
    _userModel = userModel;
  }

  Future<void> fetchChatHistory() async {
    if (_userId == null) {
      isFetchingHistory.value = false;
      return;
    }

    isFetchingHistory.value = true;
    try {
      final history = await _fetchMessagesFromApi();
      messages.addAll(history);
    } catch (e) {
      print('Error fetching chat history: $e');
    } finally {
      isFetchingHistory.value = false;
    }
  }

  Future<List<ChatMessage>> _fetchMessagesFromApi() async {
    final url = Uri.parse(
      '${ApiUrl.baseUrl}${ApiPath.getMessages(_userId!, 0, 50)}',
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': '*/*',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final chatResponse = ChatGetModelResponse.fromJson(json);

      return chatResponse.messages?.map((msg) {
            return ChatMessage(
              messageId: msg.messageId ?? '',
              text: msg.text ?? '',
              imageUrl: msg.imageUrl,
              isUser: msg.isUser,
              timestamp: msg.timestamp ?? DateTime.now(),
              nutritionData: msg.sources?.nutritionData,
              isAddedToLogs: msg.isAddedToLogs ?? false,
            );
          }).toList() ??
          [];
    } else {
      throw Exception('Failed to fetch messages: ${response.statusCode}');
    }
  }

  Future<void> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _processSelectedImage(image);
    }
  }

  Future<void> pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      await _processSelectedImage(image);
    }
  }

  Future<void> _processSelectedImage(XFile image) async {
    isUploading.value = true;

    File resizedFile = File(image.path);
    try {
      resizedFile = await ImageUtility.downscaleImage(
        image.path,
        scale: ImageScale.large_2048,
      );
    } catch (e) {
      print("Error downscaling image: $e");
      resizedFile = File(image.path);
    }

    selectedImage.value =
        resizedFile.existsSync() ? resizedFile : File(image.path);

    final imageUrl = await _storageService.uploadImage(selectedImage.value!);
    uploadedImageUrl.value = imageUrl ?? '';
    isUploading.value = false;
  }

  void clearSelectedImage() {
    selectedImage.value = null;
    uploadedImageUrl.value = '';
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty && uploadedImageUrl.value.isEmpty) return;

    final imageUrl =
        uploadedImageUrl.value.isNotEmpty ? uploadedImageUrl.value : null;

    final textToSend =
        text.isEmpty && imageUrl != null ? 'Analyse this image' : text;

    final localMessageId = 'local_${DateTime.now().millisecondsSinceEpoch}';

    messages.add(ChatMessage(
      messageId: localMessageId,
      localMessageId: localMessageId,
      text: textToSend,
      imageUrl: imageUrl,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    final userImageUrl = imageUrl;
    textController.clear();
    clearSelectedImage();

    isLoading.value = true;

    try {
      final response = await _sendToApi(
        text: textToSend,
        imageUrl: userImageUrl,
        localMessageId: localMessageId,
      );

      if (response.userMessageId != null) {
        final index = messages.indexWhere(
          (m) => m.localMessageId == localMessageId && m.isUser,
        );
        if (index != -1) {
          messages[index] = ChatMessage(
            messageId: response.userMessageId!,
            localMessageId: localMessageId,
            text: messages[index].text,
            imageUrl: messages[index].imageUrl,
            isUser: messages[index].isUser,
            timestamp: messages[index].timestamp,
            nutritionData: messages[index].nutritionData,
            isAddedToLogs: messages[index].isAddedToLogs,
          );
        }
      }

      messages.add(ChatMessage(
        messageId: response.messageId ??
            'local_${DateTime.now().millisecondsSinceEpoch}',
        text: response.aiAnswer ?? '',
        isUser: false,
        timestamp: DateTime.now(),
        nutritionData: response.nutritionData,
      ));
    } catch (e) {
      messages.add(ChatMessage(
        messageId: 'local_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Sorry, something went wrong. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addToLog(String messageId, ResponseData response) async {
    if (_userId == null) return;

    updatingLogStatusForMessages.add(messageId);

    print('Adding to log for messageId: $messageId ');

    try {
      final updateSuccess = await _updateLogStatusApi(messageId, true);

      if (!updateSuccess) {
        AppDialogs.showErrorSnackbar(
          title: 'Error',
          message: 'Failed to update log status. Please try again.',
        );
        return;
      }

      final nutritionOutput = _convertResponseToNutritionOutput(response);

      final nutritionRecord = NutritionRecord(
        nutritionOutput: nutritionOutput,
        recordTime: DateTime.now(),
        nutritionInputQuery: NutritionInputQuery(
          imageUrl: response.imageUrl ?? '',
          scanMode: ScanMode.food,
          dietaryPreferences: _dietaryPreferences,
          allergies: _allergies,
          selectedGoals: _selectedGoals,
        ),
        processingStatus: ProcessingStatus.COMPLETED,
      );

      final scannerController = Get.find<ScannerController>();
      scannerController.addRecord(nutritionRecord);

      final nutritionRecordRepo = serviceLocator<NutritionRecordRepo>();
      final existingRecords = await nutritionRecordRepo.getNutritionData(
        _userId!,
        DateTime.now(),
      );

      int totalConsumedCalories = existingRecords.dailyConsumedCalories;
      int totalConsumedProtein = existingRecords.dailyConsumedProtein;
      int totalConsumedFat = existingRecords.dailyConsumedFat;
      int totalConsumedCarb = existingRecords.dailyConsumedCarb;

      if (response.ingredients != null) {
        for (final ing in response.ingredients!) {
          totalConsumedCalories += ing.calories ?? 0;
          totalConsumedProtein += ing.protein ?? 0;
          totalConsumedFat += ing.fat ?? 0;
          totalConsumedCarb += ing.carbs ?? 0;
        }
      }

      final dailyRecords =
          List<NutritionRecord>.from(existingRecords.dailyRecords)
            ..add(nutritionRecord);

      final dailyNutritionRecords = DailyNutritionRecords(
        dailyRecords: dailyRecords,
        recordDate: DateTime.now(),
        recordId: existingRecords.recordId,
        dailyConsumedCalories: totalConsumedCalories,
        dailyBurnedCalories: existingRecords.dailyBurnedCalories,
        dailyConsumedProtein: totalConsumedProtein,
        dailyConsumedFat: totalConsumedFat,
        dailyConsumedCarb: totalConsumedCarb,
      );

      await nutritionRecordRepo.saveNutritionData(
        dailyNutritionRecords,
        _userId!,
      );

      scannerController.updateNutritionValues(
        conCalories: totalConsumedCalories,
        conProtein: totalConsumedProtein,
        conFat: totalConsumedFat,
        conCarb: totalConsumedCarb,
      );

      final index = messages.indexWhere((m) => m.messageId == messageId);
      if (index != -1) {
        messages[index] = ChatMessage(
          messageId: messages[index].messageId,
          text: messages[index].text,
          imageUrl: messages[index].imageUrl,
          isUser: messages[index].isUser,
          timestamp: messages[index].timestamp,
          nutritionData: messages[index].nutritionData,
          isAddedToLogs: true,
        );
      }

      AppDialogs.showSuccessSnackbar(
        title: 'Added to Logs',
        message: 'Meal has been added to your daily log.',
      );
    } catch (e) {
      print('Error adding to log: $e');
      AppDialogs.showErrorSnackbar(
        title: 'Error',
        message: 'Something went wrong. Please try again.',
      );
    } finally {
      updatingLogStatusForMessages.remove(messageId);
    }
  }

  Future<bool> _updateLogStatusApi(String messageId, bool isAddedToLogs) async {
    try {
      final url = Uri.parse('${ApiUrl.baseUrl}${ApiPath.updateLogStatus}');

      print(
          'Updating log status for messageId: $messageId with isAddedToLogs: $isAddedToLogs');

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
        body: jsonEncode({
          'user_id': _userId,
          'message_id': messageId,
          'is_added_to_logs': isAddedToLogs,
        }),
      );

      print(
          'Log status update response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        print('Log status updated successfully for messageId: $messageId');
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final logStatusResponse = LogStatusResponse.fromJson(json);
        return logStatusResponse.success ?? false;
      } else {
        print(
            'Failed to update log status for messageId: $messageId. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error updating log status: $e');
      return false;
    }
  }

  nutrition_out.NutritionOutput _convertResponseToNutritionOutput(
      ResponseData response) {
    final nutritionResponse = nutrition_out.NutritionResponse(
      message: response.message,
      foodName: response.foodName,
      portion: response.portion,
      portionSize: response.portionSize,
      confidenceScore: response.confidenceScore,
      ingredients: response.ingredients
          ?.map((i) => nutrition_out.Ingredient(
                name: i.name,
                calories: i.calories,
                protein: i.protein,
                carbs: i.carbs,
                fiber: i.fiber,
                fat: i.fat,
                healthScore: i.healthScore,
                healthComments: i.healthComments,
              ))
          .toList(),
      primaryConcerns: response.primaryConcerns
          ?.map((c) => nutrition_out.PrimaryConcern(
                issue: c.issue,
                explanation: c.explanation,
                recommendations: c.recommendations
                    ?.map((r) => nutrition_out.Recommendation(
                          food: r.food,
                          quantity: r.quantity,
                          reasoning: r.reasoning,
                        ))
                    .toList(),
              ))
          .toList(),
      overallHealthScore: response.overallHealthScore,
      overallHealthComments: response.overallHealthComments,
    );

    return nutrition_out.NutritionOutput(
      response: nutritionResponse,
      status: 200,
      message: 'Success',
    );
  }

  Future<ChatOutputModel> _sendToApi({
    required String text,
    String? imageUrl,
    String? localMessageId,
  }) async {
    final url = Uri.parse('${ApiUrl.baseUrl}${ApiPath.sendMessage}');

    final body = {
      'text': text,
      'user_id': _userId,
      'local_message_id': localMessageId,
      'image_url': imageUrl,
      'image_data': null,
      'local_time': DateTime.now().toUtc().toIso8601String(),
      'dietary_preferences': _dietaryPreferences,
      'allergies': _allergies,
      'selected_goals': _selectedGoals,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': '*/*',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ChatOutputModel.fromJson(json);
    } else {
      throw Exception('Failed to send message: ${response.statusCode}');
    }
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}

class ChatMessage {
  final String messageId;
  final String? localMessageId;
  final String text;
  final String? imageUrl;
  final bool isUser;
  final DateTime timestamp;
  final NutritionData? nutritionData;
  final bool isAddedToLogs;

  ChatMessage({
    required this.messageId,
    this.localMessageId,
    required this.text,
    this.imageUrl,
    required this.isUser,
    required this.timestamp,
    this.nutritionData,
    this.isAddedToLogs = false,
  });
}
