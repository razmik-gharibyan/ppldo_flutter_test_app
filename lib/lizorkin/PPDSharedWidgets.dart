import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'GlobalVariables.dart';

class PPDAppBar extends PlatformAppBar {
  final String titleText;

  @override
  Color get backgroundColor => GlobalVariables.accentColor;

  @override
  Widget get title => PlatformText(titleText);

  @override
  Widget build(BuildContext context) => PlatformAppBar();

  PPDAppBar({this.titleText: 'People Do'});
}

class PPDLabeledInput extends StatelessWidget {
  final String labelText;
  final Icon icon;
  final String mask;
  final int maxLength;
  final TextInputType inputType;
  final List<TextInputFormatter> inputFormatters;
  final TextEditingController textEditingController;
  final Function(String value) onChanged;

  PPDLabeledInput(
      {this.maxLength: 0,
      this.mask,
      this.icon,
      this.labelText,
      this.inputType: TextInputType.text,
      this.inputFormatters,
      this.onChanged,
      this.textEditingController});

  @override
  Widget build(BuildContext context) {
    final bool doMat = isMaterial(context);
    int currentCount = 0;

    if (isCupertino(context)) {
      return CupertinoTextField(
        maxLength: maxLength > 0 ? maxLength : null,
        placeholder: labelText,
        inputFormatters: inputFormatters,
        placeholderStyle: TextStyle(
            color: GlobalVariables.accentColor.withAlpha(90),
            fontStyle: FontStyle.italic),
        prefix: icon,
        keyboardType: inputType,
        onChanged: (val) {
          currentCount = val.length;
          onChanged(val);
        },
        controller: textEditingController,
      );
    } else {
      return TextFormField(
        keyboardType: inputType,
        inputFormatters: inputFormatters,
        maxLength: maxLength > 0 ? maxLength : null,
        decoration: InputDecoration(
            labelText: labelText,
            icon: icon,
            filled: true,
            labelStyle: TextStyle(color: GlobalVariables.accentColor),
            border: UnderlineInputBorder(),
            counterText: maxLength > 0 ? "$currentCount/$maxLength" : null),
        onChanged: (val) {
          currentCount = val.length;
          onChanged(val);
        },
        controller: textEditingController,
      );
    }
  }
}
