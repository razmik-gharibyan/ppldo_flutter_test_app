import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GlobalVariables{
  static final Color accentColor = Color(0xFF7CB342);
  static final Color inactiveColor = Color(0xFF7F7F7F);
  static final Color logoGrey = Color(0xFF2C3243);
  static final Color errorCode = Color(0xFFCC7070);
  static final Color darkBackgroundColor = Color(0xFF272C3C);
  static final userHighlightedColor = Color(0xFF007AFF);
  static final linksColor = Color(0xFF4A90E2);
  static final String httpUrl = "https://api-rc.ppl.do/graphql";
  static final String wsUrl = "wss://api-rc.ppl.do/graphql";

}

class TextualLogo extends StatelessWidget {
  final bool white;
  final bool long;
  const TextualLogo({
    Key key,
    this.white  = false, this.long = true
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return AutoSizeText.rich(
      TextSpan(
        text: long ? 'PPL' : 'P',
        style: TextStyle(
            color: white ? Colors.white : GlobalVariables.accentColor,
            fontSize: 100,
            fontWeight: FontWeight.w800),
      children: <TextSpan>[
        TextSpan(
          text: long ? 'DO' : 'D',
          style: TextStyle(
            color: white ? GlobalVariables.logoGrey : Colors.white,
              fontSize: 100, fontWeight: FontWeight.w800),
        )
      ],
      ),
      maxLines: 1,
      wrapWords: false,
      softWrap: false,
    );
  }
}