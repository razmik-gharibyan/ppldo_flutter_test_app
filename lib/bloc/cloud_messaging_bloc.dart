import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ppldo_flutter_test_app/bloc/bloc.dart';

class CloudMessagingBloc implements Bloc {

  // Tools
  FirebaseMessaging _fcm;

  final _cloudMessagingController = StreamController<String>();

  Sink<String> get _inCloudMessagingController => _cloudMessagingController.sink;
  Stream<String> get cloudMessagingStream => _cloudMessagingController.stream;

  void initCloudMessaging() async {
    _fcm = FirebaseMessaging.instance;
    if (_fcm.isAutoInitEnabled) {
      await _fcm.setAutoInitEnabled(false);
    }
    _fcm.requestPermission();
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final routeUrl = message.data["webviewUrl"];
      _inCloudMessagingController.add(routeUrl);
    });
  }

  Future<String> getDeviceToken() async {
    return await _fcm.getToken();
  }

  Future deleteDeviceToken() async {
    await _fcm.deleteToken();
  }

  @override
  void dispose() {
    _cloudMessagingController.close();
  }

}