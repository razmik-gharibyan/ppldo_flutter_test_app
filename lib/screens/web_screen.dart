import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:ppldo_flutter_test_app/repo/connection/connection_checker.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebScreen extends StatefulWidget {

  static const String routeName = "/web-screen";

  @override
  _WebScreenState createState() => _WebScreenState();
}

class _WebScreenState extends State<WebScreen> {

  // Constants
  final String _initialUrl = "https://dev.ppl.do";
  // Tools
  ConnectionChecker _connectionChecker;
  // Vars
  WebViewController _controller;
  StreamSubscription _subscription;
  bool _noInternet = true;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    _connectionChecker = ConnectionChecker();
    _connectionChecker.checkConnectionStatus();
    final result = _connectionChecker.connectivityStream;
    result.listen((event) {
      if (event == ConnectivityResult.none) {
        setState(() {
          _noInternet = true;
        });
      } else {
        setState(() {
          _noInternet = false;
        });
      }
    });

  }

  @override
  void dispose() {
    _subscription.cancel();
    _connectionChecker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text("ppldonet test application"),
        ),
        body: _noInternet
              ? Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.red,
                    child: Text(
                      "No network connection",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                ],
              )
              : WebView(
                  initialUrl: _initialUrl,
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController webViewController) {
                    _controller = webViewController;
                  },
                  gestureNavigationEnabled: true,
                )
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    var canGoBack = await _controller.canGoBack();
    if(canGoBack) {
      _controller.goBack();
      if (Platform.isAndroid) {
        return false;
      } else {
        return null;
      }
    }
    if (Platform.isAndroid) {
      return true;
    } else {
      return null;
    }
  }
}
