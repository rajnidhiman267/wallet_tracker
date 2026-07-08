import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tracker_app/core/theme/app_color.dart';
import 'package:tracker_app/core/widgets/image_add_bottomsheet_option_widget.dart';

class HelperUtils {
  static void showCustomToast({String? toastMsg, bool isError = false}) {
    final message = toastMsg ?? '';
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor:
          isError ? AppColors.dangerColor : AppColors.bgSuccessColor,
      textColor: AppColors.whiteColor,
      fontSize: 12,
    );
  }

  // FIX: onPick callback is now active and returns the picked file path
  static void openImagePickerBottomSheet({
    required BuildContext context,
    required Function(String path) onPick, // ← caller receives the path
  }) {
    showBottomSheet(
      context: context,
      builder: (_) {
        return ImageChooseBottomSheetWidget(
          onGalleryOptionTap: () async {
            Navigator.pop(context);
            final picked = await ImagePicker()
                .pickImage(source: ImageSource.gallery, imageQuality: 70);
            if (picked != null) onPick(picked.path);
          },
          onCameraOptionTap: () async {
            Navigator.pop(context);
            final picked = await ImagePicker()
                .pickImage(source: ImageSource.camera, imageQuality: 70);
            if (picked != null) onPick(picked.path);
          },
        );
      },
    );
  }
}