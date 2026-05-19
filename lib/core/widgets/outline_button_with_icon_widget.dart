import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tracker_app/core/theme/app_color.dart';

class OutlineButtonWithIconWidget extends StatelessWidget {
  final String svgImage;
  final String label;
  final void Function() onTap;
  const OutlineButtonWithIconWidget({
    super.key,
    required this.svgImage,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width / 1.5,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor),
        ),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(
          spacing: 12,
          mainAxisAlignment: .center,
          children: [
            SvgPicture.asset(svgImage, height: 24, width: 24),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
