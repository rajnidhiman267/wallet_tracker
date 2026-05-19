import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:tracker_app/core/theme/app_color.dart';

class AppTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final bool isPassword;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final Function()? onTextFormFieldTap;
  final Widget? suffix;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final int? maxLength;
  final AutovalidateMode? autovalidateMode;
  final String? prefixText;
  final BoxConstraints? suffixIconConstraints;

  const AppTextFormField({
    super.key,
    required this.controller,
    this.hintText,
    this.textInputAction,
    this.maxLines,
    this.isPassword = false,
    this.onChanged,
    this.validator,
    this.onTextFormFieldTap,
    this.suffix,
    this.readOnly = false,
    this.inputFormatters,
    this.prefixIcon,
    this.keyboardType,
    this.maxLength,
    this.autovalidateMode,
    this.prefixText,
    this.suffixIconConstraints,
  });

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  bool _hidePassword = true;

  @override
  Widget build(BuildContext context) {
    final isPasswordField = widget.isPassword;

    return TextFormField(
      autovalidateMode: widget.autovalidateMode,
      onTap: widget.onTextFormFieldTap,
      controller: widget.controller,
      textInputAction: widget.textInputAction ?? TextInputAction.next,
      obscureText: isPasswordField ? _hidePassword : false,
      maxLines: widget.maxLines,
      onChanged: widget.onChanged,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      style: Theme.of(context).textTheme.bodySmall,
      readOnly: widget.readOnly,
      inputFormatters: widget.inputFormatters,
      cursorColor: AppColors.hintTextColor,

      maxLength: widget.maxLength,
      decoration: InputDecoration(
        prefixStyle: Theme.of(context).textTheme.bodySmall,
        prefixText: widget.prefixText,
        hintText: widget.hintText ?? "",
        hintStyle: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.hintTextColor),

        fillColor: AppColors.bgTextFieldColor,
        filled: true,

        /// 🔥 Password Toggle Icon
        suffixIcon: isPasswordField
            ? IconButton(
                splashColor: Colors.transparent,
                icon: Icon(
                  _hidePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 16,
                  color: AppColors.secondaryColor,
                ),
                onPressed: () {
                  setState(() {
                    _hidePassword = !_hidePassword;
                  });
                },
              )
            : widget.suffix,
        suffixIconConstraints: widget.suffixIconConstraints,
        prefixIcon: widget.prefixIcon,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(),
        errorStyle: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: AppColors.dangerColor),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.hintTextColor, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.dangerColor, width: 1),
        ),
        errorMaxLines: 3,
      ),
    );
  }

  OutlineInputBorder _border() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.hintTextColor, width: 1),
    );
  }
}
