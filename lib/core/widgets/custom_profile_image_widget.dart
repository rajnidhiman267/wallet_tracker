import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';

import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:tracker_app/core/theme/app_color.dart';

class CustomProfileImageWidget extends StatelessWidget {
  const CustomProfileImageWidget({
    super.key,
    this.image,
    this.imageSize = 100,
    this.onAddButtonClick,
    this.showAddOptionText = true,
    this.isCompanyProfile = true,
  });

  final String? image;
  final double imageSize;
  final Function()? onAddButtonClick;
  final bool showAddOptionText;
  final bool isCompanyProfile;

  @override
  Widget build(BuildContext context) {
    final hasImage = image != null && image!.trim().isNotEmpty;

    return GestureDetector(
      onTap: onAddButtonClick,
      child: Container(
        height: imageSize,
        width: imageSize,
        margin: EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: hasImage ? Colors.transparent : AppColors.bgTextFieldColor,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: hasImage ? _buildImage() : _placeholder(),
        ),
      ),
    );
  }

  /// 🔥 Handles ALL types (network + local + asset)
  Widget _buildImage() {
    final img = image!.trim();

    final isNetwork = img.startsWith("http") || img.startsWith("https");

    final isLocal = File(img).existsSync();

    /// 🌐 Network Image
    if (isNetwork) {
      return CachedNetworkImage(
        imageUrl: img,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,

        placeholder: (context, url) => _shimmer(),

        errorWidget: (context, url, error) => _errorWidget(),

        errorListener: (error) {
          debugPrint("Profile image load failed: $error");
        },
      );
    }

    /// 📱 Local File Image
    if (isLocal) {
      return Image.file(
        File(img),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => _errorWidget(),
      );
    }

    /// 📦 Asset Image (fallback if you pass asset path)
    return Image.asset(
      img,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _errorWidget(),
    );
  }

  /// ✨ Shimmer
  Widget _shimmer() {
    return Shimmer(
      color: AppColors.hintTextColor,
      child: Container(color: Colors.grey[300]),
    );
  }

  /// ❌ Error UI
  Widget _errorWidget() {
    return Container(
      color: Colors.grey[200],
      alignment: Alignment.center,
      child: _placeholder(),
    );
  }

  /// 🧩 Placeholder
  Widget _placeholder() {
    return Icon(Icons.person, color: AppColors.hintTextColor, size: 20);
  }
}
