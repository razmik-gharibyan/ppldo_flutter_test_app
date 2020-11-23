import 'dart:async';

import 'package:flutter/services.dart';
import 'package:ppldo_flutter_test_app/bloc/bloc.dart';
import 'package:uni_links/uni_links.dart';

class DeepLinkBloc implements Bloc {

  final _deepLinkController = StreamController<String>();
  StreamSubscription _dlSubscription;

  Sink<String> get _inDeepLinkController => _deepLinkController.sink;
  Stream<String> get deepLinkStream => _deepLinkController.stream;

  void initUniLinks() {
    _initUniLinksFromColdStart();
    _initUniLinksFromBackground();
  }

  void _initUniLinksFromBackground() async {
    _dlSubscription = getLinksStream().listen((String link) {
      _inDeepLinkController.add(link);
    }, onError: (err) {
      print("DeepLink error occurred");
    });
  }

  void _initUniLinksFromColdStart() async {
    try {
      String initialLink = await getInitialLink();
      _inDeepLinkController.add(initialLink);
    } on PlatformException {
      print("DeepLink cold start error occurred");
    }
  }

  @override
  void dispose() {
    _dlSubscription.cancel();
    _deepLinkController.close();
  }

}