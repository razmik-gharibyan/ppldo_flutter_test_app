import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:ppldo_flutter_test_app/bloc/bloc_provider.dart';
import 'package:ppldo_flutter_test_app/bloc/connectivity_bloc.dart';
import 'package:ppldo_flutter_test_app/globals.dart' as globals;
import 'package:ppldo_flutter_test_app/screens/web_screen.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  globals.applicationMode = globals.Mode.DEVELOPMENT;
  if (kReleaseMode) {
    await SentryFlutter.init(
          (options) => options.dsn = 'https://912e6010faf6495d8dd13d623d85da5b@o48617.ingest.sentry.io/5559292',
      appRunner: () => runFlutterApp(),
    );
  } else {
    runFlutterApp();
  }
}

void runFlutterApp() async {
  await Firebase.initializeApp();
  await FlutterLibphonenumber().init();
  runApp(EasyLocalization(
      supportedLocales: [
        Locale("en"), Locale("ru"),
      ],
      path: "assets/lang",
      fallbackLocale: Locale("en"),
      useOnlyLangCode: true,
      child: MyApp())
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConnectivityBloc>(
      bloc: ConnectivityBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "People Do",
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: "Roboto",
        ),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: WebScreen(),
      ),
    );
  }
}
