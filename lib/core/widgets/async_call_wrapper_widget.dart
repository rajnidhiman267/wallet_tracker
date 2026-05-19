// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:tracker_app/core/theme/app_color.dart';

 
///
/// Wrap around any widgets that makes an async call to show a modal progress
/// indicator while the async call is in progress.
///
/// The progress indicator can be turned on or off using [inAsyncCall]
///
/// The progress indicator defaults to a [CircularProgressIndicator] but can be
/// any kind of widgets
///
/// The progress indicator can be positioned using [offset] otherwise it is
/// centered
///
/// The modal barrier can be dismissed using [dismissible]
///
/// The color of the modal barrier can be set using [color]
///
/// The opacity of the modal barrier can be set using [opacity]
///
class ModalProgressHUD extends StatelessWidget {
  final bool inAsyncCall;
  final double opacity;
  final Color color;
  final Offset? offset;
  final bool dismissible;
  final bool showLoader;
  final Widget? child;

  const ModalProgressHUD({
    super.key,
    required this.inAsyncCall,
    this.opacity = 0.8,
    this.color = Colors.black54,
    this.offset,
    this.dismissible = false,
    this.showLoader = true,
    @required this.child,
  })  : assert(child != null);

  @override
  Widget build(BuildContext context) {
    if (!inAsyncCall) return child!;

    Widget layOutProgressIndicator;
    if (offset == null) {
      layOutProgressIndicator = Center(
          child: CircularProgressIndicator(
        color: AppColors.primaryButtonColor,
      ));
    } else {
      layOutProgressIndicator = Positioned(
        left: offset!.dx,
        top: offset!.dy,
        child: CircularProgressIndicator(
          color: AppColors.primaryButtonColor,
        ),
      );
    }

    return Stack(
      children: [
        child!,
        Positioned.fill(
          child: Opacity(
            opacity: opacity,
            child: ModalBarrier(dismissible: dismissible, color: color),
          ),
        ),
        showLoader == true ? layOutProgressIndicator : const SizedBox(),
      ],
    );
  }
}
