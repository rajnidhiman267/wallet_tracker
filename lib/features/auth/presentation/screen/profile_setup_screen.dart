import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_app/core/routes/app_route_name.dart';
import 'package:tracker_app/core/utils/helper_utils.dart';
import 'package:tracker_app/core/utils/validation_utils.dart';
import 'package:tracker_app/core/widgets/async_call_wrapper_widget.dart';
import 'package:tracker_app/core/widgets/custom_profile_image_widget.dart';
import 'package:tracker_app/core/widgets/label_with_text_form_field.dart';
import 'package:tracker_app/core/widgets/primary_button.dart';
import 'package:tracker_app/features/auth/presentation/bloc/sign_up_state.dart';
import 'package:tracker_app/features/auth/presentation/bloc/update_profile_cubit.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  late TextEditingController userNameCtrl;

  late GlobalKey<FormState> profileKey;

  @override
  void initState() {
    super.initState();
    userNameCtrl = TextEditingController();

    profileKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileSetupCubit, SignUpState>(
      listener: (context, state) {
        if (state.isSuccess == true) {
          HelperUtils.showCustomToast(toastMsg: "Profile updated successfully");
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
        return ModalProgressHUD(
          inAsyncCall: state.isLoading,
          child: SafeArea(
            top: false,
            child: Scaffold(
              backgroundColor: Colors.white,
              bottomNavigationBar: Padding(
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: PrimaryOutlineButton(
                  title: 'Save',
                  onPressed: () {
                    if (profileKey.currentState!.validate()) {
                      FocusScope.of(context).unfocus();
                      context.read<ProfileSetupCubit>().updateProfile(
                        name: userNameCtrl.text,
                        photoUrl: '',
                      );
                    }
                  },
                ),
              ),
              body: Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height / 1.5,
                    child: Column(
                      spacing: 36,
                      mainAxisAlignment: .center,
                      // crossAxisAlignment: .start,
                      children: [
                        Column(
                          spacing: 8,
                          crossAxisAlignment: .start,
                          children: [
                            Text(
                              'Complete your profile',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Text(
                              "Fill in your details to complete your profile",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),

                        Form(
                          key: profileKey,
                          child: Column(
                            crossAxisAlignment: .center,
                            mainAxisAlignment: .center,
                            spacing: 12,
                            children: [
                              Center(
                                child: CustomProfileImageWidget(
                                  onAddButtonClick: () {
                                    HelperUtils.openImagePickerBottomSheet(
                                      context: context,
                                    );
                                  },
                                ),
                              ),
                              LabelWithTextFormField(
                                label: "Name",
                                hintText: "Enter your name",
                                controller: userNameCtrl,
                                validator: (value) => AppValidator()
                                    .requiredField(value, fieldName: "name"),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                keyboardType: TextInputType.name,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
