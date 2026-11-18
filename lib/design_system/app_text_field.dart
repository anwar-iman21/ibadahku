import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_text.dart';
import 'extensions.dart';

/// Input teks dengan label di atas, validasi, dan toggle show/hide password.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.helper,
    this.controller,
    this.focusNode,
    this.icon,
    this.prefixText,
    this.suffixText,
    this.obscure = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.autofocus = false,
    this.errorText,
    this.enabled = true,
    this.maxLines = 1,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  final String? label;
  final String? hint;
  final String? helper;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final IconData? icon;
  final String? prefixText;
  final String? suffixText;
  final bool obscure;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final String? errorText;
  final bool enabled;
  final int maxLines;
  final AutovalidateMode autovalidateMode;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _hide = true;

  OutlineInputBorder _border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: Rad.mdR,
        borderSide: BorderSide(color: c, width: w),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AppText.sm.medium),
          const VGap(6),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: widget.obscure && _hide,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          textInputAction: widget.textInputAction,
          autofocus: widget.autofocus,
          enabled: widget.enabled,
          maxLines: widget.obscure ? 1 : widget.maxLines,
          autovalidateMode: widget.autovalidateMode,
          style: AppText.base,
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helper,
            helperMaxLines: 3,
            errorText: widget.errorText,
            errorMaxLines: 3,
            filled: true,
            fillColor: context.fieldFill,
            prefixIcon: widget.icon == null
                ? null
                : Icon(widget.icon, size: 20, color: context.mutedText),
            prefixText: widget.prefixText,
            suffixText: widget.suffixText,
            suffixIcon: widget.obscure
                ? IconButton(
                    tooltip: _hide ? 'Tampilkan password' : 'Sembunyikan password',
                    icon: Icon(_hide
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () => setState(() => _hide = !_hide),
                  )
                : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: Sp.s4, vertical: 14),
            border: _border(context.borderColor),
            enabledBorder: _border(context.borderColor),
            disabledBorder: _border(context.borderColor),
            focusedBorder: _border(AppColors.green[600], 1.8),
            errorBorder: _border(AppColors.error),
            focusedErrorBorder: _border(AppColors.error, 1.8),
          ),
        ),
      ],
    );
  }
}
