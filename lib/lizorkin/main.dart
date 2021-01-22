
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:people_do/lizorkin/ErrorsLog.dart';
import 'package:people_do/lizorkin/GlobalVariables.dart';
import 'package:people_do/lizorkin/widgets/LoadingScreen.dart';
import 'package:people_do/lizorkin/widgets/SplashScreen.dart';


void main() {
  runApp(PeopleDoApp());
}

class PeopleDoApp extends StatelessWidget {
  // This widget is the root of your application.

  final ErrorsLog log = ErrorsLog();


  @override
  Widget build(BuildContext context) {
    return PlatformApp(
      localizationsDelegates: [DefaultMaterialLocalizations.delegate],
      material: (_, __) =>
          MaterialAppData(
              theme: ThemeData(
                primaryColor: GlobalVariables.accentColor,
              )),
      color: GlobalVariables.accentColor,
      title: 'People Do',
      home: SplashScreen(),
    );
  }

}


