import 'package:NomAi/app/components/dialogs.dart';
import 'package:NomAi/app/components/social_media_share_widget.dart';
import 'package:NomAi/app/constants/enums.dart';
import 'package:NomAi/app/models/AI/nutrition_input.dart';
import 'package:NomAi/app/models/Auth/user.dart';
import 'package:NomAi/app/modules/Scanner/controller/scanner_controller.dart';
import 'package:NomAi/app/repo/nutrition_record_repo.dart';
import 'package:NomAi/app/repo/storage_service.dart';
import 'package:NomAi/app/utility/registry_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:sizer/sizer.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/models/AI/nutrition_output.dart';
import 'package:NomAi/app/models/AI/nutrition_record.dart';

import 'package:NomAi/app/utility/date_utility.dart';

class NutritionView extends StatefulWidget {
  final NutritionRecord nutritionRecord;
  final UserModel userModel;

  const NutritionView({
    super.key,
    required this.nutritionRecord,
    required this.userModel,
  });

  @override
  State<NutritionView> createState() => _NutritionViewState();
}

class _NutritionViewState extends State<NutritionView> {
  late final TextEditingController _foodNameController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatController;

  final FocusNode _foodNameFocusNode = FocusNode();
  final FocusNode _caloriesFocusNode = FocusNode();
  final FocusNode _proteinFocusNode = FocusNode();
  final FocusNode _carbsFocusNode = FocusNode();
  final FocusNode _fatFocusNode = FocusNode();

  late final ValueNotifier<String?> _imagePathNotifier;

  bool _isEditing = false;
  String? _selectedImagePath;

  NutritionRecord get nutritionRecord => widget.nutritionRecord;
  UserModel get userModel => widget.userModel;

  @override
  void initState() {
    super.initState();
    final totals = _calculateCurrentTotals();

    _foodNameController = TextEditingController(
      text: nutritionRecord.nutritionOutput?.response?.foodName ?? '',
    );
    _caloriesController = TextEditingController(
      text: totals['calories']!.toString(),
    );
    _proteinController = TextEditingController(
      text: totals['protein']!.toString(),
    );
    _carbsController = TextEditingController(
      text: totals['carbs']!.toString(),
    );
    _fatController = TextEditingController(
      text: totals['fat']!.toString(),
    );

    final query = nutritionRecord.nutritionInputQuery;
    final initialImage = query?.imageFilePath?.isNotEmpty == true
        ? query!.imageFilePath
        : query?.imageUrl?.toString();

    _imagePathNotifier = ValueNotifier<String?>(initialImage);
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();

    _foodNameFocusNode.dispose();
    _caloriesFocusNode.dispose();
    _proteinFocusNode.dispose();
    _carbsFocusNode.dispose();
    _fatFocusNode.dispose();

    _imagePathNotifier.dispose();
    super.dispose();
  }

  Map<String, int> _calculateCurrentTotals() {
    int currentCalories = 0;
    int currentProtein = 0;
    int currentCarbs = 0;
    int currentFat = 0;

    final ingredients = nutritionRecord.nutritionOutput?.response?.ingredients;
    if (ingredients != null) {
      for (final ingredient in ingredients) {
        currentCalories += ingredient.calories ?? 0;
        currentProtein += ingredient.protein ?? 0;
        currentCarbs += ingredient.carbs ?? 0;
        currentFat += ingredient.fat ?? 0;
      }
    }

    return {
      'calories': currentCalories,
      'protein': currentProtein,
      'carbs': currentCarbs,
      'fat': currentFat,
    };
  }

  void _resetEditingControllers() {
    final totals = _calculateCurrentTotals();
    _foodNameController.text =
        nutritionRecord.nutritionOutput?.response?.foodName ?? '';
    _caloriesController.text = totals['calories']!.toString();
    _proteinController.text = totals['protein']!.toString();
    _carbsController.text = totals['carbs']!.toString();
    _fatController.text = totals['fat']!.toString();
    _selectedImagePath = null;

    final query = nutritionRecord.nutritionInputQuery;
    final resetImage = query?.imageFilePath?.isNotEmpty == true
        ? query!.imageFilePath
        : query?.imageUrl?.toString();
    _imagePathNotifier.value = resetImage;
  }

