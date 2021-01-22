import 'dart:async';

import 'package:people_do/bloc/bloc.dart';

class JSCommunicationBloc implements Bloc {

  // -- CookieTimer
  Timer _timer;
  // -- Controllers
  final _cookieTimerController = StreamController<bool>();
  final _addContactController = StreamController<String>();
  // -- Sinks
  Sink<bool> get _inCookieTimerController => _cookieTimerController.sink;
  Sink<String> get _inAddContactController => _addContactController.sink;
  // -- Streams
  Stream<bool> get cookieTimerStream => _cookieTimerController.stream;
  Stream<String> get addContactStream => _addContactController.stream;

  void startSession() {
    _startCookieTimer();
  }

  void _startCookieTimer() {
    _timer = Timer.periodic(new Duration(seconds: 5), (timer) async {
      _inCookieTimerController.add(true);
    });
  }

  void addContactNumber(String number) {
    _inAddContactController.add(number);
  }

  @override
  void dispose() {
    _timer.cancel();
    _cookieTimerController.close();
    _addContactController.close();
  }

}