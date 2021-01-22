import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:people_do/lizorkin/GlobalVariables.dart';
import 'package:people_do/lizorkin/LocalSettings.dart';
import 'package:people_do/lizorkin/widgets/LicenseScreen.dart';
import 'package:people_do/lizorkin/widgets/LoadingScreen.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    LocalSettings().loading.addListener(() {
      if (LocalSettings().loading.value == false) {
        if (LocalSettings().token.value == null ||
            LocalSettings().token.value.isEmpty) {
          Navigator.of(context).pushReplacement(platformPageRoute(
              context: context,
              builder: (_) {
                return LicenseScreen();
              }));
        } else {
          Navigator.of(context).pushReplacement(platformPageRoute(
              context: context,
              builder: (_) {
                return LoadingScreen();
              }));
        }
      }
    });
    return PlatformScaffold(
      body: SizedBox.expand(
        child: Container(
          color: Color(0xff7DB343),
          child: Center(
            child: TextualLogo(
              long: false,
              white: true,
            ),
          ),
        ),
      ),
    );
  }
}