  @override
  Widget build(BuildContext context) {
    NutritionResponse response = nutritionRecord.nutritionOutput!.response!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),
                  _buildFoodHeaderCard(context, response),
                  SizedBox(height: 2.h),
                  _buildNutritionSummaryCard(context, response),
                  if (response.overallHealthComments != null &&
                      response.overallHealthComments!.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    _buildHealthInsightsCard(context, response),
                  ],
                  if (response.ingredients != null &&
                      response.ingredients!.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    _buildIngredientsCard(context, response),
                  ],
                  if (response.primaryConcerns != null &&
                      response.primaryConcerns!.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    _buildPrimaryConcernsCard(context, response),
                  ],
                  if (response.suggestAlternatives != null &&
                      response.suggestAlternatives!.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    _buildAlternativesCard(context, response),
                  ],
                  SizedBox(height: 3.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadImage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Image Source',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: NomAIColors.black,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    context,
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                  _buildImageSourceOption(
                    context,
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image == null) return;

    AppDialogs.showLoadingDialog(
      title: "Uploading Image",
      message: "Please wait...",
    );

    try {
      final storageService = serviceLocator<StorageService>();
      final imageUrl = await storageService.uploadImage(File(image.path));

      if (imageUrl == null) {
        AppDialogs.hideDialog();
        if (context.mounted) {
          AppDialogs.showErrorSnackbar(
            title: "Error",
            message: "Failed to upload image. Please try again.",
          );
        }
        return;
      }

      final recordTime = nutritionRecord.recordTime ?? DateTime.now();

      final updatedQuery = NutritionInputQuery(
        imageUrl: imageUrl,
        imageFilePath: image.path,
        scanMode: nutritionRecord.nutritionInputQuery?.scanMode,
        food_description: nutritionRecord.nutritionInputQuery?.food_description,
        dietaryPreferences:
            nutritionRecord.nutritionInputQuery?.dietaryPreferences,
        allergies: nutritionRecord.nutritionInputQuery?.allergies,
        selectedGoals: nutritionRecord.nutritionInputQuery?.selectedGoals,
      );

      final updatedRecord = NutritionRecord(
        nutritionOutput: nutritionRecord.nutritionOutput,
        recordTime: nutritionRecord.recordTime,
        nutritionInputQuery: updatedQuery,
        processingStatus: nutritionRecord.processingStatus,
      );

      final nutritionRecordRepo = NutritionRecordRepo();
      final result = await nutritionRecordRepo.updateMealEntry(
          userModel.userId, updatedRecord, recordTime, recordTime);

      AppDialogs.hideDialog();

      if (result == QueryStatus.SUCCESS) {
        final scannerController = Get.put(ScannerController());
        await scannerController.getRecordByDate(userModel.userId, recordTime);
        if (context.mounted) {
          AppDialogs.showSuccessSnackbar(
            title: "Success",
            message: "Image uploaded successfully!",
          );
          Navigator.pop(context);
        }
      } else {
        if (context.mounted) {
          AppDialogs.showErrorSnackbar(
            title: "Error",
            message: "Failed to save image. Please try again.",
          );
        }
      }
    } catch (e) {
      AppDialogs.hideDialog();
      if (context.mounted) {
        AppDialogs.showErrorSnackbar(
          title: "Error",
          message: "Failed to upload image: $e",
        );
      }
    }
  }

