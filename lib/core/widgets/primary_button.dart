import 'package:flutter/material.dart';
import 'package:tracker_app/core/theme/app_color.dart';

class PrimaryOutlineButton extends StatelessWidget {
  const PrimaryOutlineButton({
    super.key,
    required this.title,
    this.onPressed,
    this.iconData,
    this.isLoading,
    this.style,

    this.iconPadding,
  });

  final String title;
  final Widget? iconData;
  final VoidCallback? onPressed;
  final bool? isLoading;
  final TextStyle? style;

  final double? iconPadding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.primaryButtonColor,
          side: const BorderSide(color: AppColors.primaryButtonColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconData != null) ...[iconData!],
              (isLoading == true)
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.primaryButtonColor,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      title,
                      style:
                          style ??
                          Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: AppColors.whiteColor,
                          ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
