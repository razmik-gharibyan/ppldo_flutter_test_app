import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:ppldo_flutter_test_app/bloc/bloc.dart';

class ConnectivityBloc extends Bloc {

  Timer _timer;

  final _connectivityController = StreamController<ConnectivityResult>();

  Sink<ConnectivityResult> get _inDeepLinkController => _connectivityController.sink;
  Stream<ConnectivityResult> get deepLinkStream => _connectivityController.stream;

  void checkConnectionStatus() {
    final connectivity = Connectivity();
    _timer = Timer.periodic(new Duration(milliseconds: 2000), (timer) async {
      final result = await connectivity.checkConnectivity();
      _inDeepLinkController.add(result);
    });
  }

  @override
  void dispose() {
    _connectivityController.close();
    _timer.cancel();
  }

}