  Widget _buildImageSourceOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: NomAIColors.black.withOpacity(0.1),
            ),
            child: Icon(icon, size: 32, color: NomAIColors.black),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: NomAIColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteMeal(BuildContext context) async {
    // Show confirmation dialog
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Meal Entry'),
          content: const Text(
            'Are you sure you want to delete this meal entry? This action cannot be undone.',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Handle delete logic here if needed
                // For now, just close the dialog since the logic is commented out
                // Navigator.of(context).pop();

                AppDialogs.showLoadingDialog(
                  title: "Deleting Meal",
                  message: "Removing meal from records...",
                );

                String userId = userModel.userId;
                final nutritionRecordRepo = NutritionRecordRepo();
                final recordTime = nutritionRecord.recordTime ?? DateTime.now();

                QueryStatus result =
                    await nutritionRecordRepo.deleteMealEntryByTime(
                  userId,
                  recordTime,
                  recordTime,
                );

                if (result == QueryStatus.SUCCESS) {
                  AppDialogs.hideDialog();

                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pop(); // Go back to previous screen

                  AppDialogs.showSuccessSnackbar(
                    title: "Success",
                    message: "Meal deleted successfully!",
                  );
                  ScannerController scannerController =
                      Get.put(ScannerController());

                  await scannerController.getRecordByDate(userId, recordTime);
                } else {
                  // Show error snackbar if deletion failed
                  AppDialogs.showErrorSnackbar(
                    title: "Error",
                    message: "Failed to add to meals. Please try again.",
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    // if (confirm != true) return;

    // try {
    //   // Show loading dialog with shorter message to prevent overflow
    //   AppDialogs.showLoadingDialog(
    //     title: "Deleting Meal",
    //     message: "Removing meal from records...",
    //   );

    //   // Get user ID from BLoC
    //   String? userId;
    // final userBloc = context.read<UserBloc>();
    // final userState = userBloc.state;
    // if (userState is UserLoaded) {
    //   userId = userState.userModel.userId;
    // }

    //   if (userId == null) {
    //     AppDialogs.hideDialog();
    //     AppDialogs.showErrorSnackbar(
    //       title: "Error",
    //       message: "Unable to identify user.",
    //     );
    //     return;
    //   }

    // final nutritionRecordRepo = NutritionRecordRepo();
    // final recordTime = nutritionRecord.recordTime ?? DateTime.now();

    //   // First try to delete by time
    // QueryStatus result = await nutritionRecordRepo.deleteMealEntryByTime(
    //   userId,
    //   recordTime,
    //   recordTime,
    // );

    //   // If deletion by time fails, try to find by matching nutrition data and delete by index
    //   if (result != QueryStatus.SUCCESS) {
    //     // Get current daily records
    //     final dailyRecords =
    //         await nutritionRecordRepo.getNutritionData(userId, recordTime);

    //     // Find the meal index by comparing nutrition data
    //     int mealIndex = -1;
    //     for (int i = 0; i < dailyRecords.dailyRecords.length; i++) {
    //       final record = dailyRecords.dailyRecords[i];
    //       if (_areRecordsEqual(record, nutritionRecord)) {
    //         mealIndex = i;
    //         break;
    //       }
    //     }

    //     if (mealIndex != -1) {
    //       result = await nutritionRecordRepo.deleteMealEntry(
    //           userId, recordTime, mealIndex);
    //     }
    //   }

    //   // Hide loading dialog
    //   AppDialogs.hideDialog();

    //   if (result == QueryStatus.SUCCESS) {
    //     // Update the scanner controller to refresh the data
    //     final scannerController = Get.find<ScannerController>();
    //     await scannerController.getRecordByDate(userId, recordTime);

    //     // Show success message
    //     AppDialogs.showSuccessSnackbar(
    //       title: "Success",
    //       message: "Meal deleted successfully!",
    //     );

    //     // Go back to previous screen
    //     Navigator.of(context).pop();
    //   } else {
    //     AppDialogs.showErrorSnackbar(
    //       title: "Error",
    //       message: "Failed to delete meal entry.",
    //     );
    //   }
    // } catch (e) {
    //   // Hide loading dialog if it's still showing
    //   AppDialogs.hideDialog();

    //   AppDialogs.showErrorSnackbar(
    //     title: "Error",
    //     message: "An unexpected error occurred.",
    //   );
    // }
  }

  Future<void> _performMealUpdate(
    BuildContext context,
    TextEditingController foodNameController,
    TextEditingController caloriesController,
    TextEditingController proteinController,
    TextEditingController carbsController,
    TextEditingController fatController,
    String? selectedImagePath,
  ) async {
    // Validate required fields
    if (foodNameController.text.trim().isEmpty) {
      AppDialogs.showErrorSnackbar(
        title: "Error",
        message: "Please enter a food name.",
      );
      return;
    }

    // Validate and parse numeric values
    int? calories = int.tryParse(caloriesController.text.trim());
    int? protein = int.tryParse(proteinController.text.trim());
    int? carbs = int.tryParse(carbsController.text.trim());
    int? fat = int.tryParse(fatController.text.trim());

    if (calories == null || calories < 0) {
      AppDialogs.showErrorSnackbar(
        title: "Invalid Input",
        message: "Please enter a valid number for calories (0 or greater).",
      );
      return;
    }

    if (protein == null || protein < 0) {
      AppDialogs.showErrorSnackbar(
        title: "Invalid Input",
        message: "Please enter a valid number for protein (0 or greater).",
      );
      return;
    }

    if (carbs == null || carbs < 0) {
      AppDialogs.showErrorSnackbar(
        title: "Invalid Input",
        message: "Please enter a valid number for carbs (0 or greater).",
      );
      return;
    }

    if (fat == null || fat < 0) {
      AppDialogs.showErrorSnackbar(
        title: "Invalid Input",
        message: "Please enter a valid number for fat (0 or greater).",
      );
      return;
    }

    AppDialogs.showLoadingDialog(
      title: "Updating Meal",
      message: "Saving your changes...",
    );

    try {
      String userId = userModel.userId;
      final nutritionRecordRepo = NutritionRecordRepo();
      final recordTime = nutritionRecord.recordTime ?? DateTime.now();

      // Build a new NutritionRecord with updated values (immutable-style)
      final old = nutritionRecord;
      final oldOutput = old.nutritionOutput;
      final oldResp = oldOutput?.response;

      // Copy ingredients and update the first (main) one
      List<Ingredient> newIngredients;
      if (oldResp?.ingredients != null && oldResp!.ingredients!.isNotEmpty) {
        newIngredients = oldResp.ingredients!
            .map((i) => Ingredient.fromJson(i.toJson()))
            .toList();
        final first = newIngredients.first;
        first.name = foodNameController.text.trim();
        first.calories = calories;
        first.protein = protein;
        first.carbs = carbs;
        first.fat = fat;
        first.healthScore = first.healthScore ?? 5;
        first.healthComments =
            first.healthComments ?? 'Manually entered nutrition values';
      } else {
        newIngredients = [
          Ingredient(
            name: foodNameController.text.trim(),
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            healthScore: 5,
            healthComments: 'Manually entered nutrition values',
          )
        ];
      }

      final newResponse = NutritionResponse(
        message: oldResp?.message,
        foodName: foodNameController.text.trim(),
        portion: oldResp?.portion,
        portionSize: oldResp?.portionSize,
        confidenceScore: oldResp?.confidenceScore,
        ingredients: newIngredients,
        primaryConcerns: oldResp?.primaryConcerns,
        suggestAlternatives: oldResp?.suggestAlternatives,
        overallHealthScore: oldResp?.overallHealthScore,
        overallHealthComments: oldResp?.overallHealthComments,
      );

      final newOutput = NutritionOutput(
        response: newResponse,
        status: oldOutput?.status,
        message: oldOutput?.message,
        metadata: oldOutput?.metadata,
        inputTokenCount: oldOutput?.inputTokenCount,
        outputTokenCount: oldOutput?.outputTokenCount,
        totalTokenCount: oldOutput?.totalTokenCount,
        estimatedCost: oldOutput?.estimatedCost,
        executionTimeSeconds: oldOutput?.executionTimeSeconds,
      );

      final oldQuery = old.nutritionInputQuery;
      final newQuery = oldQuery == null
          ? null
          : NutritionInputQuery(
              imageUrl: oldQuery.imageUrl,
              scanMode: oldQuery.scanMode,
              food_description: foodNameController.text.trim(),
              imageFilePath: selectedImagePath ?? oldQuery.imageFilePath,
              dietaryPreferences: oldQuery.dietaryPreferences,
              allergies: oldQuery.allergies,
              selectedGoals: oldQuery.selectedGoals,
            );

      final updatedRecord = NutritionRecord(
        nutritionOutput: newOutput,
        recordTime: old.recordTime,
        nutritionInputQuery: newQuery,
        processingStatus: old.processingStatus,
      );

      QueryStatus result = await nutritionRecordRepo.updateMealEntry(
        userId,
        updatedRecord,
        recordTime,
        recordTime,
      );

      AppDialogs.hideDialog();

      if (result == QueryStatus.SUCCESS) {
        AppDialogs.showSuccessSnackbar(
          title: "Success",
          message: "Meal updated successfully with your custom values!",
        );

        // Refresh the data in scanner controller
        ScannerController scannerController = Get.put(ScannerController());
        await scannerController.getRecordByDate(userId, recordTime);

        // Go back to refresh the view
        Navigator.of(context).pop();
      } else {
        AppDialogs.showErrorSnackbar(
          title: "Error",
          message: "Failed to update meal. Please try again.",
        );
      }
    } catch (e) {
      AppDialogs.hideDialog();
      AppDialogs.showErrorSnackbar(
        title: "Error",
        message: "An unexpected error occurred: $e",
      );
    }
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 35.h,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      leading: Bounceable(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: NomAIColors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back_ios_new,
              color: NomAIColors.black, size: 20),
        ),
      ),
      actions: [
        Bounceable(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SocialMediaShareWidget(
                  nutritionRecord: nutritionRecord,
                  userName: userModel.name,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: NomAIColors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child:
                const Icon(Icons.ios_share, color: NomAIColors.black, size: 20),
          ),
        ),
        Bounceable(
          onTap: () async {
            if (_isEditing) {
              await _performMealUpdate(
                context,
                _foodNameController,
                _caloriesController,
                _proteinController,
                _carbsController,
                _fatController,
                _selectedImagePath,
              );
            } else {
              setState(() {
                _resetEditingControllers();
                _isEditing = true;
              });
            }
          },
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: NomAIColors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              _isEditing ? Icons.check : Icons.edit_outlined,
              color: NomAIColors.black,
              size: 20,
            ),
          ),
        ),
        if (_isEditing)
          Bounceable(
            onTap: () {
              setState(() {
                _resetEditingControllers();
                _isEditing = false;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: NomAIColors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.close,
                color: NomAIColors.red,
                size: 20,
              ),
            ),
          ),
        Bounceable(
          onTap: () => _handleDeleteMeal(context),
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: NomAIColors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.delete_outline,
                color: NomAIColors.red, size: 20),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                NomAIColors.black.withOpacity(0.3),
                Colors.transparent,
                NomAIColors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: nutritionRecord.nutritionInputQuery?.imageUrl != null &&
                  nutritionRecord.nutritionInputQuery!.imageUrl!.isNotEmpty
              ? Image.network(
                  nutritionRecord.nutritionInputQuery!.imageUrl.toString(),
                  fit: BoxFit.cover,
                  webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: NomAIColors.greyLight,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant,
                            size: 48,
                            color: NomAIColors.black.withOpacity(0.3),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No Image Available',
                            style: TextStyle(
                              color: NomAIColors.black.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : _isEditing
                  ? Container(
                      color: NomAIColors.greyLight,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => _uploadImage(context),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: NomAIColors.black.withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.add_a_photo,
                                  size: 48,
                                  color: NomAIColors.black.withOpacity(0.5),
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Tap to add image',
                              style: TextStyle(
                                color: NomAIColors.black.withOpacity(0.5),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      color: NomAIColors.greyLight,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.restaurant,
                                size: 48,
                                color: NomAIColors.black.withOpacity(0.3)),
                            SizedBox(height: 8),
                            Text('No Image Available',
                                style: TextStyle(
                                    color: NomAIColors.black.withOpacity(0.3))),
                          ],
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildFoodHeaderCard(
      BuildContext context, NutritionResponse response) {
    return Column(
      children: [
        TextFormField(
          controller: _foodNameController,
          focusNode: _foodNameFocusNode,
          textAlign: TextAlign.center,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: NomAIColors.black,
          ),
          cursorColor: NomAIColors.black,
          decoration: _isEditing
              ? const InputDecoration(
                  hintText: 'Enter Food Name',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: NomAIColors.black),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: NomAIColors.black, width: 2),
                  ),
                )
              : const InputDecoration(
                  hintText: 'Enter Food Name',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
          readOnly: !_isEditing,
          onTapOutside: (_) => _foodNameFocusNode.unfocus(),
        ),
        if (response.overallHealthScore != null) ...[
          SizedBox(height: 2.h),
          HealthScoreWidget(nutritionRecord: nutritionRecord),
        ],
      ],
    );
  }

  Widget _buildNutritionSummaryCard(
      BuildContext context, NutritionResponse response) {
    int totalCalories = 0;
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFat = 0;

    if (response.ingredients != null) {
      for (var ingredient in response.ingredients!) {
        totalCalories += ingredient.calories ?? 0;
        totalProtein += ingredient.protein ?? 0;
        totalCarbs += ingredient.carbs ?? 0;
        totalFat += ingredient.fat ?? 0;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.analytics_outlined, color: NomAIColors.black, size: 20),
            SizedBox(width: 2.w),
            Text(
              'Nutrition Facts',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: NomAIColors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: NomAIColors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Calories',
                style: context.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              _isEditing
                  ? SizedBox(
                      width: 120,
                      child: TextField(
                        controller: _caloriesController,
                        focusNode: _caloriesFocusNode,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        style: context.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        cursorColor: Colors.white,
                        decoration: const InputDecoration(
                          isDense: true,
                          hintText: 'kcal',
                          hintStyle: TextStyle(color: Colors.white54),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 2),
                          ),
                        ),
                        onTapOutside: (_) => _caloriesFocusNode.unfocus(),
                      ),
                    )
                  : Text(
                      '$totalCalories kcal',
                      style: context.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildEnhancedNutrientBox(
                context,
                'Carbs',
                '$totalCarbs',
                'g',
                NomAIColors.carbsColor,
                Icons.grain,
                controller: _carbsController,
                focusNode: _carbsFocusNode,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildEnhancedNutrientBox(
                context,
                'Protein',
                '$totalProtein',
                'g',
                NomAIColors.proteinColor,
                Icons.fitness_center,
                controller: _proteinController,
                focusNode: _proteinFocusNode,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildEnhancedNutrientBox(
                context,
                'Fat',
                '$totalFat',
                'g',
                NomAIColors.fatColor,
                Icons.water_drop,
                controller: _fatController,
                focusNode: _fatFocusNode,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnhancedNutrientBox(
    BuildContext context,
    String label,
    String value,
    String unit,
    Color color,
    IconData icon, {
    TextEditingController? controller,
    FocusNode? focusNode,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: NomAIColors.greyLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: NomAIColors.black,
            ),
          ),
          const SizedBox(height: 4),
          _isEditing && controller != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    SizedBox(
                      width: 60,
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                        cursorColor: color,
                        decoration: const InputDecoration(
                          isDense: true,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: NomAIColors.black),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: NomAIColors.black, width: 2),
                          ),
                        ),
                        onTapOutside: (_) => focusNode?.unfocus(),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      unit,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: NomAIColors.black.withOpacity(0.6),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      unit,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: NomAIColors.black.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildHealthInsightsCard(
      BuildContext context, NutritionResponse response) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.psychology_outlined, color: NomAIColors.black, size: 20),
            SizedBox(width: 2.w),
            Text(
              'Health Insights',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: NomAIColors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: NomAIColors.greyLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            response.overallHealthComments ?? '',
            style: context.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: NomAIColors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientsCard(
      BuildContext context, NutritionResponse response) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.restaurant_menu, color: NomAIColors.black, size: 20),
            SizedBox(width: 2.w),
            Text(
              'Ingredients',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: NomAIColors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: response.ingredients?.length ?? 0,
          itemBuilder: (context, index) {
            final ingredient = response.ingredients![index];
            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Container(
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
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: NomAIColors.black,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            ingredient.name ?? 'Unknown',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: NomAIColors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (ingredient.healthComments != null &&
                        ingredient.healthComments!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          ingredient.healthComments!,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: NomAIColors.black.withOpacity(0.6),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPrimaryConcernsCard(
      BuildContext context, NutritionResponse response) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.warning_amber_outlined,
                color: NomAIColors.red, size: 20),
            SizedBox(width: 2.w),
            Text(
              'Primary Concerns',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: NomAIColors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: response.primaryConcerns?.length ?? 0,
          itemBuilder: (context, index) {
            final concern = response.primaryConcerns![index];
            return Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NomAIColors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NomAIColors.red.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: NomAIColors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            concern.issue ?? 'Unknown Concern',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: NomAIColors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      concern.explanation ?? 'No explanation available',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: NomAIColors.black,
                        height: 1.4,
                      ),
                    ),
                    if (concern.recommendations != null &&
                        concern.recommendations!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Recommendations:',
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: NomAIColors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: concern.recommendations?.length ?? 0,
                        itemBuilder: (context, recIndex) {
                          final suggestion = concern.recommendations![recIndex];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: NomAIColors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${suggestion.food} - ${suggestion.reasoning} (${suggestion.quantity})',
                                    style:
                                        context.textTheme.bodySmall?.copyWith(
                                      color: NomAIColors.black,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAlternativesCard(
      BuildContext context, NutritionResponse response) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb_outline, color: NomAIColors.black, size: 20),
            SizedBox(width: 2.w),
            Text(
              'Healthier Alternatives',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: NomAIColors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: response.suggestAlternatives?.length ?? 0,
          itemBuilder: (context, index) {
            final alternative = response.suggestAlternatives![index];
            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Container(
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
                        Icon(Icons.trending_up,
                            color: NomAIColors.black, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            alternative.name ?? 'Unknown',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: NomAIColors.black,
                            ),
                          ),
                        ),
                        if (alternative.healthScore != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: NomAIColors.black,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${alternative.healthScore}/10',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (alternative.healthComments != null &&
                        alternative.healthComments!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        alternative.healthComments!,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: NomAIColors.black.withOpacity(0.7),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class HealthScoreWidget extends StatelessWidget {
  final NutritionRecord nutritionRecord;

  const HealthScoreWidget({
    super.key,
    required this.nutritionRecord,
  });

  @override
  Widget build(BuildContext context) {
    double scorePercent = (nutritionRecord
            .nutritionOutput!.response!.overallHealthScore!
            .clamp(0, 10)) /
        10;

    int healthScore = nutritionRecord
        .nutritionOutput!.response!.overallHealthScore!
        .clamp(0, 10)
        .toInt();

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: NomAIColors.greyLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Meal Time",
                  style: context.textTheme.bodySmall?.copyWith(
                    color: NomAIColors.black.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateUtility.getTimeFromDateTime(
                    nutritionRecord.recordTime?.toLocal() ?? DateTime.now(),
                  ),
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: NomAIColors.black,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              CircularPercentIndicator(
                radius: 8.w,
                lineWidth: 6.0,
                animation: true,
                animationDuration: 1200,
                percent: scorePercent,
                backgroundColor: NomAIColors.black.withOpacity(0.1),
                progressColor: _getProgressColor(scorePercent),
                circularStrokeCap: CircularStrokeCap.round,
                center: Text(
                  '$healthScore',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getProgressColor(scorePercent),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getHealthRating(healthScore),
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getProgressColor(scorePercent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double percent) {
    if (percent >= 0.6) return NomAIColors.black;
    return NomAIColors.red;
  }

  String _getHealthRating(int score) {
    if (score >= 8) return 'Excellent';
    if (score >= 6) return 'Good';
    if (score >= 4) return 'Fair';
    return 'Poor';
  }
}
