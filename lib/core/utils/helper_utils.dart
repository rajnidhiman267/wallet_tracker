import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tracker_app/core/theme/app_color.dart';
import 'package:tracker_app/core/widgets/image_add_bottomsheet_option_widget.dart';

class HelperUtils {
  static void showCustomToast({String? toastMsg, bool isError = false}) {
    final message = toastMsg ?? "";
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: isError == true
          ? AppColors.dangerColor
          : AppColors.bgSuccessColor,
      textColor: AppColors.whiteColor,
      fontSize: 12,
    );
  }
    static void openImagePickerBottomSheet({
    required BuildContext context,
    // required Function(ImageSource source) onPick,
  }) {
    showBottomSheet(
      context: context,
      builder: (_) {
        return ImageChooseBottomSheetWidget(
          onGalleryOptionTap: () {
            // onPick(ImageSource.gallery);
          },
          onCameraOptionTap: () {
            // onPick(ImageSource.camera);
          },
        );
      },
    );
  }
}
