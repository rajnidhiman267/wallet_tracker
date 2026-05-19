import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tracker_app/core/widgets/app_text_form_field_widget.dart';

class LabelWithTextFormField extends StatelessWidget {
  const LabelWithTextFormField({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.image,
    this.hintText,
    this.bottomText,
    this.validator,
    this.onChange,
    this.textInputAction,
    this.needBottomText = false,
    this.isExpandedText = false,
    this.showLabelIcon = false,
    this.isPasswordField = false,
    this.onTextFormFieldTap,
    this.suffix,
    this.readOnly = false,
    this.prefixIcon,
    this.isMandatory = false,
    this.textStyle,
    this.maxLength,
    this.inputFormatters,
    this.keyboardType,
    this.autovalidateMode,
    this.prefixText,
    this.showIconWithLabel = false,
    this.isSvg = false,
    this.infoMsg,
    this.isTipToolEnable = false,
    this.labelSuffixWidget,
    this.suffixIconConstraints,
    this.iconWidget,
  });

  final String label;
  final String? image;
  final String? hintText;
  final TextEditingController controller;
  final int? maxLines;
  final bool? needBottomText;
  final bool? isExpandedText;
  final String? bottomText;
  final bool? showLabelIcon;
  final bool? isPasswordField;
  final Function(String)? onChange;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final Function()? onTextFormFieldTap;
  final Widget? suffix;
  final bool readOnly;
  final Widget? prefixIcon;
  final bool? isMandatory;
  final TextStyle? textStyle;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final AutovalidateMode? autovalidateMode;
  final String? prefixText;
  final bool showIconWithLabel;
  final bool isSvg;
  final String? infoMsg;
  final bool isTipToolEnable;
  final Widget? labelSuffixWidget;
  final Widget? iconWidget;
  final BoxConstraints? suffixIconConstraints;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),

        SizedBox(height: 4),
        AppTextFormField(
          onTextFormFieldTap: onTextFormFieldTap,
          suffix: suffix,
          readOnly: readOnly,
          controller: controller,
          hintText: hintText,
          isPassword: isPasswordField ?? false,
          maxLines: maxLines,
          maxLength: maxLength,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          autovalidateMode: autovalidateMode,
          suffixIconConstraints: suffixIconConstraints,
          validator: validator,
          onChanged: onChange,
          prefixIcon: prefixIcon,
          prefixText: autovalidateMode != AutovalidateMode.onUserInteraction
              ? null
              : prefixText,
        ),
        if (needBottomText == true) ...[
          SizedBox(height: 4),
          needBottomText == true
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    bottomText ?? " ",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ],
    );
  }
}
