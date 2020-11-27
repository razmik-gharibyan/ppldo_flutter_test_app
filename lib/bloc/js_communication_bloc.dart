import 'dart:async';

import 'package:ppldo_flutter_test_app/bloc/bloc.dart';

class JSCommunicationBloc implements Bloc {

  // Tools
  Timer _timer;
  // -- CookieTimer
  final _cookieTimerController = StreamController<bool>();
  Sink<bool> get _inCookieTimerController => _cookieTimerController.sink;
  Stream<bool> get cookieTimerStream => _cookieTimerController.stream;

  void startSession() {
    _startCookieTimer();
  }

  void _startCookieTimer() {
    _timer = Timer.periodic(new Duration(seconds: 5), (timer) async {
      _inCookieTimerController.add(true);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _cookieTimerController.close();
  }

}