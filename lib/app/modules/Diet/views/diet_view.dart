import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:NomAi/app/components/shimmer.dart';
import 'package:NomAi/app/constants/colors.dart';
import 'package:NomAi/app/models/Auth/user.dart';
import 'package:NomAi/app/models/Diet/diet_output.dart';
import 'package:NomAi/app/modules/Auth/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_event.dart';
import 'package:NomAi/app/modules/Auth/blocs/my_user_bloc/my_user_state.dart';
import 'package:NomAi/app/modules/Diet/controller/diet_controller.dart';
import 'package:NomAi/app/modules/Diet/views/change_meal_sheet.dart';
import 'package:NomAi/app/modules/Diet/views/diet_history_page.dart';
import 'package:NomAi/app/modules/Diet/widgets/widgets.dart';

class DietView extends StatefulWidget {
  const DietView({super.key});

  @override
  State<DietView> createState() => _DietViewState();
}

class _DietViewState extends State<DietView> {
  late final DietController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(DietController());
    _loadUserData();
  }

  void _loadUserData() {
    final userBloc = context.read<UserBloc>();
    final state = userBloc.state;

    if (state is UserLoaded) {
      _controller.setUserModel(state.userModel);
    } else {
      userBloc.add(
          LoadUserModel(context.read<AuthenticationBloc>().state.user!.uid));
      userBloc.stream.firstWhere((s) => s is UserLoaded).then((state) {
        if (state is UserLoaded) {
          _controller.setUserModel(state.userModel);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.isLoading.value) {
        return Scaffold(
          backgroundColor: NomAIColors.blueGrey,
          appBar: _buildAppBar(),
          body: _buildGradientBody(_buildLoadingShimmer()),
        );
      }

      if (_controller.weeklyDiet.value == null) {
        return Scaffold(
          backgroundColor: NomAIColors.blueGrey,
          appBar: _buildAppBar(),
          body: _buildGradientBody(_buildNoDietView()),
        );
      }

      if (_controller.isDietExpired) {
        return Scaffold(
          backgroundColor: NomAIColors.blueGrey,
          appBar: _buildAppBar(),
          body: _buildGradientBody(_buildExpiredDietView()),
        );
      }

      return Scaffold(
        backgroundColor: NomAIColors.blueGrey,
        appBar: _buildAppBar(),
        body: _buildGradientBody(_buildDietContent()),
      );
    });
  }

  Widget _buildGradientBody(Widget child) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            NomAIColors.blueGrey,
            NomAIColors.blueGrey.withOpacity(0.9),
            NomAIColors.blueGrey.withOpacity(0.8),
            NomAIColors.blueGrey.withOpacity(0.7),
            NomAIColors.blueGrey.withOpacity(0.6),
            NomAIColors.blueGrey.withOpacity(0.5),
            NomAIColors.blueGrey.withOpacity(0.4),
            NomAIColors.blueGrey.withOpacity(0.3),
            NomAIColors.blueGrey.withOpacity(0.2),
            NomAIColors.blueGrey.withOpacity(0.1),
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

  Widget _buildLoadingShimmer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),
          const ShimmerDaySelector(),
          SizedBox(height: 2.h),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const ShimmerMealCard(),
                  SizedBox(height: 12),
                  const ShimmerMealCard(),
                  SizedBox(height: 12),
                  const ShimmerMealCard(),
                  SizedBox(height: 12),
                  const ShimmerMealCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: NomAIColors.blueGrey,
      elevation: 0,
      title: const Text(
        'Weekly Diet Plan',
        style: TextStyle(
          color: NomAIColors.whiteText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      iconTheme: const IconThemeData(color: NomAIColors.whiteText),
      actions: [
        IconButton(
          onPressed: () => Get.to(() => const DietHistoryPage()),
          icon: const Icon(Icons.history),
        ),
      ],
    );
  }

  Widget _buildNoDietView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: NomAIColors.black.withOpacity(0.3),
          ),
          SizedBox(height: 16),
          Text(
            'No diet plan yet',
            style: context.textTheme.titleMedium?.copyWith(
              color: NomAIColors.black.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Create your personalized weekly diet plan',
            style: context.textTheme.bodySmall?.copyWith(
              color: NomAIColors.black.withOpacity(0.4),
            ),
          ),
          SizedBox(height: 24),
          GestureDetector(
            onTap: () => _showCreateDietSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: NomAIColors.black,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Create a Diet Plan',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiredDietView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 64,
            color: NomAIColors.black.withOpacity(0.3),
          ),
          SizedBox(height: 16),
          Text(
            'Your diet plan has ended',
            style: context.textTheme.titleMedium?.copyWith(
              color: NomAIColors.black.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Started on ${_controller.weekStartDate ?? "?"} - Ended on ${_controller.weekEndDate ?? "?"}',
            style: context.textTheme.bodySmall?.copyWith(
              color: NomAIColors.black.withOpacity(0.4),
            ),
          ),
          SizedBox(height: 24),
          GestureDetector(
            onTap: () => _showCreateDietSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: NomAIColors.black,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Start New Week',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietContent() {
    final diet = _controller.weeklyDiet.value!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 2.h,
          ),
          WeekHeader(
            weekStartDate: diet.weekStartDate ?? '',
            weekEndDate: diet.weekEndDate ?? '',
            nutrition: diet.totalWeeklyNutrition,
          ),
          SizedBox(
            height: 2.h,
          ),
          _buildDaySelector(),
          SizedBox(height: 2.h),
          Expanded(child: _buildDayMeals()),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    final days = _controller.weeklyDiet.value?.dailyDiets ?? [];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = _controller.selectedDayIndex.value == index;

          return GestureDetector(
            onTap: () => _controller.selectDay(index),
            child: Container(
              margin: EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? NomAIColors.black : NomAIColors.greyLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                day.dayName ?? '',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isSelected ? Colors.white : NomAIColors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayMeals() {
    final day = _controller.selectedDay;
    if (day == null) return const SizedBox.shrink();

    return ListView(
      children: [
        if (day.totalNutrition != null)
          DayNutritionSummary(nutrition: day.totalNutrition!),
        SizedBox(height: 2.h),
        if (day.meals?.breakfast != null)
          MealCard(
              title: 'Breakfast',
              meal: day.meals!.breakfast!,
              icon: Icons.wb_sunny,
              onAddToLog: () => _controller.markMealAsEaten(
                dayIndex: _controller.selectedDayIndex.value,
                mealType: 'breakfast',
                meal: day.meals!.breakfast!,
              ),
              onChange: () => Get.bottomSheet(
                    ChangeMealSheet(
                        currentMeal: day.meals!.breakfast!,
                        mealType: 'breakfast'),
                    isScrollControlled: true,
                    ignoreSafeArea: false,
                  )),
        if (day.meals?.lunch != null)
          MealCard(
              title: 'Lunch',
              meal: day.meals!.lunch!,
              icon: Icons.wb_cloudy,
              onAddToLog: () => _controller.markMealAsEaten(
                dayIndex: _controller.selectedDayIndex.value,
                mealType: 'lunch',
                meal: day.meals!.lunch!,
              ),
              onChange: () => Get.bottomSheet(
                    ChangeMealSheet(
                        currentMeal: day.meals!.lunch!, mealType: 'lunch'),
                    isScrollControlled: true,
                    ignoreSafeArea: false,
                  )),
        if (day.meals?.dinner != null)
          MealCard(
              title: 'Dinner',
              meal: day.meals!.dinner!,
              icon: Icons.nightlight,
              onAddToLog: () => _controller.markMealAsEaten(
                dayIndex: _controller.selectedDayIndex.value,
                mealType: 'dinner',
                meal: day.meals!.dinner!,
              ),
              onChange: () => Get.bottomSheet(
                    ChangeMealSheet(
                        currentMeal: day.meals!.dinner!, mealType: 'dinner'),
                    isScrollControlled: true,
                    ignoreSafeArea: false,
                  )),
        if (day.meals?.snacks != null && day.meals!.snacks!.isNotEmpty)
          ...day.meals!.snacks!.asMap().entries.map((entry) => MealCard(
                title: 'Snack ${(entry.key + 1).toString()}',
                meal: entry.value,
                icon: Icons.cookie_outlined,
                onAddToLog: () => _controller.markMealAsEaten(
                  dayIndex: _controller.selectedDayIndex.value,
                  mealType: 'snacks',
                  meal: entry.value,
                ),
              )),
        if (day.cheatMealOfTheDay != null)
          MealCard(
              title: 'Cheat Meal',
              meal: day.cheatMealOfTheDay!,
              icon: Icons.local_fire_department,
              onAddToLog: () => _controller.markMealAsEaten(
                dayIndex: _controller.selectedDayIndex.value,
                mealType: 'cheatMeal',
                meal: day.cheatMealOfTheDay!,
              )),
      ],
    );
  }

  void _showCreateDietSheet(BuildContext context) {
    final caloriesController =
        TextEditingController(text: _controller.calories.toString());
    final proteinController =
        TextEditingController(text: _controller.protein.toString());
    final carbsController =
        TextEditingController(text: _controller.carbs.toString());
    final fiberController =
        TextEditingController(text: _controller.fiber.toString());
    final fatController =
        TextEditingController(text: _controller.fat.toString());
    final promptController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: NomAIColors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Create Weekly Diet',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: NomAIColors.black,
                ),
              ),
              SizedBox(height: 24),
              _buildInputField(
                  'Calories', caloriesController, TextInputType.number),
              _buildInputField(
                  'Protein (g)', proteinController, TextInputType.number),
              _buildInputField(
                  'Carbs (g)', carbsController, TextInputType.number),
              _buildInputField(
                  'Fiber (g)', fiberController, TextInputType.number),
              _buildInputField('Fat (g)', fatController, TextInputType.number),
              _buildMultilineInputField(
                  'Additional Instructions', promptController,
                  maxLines: 4, maxLength: 600),
              SizedBox(height: 24),
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _controller.isCreating.value
                          ? null
                          : () async {
                              final success =
                                  await _controller.createWeeklyDiet(
                                calories: int.tryParse(caloriesController.text),
                                protein: int.tryParse(proteinController.text),
                                carbs: int.tryParse(carbsController.text),
                                fiber: int.tryParse(fiberController.text),
                                fat: int.tryParse(fatController.text),
                                prompt: promptController.text.isEmpty
                                    ? 'Create a healthy diet plan'
                                    : promptController.text,
                              );
                              if (success) {
                                Get.back();
                              } else {
                                Get.snackbar(
                                  'Error',
                                  'Failed to create diet plan',
                                  backgroundColor: NomAIColors.red,
                                  colorText: Colors.white,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NomAIColors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _controller.isCreating.value
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Generate Diet Plan'),
                    ),
                  )),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    TextInputType keyboardType,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: NomAIColors.black.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: context.textTheme.bodyMedium?.copyWith(
              color: NomAIColors.black,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: NomAIColors.greyLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultilineInputField(
    String label,
    TextEditingController controller, {
    int maxLines = 4,
    int maxLength = 600,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: NomAIColors.black.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.multiline,
            maxLines: maxLines,
            maxLength: maxLength,
            style: context.textTheme.bodyMedium?.copyWith(
              color: NomAIColors.black,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: NomAIColors.greyLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              counterText: '',
            ),
          ),
        ],
      ),
    );
  }
}
