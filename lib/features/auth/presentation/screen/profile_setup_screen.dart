import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_app/core/routes/app_route_name.dart';
import 'package:tracker_app/core/utils/helper_utils.dart';
import 'package:tracker_app/core/utils/validation_utils.dart';
import 'package:tracker_app/core/widgets/custom_profile_image_widget.dart';
import 'package:tracker_app/core/widgets/label_with_text_form_field.dart';
import 'package:tracker_app/core/widgets/primary_button.dart';
import 'package:tracker_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:tracker_app/features/auth/presentation/bloc/update_profile_cubit.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  late TextEditingController userNameCtrl;
  late GlobalKey<FormState> profileKey;

  // FIX: track the locally picked image path so we can show it and save it
  String? _pickedImagePath;

  @override
  void initState() {
    super.initState();
    userNameCtrl = TextEditingController();
    profileKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    userNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // FIX: use scaffold background from theme instead of hardcoded white
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<ProfileSetupCubit, AuthState>(
      listener: (context, state) {
        if (state.isSuccess) {
          HelperUtils.showCustomToast(toastMsg: 'Profile updated successfully');
          context.goNamed(AppRouteName.home);
        }
        if (state.errorMessage != null) {
          HelperUtils.showCustomToast(
            toastMsg: state.errorMessage,
            isError: true,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          // FIX: removed hardcoded Colors.white — now respects dark/light theme
          appBar: AppBar(
            title: const Text('Complete Profile'),
            leading: context.canPop()
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded),
                    onPressed: () => context.pop(),
                  )
                : null,
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: PrimaryOutlineButton(
              title: 'Save',
              isLoading: state.isLoading,
              onPressed: state.isLoading
                  ? null
                  : () {
                      if (profileKey.currentState!.validate()) {
                        FocusScope.of(context).unfocus();
                        context.read<ProfileSetupCubit>().updateProfile(
                              name: userNameCtrl.text.trim(),
                              // FIX: pass the actual picked path, not empty string
                              photoUrl: _pickedImagePath,
                            );
                      }
                    },
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Form(
              key: profileKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Complete your profile',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fill in your details to complete your profile',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 36),

                  // Avatar picker — centered
                  Center(
                    child: Stack(
                      children: [
                        // FIX: pass _pickedImagePath so the widget shows the
                        // picked image immediately (reactive preview)
                        CustomProfileImageWidget(
                          imageSize: 110,
                          image: _pickedImagePath,
                          onAddButtonClick: () {
                            HelperUtils.openImagePickerBottomSheet(
                              context: context,
                              // FIX: callback now wired up — updates local state
                              onPick: (path) {
                                setState(() => _pickedImagePath = path);
                              },
                            );
                          },
                        ),
                        // Camera badge overlay
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              HelperUtils.openImagePickerBottomSheet(
                                context: context,
                                onPick: (path) {
                                  setState(() => _pickedImagePath = path);
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.scaffoldBackgroundColor,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Name field
                  LabelWithTextFormField(
                    label: 'Name',
                    hintText: 'Enter your name',
                    controller: userNameCtrl,
                    validator: (value) =>
                        AppValidator().requiredField(value, fieldName: 'name'),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 24),

                  // Info card — explains what happens next
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : theme.colorScheme.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'You can update your profile anytime from the home screen.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}