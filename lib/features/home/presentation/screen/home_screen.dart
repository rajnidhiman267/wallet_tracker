import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_app/core/routes/app_route_name.dart';
import 'package:tracker_app/core/theme/app_color.dart';
import 'package:tracker_app/core/widgets/custom_profile_image_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,

      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.whiteColor,
          title: Row(
            spacing: 8,
            children: [
              CustomProfileImageWidget(
                imageSize: 45,
                image: FirebaseAuth.instance.currentUser?.photoURL,
              ),
              Text(
                "Hello ${FirebaseAuth.instance.currentUser?.displayName}",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, size: 20 ),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                context.goNamed(AppRouteName.login);
              },
            ),
          ],
        ),
        backgroundColor: AppColors.whiteColor,
        body: Column(children: [
           
          ],
        ),
      ),
    );
  }
}
