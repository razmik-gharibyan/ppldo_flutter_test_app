import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ppldo_flutter_test_app/bloc/bloc.dart';

class CloudMessagingBloc implements Bloc {

  // Tools
  FirebaseMessaging _fcm;

  final _cloudMessagingController = StreamController<String>();

  Sink<String> get _inCloudMessagingController => _cloudMessagingController.sink;
  Stream<String> get cloudMessagingStream => _cloudMessagingController.stream;

  void initCloudMessaging() {
    _fcm = FirebaseMessaging();
    if (Platform.isIOS) {
      _fcm.requestNotificationPermissions();
    }
    _fcm.configure(onMessage: (msg) {
      print(msg);
      return;
    }, onLaunch: (msg) {
      print(msg);
      return;
    }, onResume: (msg) {
      print(msg);
      return;
    });
  }

  Future<String> getDeviceToken() async {
    return await _fcm.getToken();
  }

  @override
  void dispose() {
    _cloudMessagingController.close();
  }

}