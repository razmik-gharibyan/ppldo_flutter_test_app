import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:ppldo_flutter_test_app/bloc/bloc_provider.dart';
import 'package:ppldo_flutter_test_app/bloc/connectivity_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebScreen extends StatefulWidget {

  static const String routeName = "/web-screen";

  @override
  _WebScreenState createState() => _WebScreenState();
}

class _WebScreenState extends State<WebScreen> {

  // Constants
  final String _initialUrl = "https://dev.ppl.do";
  // Vars
  WebViewController _controller;
  // Bloc
  ConnectivityBloc _connectivityBloc;

  @override
  void initState() {
    super.initState();
    _connectivityBloc = BlocProvider.of<ConnectivityBloc>(context);
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    _connectivityBloc.checkConnectionStatus();
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
        body: StreamBuilder<ConnectivityResult>(
            stream: _connectivityBloc.connectivityStream,
            builder: (ctx, snapshot) {
              final connectivityResult = snapshot.data;
              if (connectivityResult == ConnectivityResult.none) {
                return Stack(
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
                );
              } else {
                return WebView(
                  initialUrl: _initialUrl,
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController webViewController) {
                    _controller = webViewController;
                    },
                  gestureNavigationEnabled: true,
                );
              }
            }
        )
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    var canGoBack = await _controller.canGoBack();
    if(canGoBack) {
      _controller.goBack();
      return false;
    }
    return true;
  }
}
