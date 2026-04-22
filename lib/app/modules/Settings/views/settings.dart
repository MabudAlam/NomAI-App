import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:NomAi/app/modules/Auth/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:NomAi/app/modules/Onboarding/views/onboarding_home.dart';
import 'package:NomAi/app/modules/Settings/views/adjust_goals.dart';
import 'package:NomAi/app/repo/firebase_user_repo.dart';

import 'edit_profile.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late String _userId;
  final FirebaseUserRepo _userRepository = FirebaseUserRepo();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthenticationBloc>().state;
    if (authState.user == null) {
      return;
    }

    _userId = authState.user!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text(
            'Settings',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        body: FutureBuilder(
          future: _userRepository.getUserById(_userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else {
              final userModel = snapshot.data;
              if (userModel == null || userModel.userInfo == null) {
                return const Center(
                  child: Text('Profile data is unavailable.'),
                );
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPersonalStat(
                          'Age', userModel.userInfo!.age.toString()),
                      const SizedBox(height: 16),
                      _buildPersonalStat(
                          'Height', '${userModel.userInfo!.currentHeight} cm'),
                      const SizedBox(height: 16),
                      _buildPersonalStat('Current Weight',
                          '${userModel.userInfo!.currentWeight} kg'),
                      SizedBox(height: 2.h),

                      const Divider(thickness: 1),

                      SizedBox(height: 2.h),
                      const Text(
                        'Customization',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildNavigationItem(
                        'Personal details',
                        onTap: () {
                          Get.to(
                            () => EditUserBasicInfoView(
                              userBasicInfo: userModel.userInfo!,
                              userModel: userModel,
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 2.h),
                      _buildNavigationItem(
                        'Adjust goals',
                        subtitle: 'Calories, carbs, fats, and protein',
                        onTap: () {
                          Get.to(() => AdjustGoalsView(
                                userMacros: userModel.userInfo!.userMacros,
                                userBasicInfo: userModel.userInfo,
                                userModel: userModel,
                              ));
                        },
                      ),
                      SizedBox(height: 2.h),

                      const Divider(thickness: 1),
                      SizedBox(height: 2.h),
                      _buildLogoutButton(
                        onTap: () async {
                          final shouldLogout = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              title: const Text('Log out'),
                              content: const Text(
                                'Are you sure you want to log out?',
                              ),
                              actionsAlignment: MainAxisAlignment.end,
                              actionsPadding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                bottom: 12,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.black,
                                  ),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Log out'),
                                ),
                              ],
                            ),
                          );

                          if (shouldLogout == true) {
                            await _userRepository.logOut();
                            if (!mounted) return;
                            Get.offAll(() => const OnboardingHome());
                          }
                        },
                      ),

                      // SizedBox(height: 2.h),
                      // const Text(
                      //   'Preferences',

                      //   style: TextStyle(
                      //     fontSize: 22,
                      //     fontWeight: FontWeight.bold,
                      //     color: Colors.black,
                      //   ),
                      // ),
                      // const SizedBox(height: 24),
                      // _buildToggleItem(
                      //     'Burned Calories',
                      //     'Add burned calories to daily goal',
                      //     isCaloriesBurnedEnabled, (value) {
                      //   setState(() {
                      //     isCaloriesBurnedEnabled = value;
                      //   });
                      // }),
                      // SizedBox(height: 2.h),

                      // const Divider(thickness: 1),
                      // SizedBox(height: 2.h),

                      // const SizedBox(height: 16),
                      // const Text(
                      //   'Legal',
                      //   style: TextStyle(
                      //     fontSize: 22,
                      //     fontWeight: FontWeight.bold,
                      //     color: Colors.black,
                      //   ),
                      // ),
                      // const SizedBox(height: 24),
                      // _buildNavigationItem('Terms and Conditions'),
                      // const SizedBox(height: 16),
                      // _buildNavigationItem('Privacy Policy'),
                      // const SizedBox(height: 16),
                      // _buildNavigationItem('Delete Account?'),
                      // const SizedBox(height: 16),

                      // Padding(
                      //   padding: const EdgeInsets.symmetric(vertical: 24.0),
                      //   child: Text(
                      //     'VERSION 1.0.62',
                      //     style: TextStyle(
                      //       fontSize: 12,
                      //       color: Colors.grey[700],
                      //     ),
                      //   ),
                      // ),

                      // const SizedBox(height: 60),
                    ],
                  ),
                ),
              );
            }
          },
        ));
  }

  Widget _buildPersonalStat(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationItem(
    String title, {
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton({
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text(
          'Log out',
          style: TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
