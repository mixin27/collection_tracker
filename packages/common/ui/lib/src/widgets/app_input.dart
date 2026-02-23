import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

class AppInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final InputDecoration? decoration;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final bool autofocus;
  final bool enabled;
  final bool obscureText;
  final bool autocorrect;
  final bool enableSuggestions;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onTap;

  const AppInput({
    this.controller,
    this.initialValue,
    this.decoration,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.keyboardType,
    this.textInputAction,
    this.readOnly = false,
    this.autofocus = false,
    this.enabled = true,
    this.obscureText = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mergedDecoration =
        (decoration ??
                InputDecoration(
                  labelText: labelText,
                  hintText: hintText,
                  prefixIcon: prefixIcon,
                  suffixIcon: suffixIcon,
                  prefixText: prefixText,
                ))
            .copyWith(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            );

    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      decoration: mergedDecoration,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      readOnly: readOnly,
      autofocus: autofocus,
      enabled: enabled,
      obscureText: obscureText,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      smartDashesType: smartDashesType,
      smartQuotesType: smartQuotesType,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      onTap: onTap,
    );
  }
}
