

import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:people_do/lizorkin/PPDNetwork/Parsers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'GlobalVariables.dart';
import 'LoginWindow.dart';
import 'MainWidget.dart';
import 'PPDNetwork/PPDNetwork.dart';

class LocalSettings
{
  static final LocalSettings _singleton = LocalSettings._internal();

  LocalSettings._internal(){
    SharedPreferences.getInstance().then((prefs) {
      LocalSettings().expirationDate.addListener(() {
        prefs.setInt("expirationDate",
            LocalSettings().expirationDate?.value?.millisecondsSinceEpoch ?? 0);
      });
      LocalSettings().expiration.addListener(() {
        prefs.setInt("expiration", LocalSettings().expiration.value ?? 0);
      });
      LocalSettings().token.addListener(() {
        prefs.setString('token', LocalSettings().token.value);
      });
      try {
        LocalSettings().token.value = prefs.getString("token");
        LocalSettings().expiration.value = prefs.getInt("expiration");
        LocalSettings().expirationDate.value =
            DateTime.fromMillisecondsSinceEpoch(prefs.getInt("expirationDate"));
      } catch (e) {}
      loading.value = false;
    });
  }

  final ValueNotifier<String> token = ValueNotifier<String>("");
  final ValueNotifier<int> expiration = ValueNotifier<int>(0);
  final ValueNotifier<DateTime> expirationDate = ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<bool> loading = ValueNotifier<bool>(true);

  UserProfileParser user;

  factory LocalSettings() {
    return _singleton;
  }

}
