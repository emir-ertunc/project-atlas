import 'package:flutter/material.dart';
import 'package:project_atlas/core/design_system/components/app_dashboard_card.dart';
import 'package:project_atlas/core/design_system/tokens/app_component_tokens.dart';
import 'package:project_atlas/core/design_system/tokens/app_spacing.dart';

class AppDenseFormSection extends StatelessWidget {
  const AppDenseFormSection({
    required this.title,
    required this.children,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppDashboardCard(
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0) const SizedBox(height: AppSpacing.sm),
            children[index],
          ],
        ],
      ),
    );
  }
}

class AppDenseTextField extends StatelessWidget {
  const AppDenseTextField({
    required this.label,
    this.controller,
    this.initialValue,
    this.helperText,
    this.suffixText,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.enabled = true,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final String? helperText;
  final String? suffixText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        suffixText: suffixText,
        isDense: true,
        constraints: const BoxConstraints(
          minHeight: AppComponentTokens.denseControlHeight,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
      ),
    );
  }
}
