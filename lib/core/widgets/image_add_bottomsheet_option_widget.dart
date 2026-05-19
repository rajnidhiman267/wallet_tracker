import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:tracker_app/core/theme/app_color.dart';

class ImageChooseBottomSheetWidget extends StatelessWidget {
  const ImageChooseBottomSheetWidget({
    super.key,
    this.onGalleryOptionTap,
    this.onCameraOptionTap,
  });
  final Function()? onGalleryOptionTap;
  final Function()? onCameraOptionTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: IntrinsicHeight(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),

          child: Column(
            children: [
              Container(
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.hintTextColor,
                ),
              ),

              Padding(
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Add image",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    InkWell(
                      onTap: () => context.pop(),
                      child: Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              const Divider(),

              itemIconWithLabel(
                context: context,
                onTap: () {
                  context.pop();
                  if (onGalleryOptionTap != null) {
                    onGalleryOptionTap!();
                  }
                },
                title: "Choose from Gallery",
                image: Icons.browse_gallery_outlined,
              ),
              itemIconWithLabel(
                context: context,
                onTap: () {
                  context.pop();
                  if (onCameraOptionTap != null) {
                    onCameraOptionTap!();
                  }
                },
                title: "Take a Photo",
                image: Icons.camera_alt_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }

  InkWell itemIconWithLabel({
    required Function()? onTap,
    required String title,
    required IconData image,
    required BuildContext context,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          spacing: 12,
          children: [
            Icon(image, color: AppColors.hintTextColor),

            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
