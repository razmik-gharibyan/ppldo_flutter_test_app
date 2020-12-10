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
    _fcm = FirebaseMessaging();
    _fcm.requestNotificationPermissions();
    _fcm.configure(onMessage: (msg) {
      print(msg);
      return;
    }, onLaunch: (msg) {
      final routeUrl = msg["data"]["webviewUrl"];
      _inCloudMessagingController.add(routeUrl);
      return;
    }, onResume: (msg) {
      final routeUrl = msg["data"]["webviewUrl"];
      _inCloudMessagingController.add(routeUrl);
      return;
    });
    await _fcm.setAutoInitEnabled(false);
  }

  Future<String> getDeviceToken() async {
    return await _fcm.getToken();
  }

  Future deleteDeviceToken() async {
    try {
      bool didDelete = await _fcm.deleteInstanceID();
      print(didDelete);
    } catch (e) {
      print("DELETE TOKEN EXCEPTION IS $e");
    }
  }

  @override
  void dispose() {
    _cloudMessagingController.close();
  }

}