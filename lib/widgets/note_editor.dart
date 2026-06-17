import 'package:code_text_field/code_text_field.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/gruvbox-dark.dart';
import 'package:flutter_highlight/themes/gruvbox-light.dart';

/// Wraps [CodeField] in [CodeTheme] + transparent [Material] because the
/// editor uses Material widgets internally but Outline runs [FluentApp].
class NoteEditor extends StatelessWidget {
  const NoteEditor({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final CodeController controller;
  final void Function(String content) onChanged;

  @override
  Widget build(BuildContext context) {
    final brightness = fluent.FluentTheme.of(context).brightness;
    final styles =
        brightness == fluent.Brightness.dark ? gruvboxDarkTheme : gruvboxLightTheme;

    return CodeTheme(
      data: CodeThemeData(styles: styles),
      child: Material(
        type: MaterialType.transparency,
        child: CodeField(
          controller: controller,
          onChanged: onChanged,
          expands: true,
          textStyle: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
