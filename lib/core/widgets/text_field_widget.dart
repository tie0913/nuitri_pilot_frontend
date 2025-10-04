import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 为了 TextInputFormatter / AutofillHints

/// 通用文本输入（带统一样式、可选清空按钮）
/// - 如果传入了 suffixIcon，就不再显示清空按钮
/// - 如果需要密码遮盖，直接把 [obscureText] 设为 true，或用下面的 AppPasswordField
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.label,
    this.hintText,
    this.requiredMark = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.showClearButton = true,
    this.readOnly = false,
    this.enabled,
    this.autofillHints,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.maxLines = 1,
    this.minLines,
    this.obscureText = false,
    this.obscuringCharacter = '•',
    this.enableSuggestions = true,
    this.autocorrect = true,
  });

  final TextEditingController controller;

  final String? label;
  final String? hintText;
  final bool requiredMark;

  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  final String? Function(String?)? validator;

  final TextInputAction textInputAction;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;

  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool showClearButton;

  final bool readOnly;
  final bool? enabled;

  final Iterable<String>? autofillHints;
  final AutovalidateMode autovalidateMode;

  final int maxLines;
  final int? minLines;

  final bool obscureText;
  final String obscuringCharacter;
  final bool enableSuggestions;
  final bool autocorrect;

  @override
  Widget build(BuildContext context) {
    // 用 ValueListenableBuilder 监听文本变化，控制清空按钮显隐
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final bool canShowClear =
            showClearButton && suffixIcon == null && !readOnly && (value.text.isNotEmpty);

        return TextFormField(
          controller: controller,
          readOnly: readOnly,
          enabled: enabled,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          onChanged: onChanged,
          autofillHints: autofillHints,
          autovalidateMode: autovalidateMode,

          // 遮盖时强制单行，避免布局异常
          maxLines: obscureText ? 1 : maxLines,
          minLines: obscureText ? 1 : minLines,

          obscureText: obscureText,
          obscuringCharacter: obscuringCharacter,
          enableSuggestions: enableSuggestions,
          autocorrect: autocorrect,

          decoration: InputDecoration(
            labelText: label == null ? null : (requiredMark ? '$label *' : label),
            hintText: hintText,
            prefixIcon: prefixIcon,
            // 只放一个后缀：优先用调用方提供的 suffixIcon；否则显示清空按钮
            suffixIcon: suffixIcon ??
                (canShowClear
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'clear',
                        onPressed: () {
                          controller.clear();
                          onChanged?.call('');
                        },
                      )
                    : null),
          ),
          validator: validator,
        );
      },
    );
  }
}

/// 密码输入（组合，而不是继承），自带“显示/隐藏”切换
class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    required this.controller,
    this.label = 'Password',
    this.validator,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final void Function(String)? onSubmitted;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      label: widget.label,
      requiredMark: true,
      keyboardType: TextInputType.visiblePassword,
      autofillHints: const [AutofillHints.password],
      obscureText: _obscure,
      obscuringCharacter: '•',
      enableSuggestions: false,
      autocorrect: false,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      validator: widget.validator ??
          (v) {
            //if (v == null || v.isEmpty) return '请输入密码';
            //if (v.length < 8) return '至少 8 位';
            return null;
          },
      suffixIcon: IconButton(
        tooltip: _obscure ? 'Show' : 'Hide',
        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    );
  }
}
