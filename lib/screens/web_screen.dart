import 'dart:async';
import 'dart:io';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ppldo_flutter_test_app/bloc/bloc_provider.dart';
import 'package:ppldo_flutter_test_app/bloc/cloud_messaging_bloc.dart';
import 'package:ppldo_flutter_test_app/bloc/connectivity_bloc.dart';
import 'package:ppldo_flutter_test_app/bloc/deeplink_bloc.dart';
import 'package:ppldo_flutter_test_app/bloc/js_communication_bloc.dart';
import 'package:ppldo_flutter_test_app/helper/permission_helper.dart';
import 'package:ppldo_flutter_test_app/services/cloud_messaging_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ppldo_flutter_test_app/globals.dart' as globals;

class WebScreen extends StatefulWidget {

  static const String routeName = "/web-screen";

  @override
  _WebScreenState createState() => _WebScreenState();
}

class _WebScreenState extends State<WebScreen> {

  // Constants
  final String _initialUrl = globals.initialUrlDevChannel;
  // Tools and Services
  PermissionHelper _permissionHelper;
  InAppWebViewController _controller;
  InAppWebViewGroupOptions _options;
  CloudMessagingService _cloudMessagingService;
  ChromeSafariBrowser _chromeSafariBrowser;
  // Bloc
  ConnectivityBloc _connectivityBloc;
  DeepLinkBloc _deepLinkBloc;
  JSCommunicationBloc _jsCommunicationBloc;
  CloudMessagingBloc _cloudMessagingBloc;
  // Vars
  PermissionStatus _contactsPermissionStatus;
  bool _permissionCheckedOnce = false;
  String _deviceToken;

  @override
  void initState() {
    super.initState();
    // -- Init Bloc --
    _connectivityBloc = BlocProvider.of<ConnectivityBloc>(context);
    _deepLinkBloc = DeepLinkBloc();
    _jsCommunicationBloc = JSCommunicationBloc();
    _cloudMessagingBloc = CloudMessagingBloc();
    // -- Init tools --
    _permissionHelper = PermissionHelper();
    _cloudMessagingService = CloudMessagingService();
    _chromeSafariBrowser = ChromeSafariBrowser();
    _options = InAppWebViewGroupOptions();
    _options.crossPlatform.useShouldOverrideUrlLoading = true;
    _options.android.hardwareAcceleration = true;
    _options.crossPlatform.disableContextMenu = false;
    _options.android.overScrollMode = AndroidOverScrollMode.OVER_SCROLL_ALWAYS;
    _options.android.useHybridComposition = true;
    // -- Init operations --
    _deepLinkBloc.initUniLinks();
    _cloudMessagingBloc.initCloudMessaging();
    // -- Listen for changes --
    _connectivityBloc.checkConnectionStatus();
    _jsCommunicationBloc.startSession();
  }

  @override
  void dispose() {
    _cloudMessagingBloc.dispose();
    _deepLinkBloc.dispose();
    _jsCommunicationBloc.dispose();
    _chromeSafariBrowser.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: StreamBuilder<String>(
          stream: _deepLinkBloc.deepLinkStream,
          builder: (ct, deepLinkSnapshot) {
            if (!deepLinkSnapshot.hasData) {
              print("No deeplink snapshot");
            } else {
              _controller.loadUrl(url: deepLinkSnapshot.data);
            }
            return SafeArea(
              child: StreamBuilder<bool>(
                stream: _connectivityBloc.networkErrorStream,
                builder: (c, errorSnapshot) {
                  if (!errorSnapshot.hasData || !errorSnapshot.data) {
                    return InAppWebView(
                      initialUrl: _initialUrl,
                      initialOptions: _options,
                      onWebViewCreated: (InAppWebViewController webViewController) {
                        if (_controller != null) {
                          _controller = webViewController;
                        } else {
                          _controller = webViewController;
                          _listenForEvents();
                          _getCookies();
                        }
                      },
                      gestureRecognizers: [Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer())].toSet(),
                      shouldOverrideUrlLoading: (controller, request) async {
                        return await _handleUrlRequests(request);
                      },
                      onLoadError: (controller, url, code, message) {
                        _loadErrorWidget(message);
                      },
                    );
                  } else {
                    return _errorWidget();
                  }
                },
              )
            );
          }
        ),
      )
    );
  }
  
  void _listenForJSEvents() {
    _jsCommunicationBloc.cookieTimerStream.listen((bool event) {
      if (event) {
        _getCookies();
      }
    });
  }

  void _getCookies() async {
    try {
      final String cookie = await _controller.evaluateJavascript(source: "document.cookie");
      if (cookie != null && cookie.isNotEmpty && cookie != "null" && cookie != "\"\"") {
        final token = _getTokenFromCookies(cookie);
        if (token != null && token.isNotEmpty) {
          if (!_permissionCheckedOnce) {
            //_getPermissions();
            _permissionCheckedOnce = true;
            _deviceToken = await _cloudMessagingBloc.getDeviceToken();
            if (_deviceToken != null && _deviceToken.isNotEmpty) {
              await _cloudMessagingService.postDeviceToken(token, _deviceToken);
            }
          }
        }
      }
      if (cookie != null && cookie.isEmpty && _deviceToken != null && _deviceToken.isNotEmpty) {
        await _cloudMessagingBloc.deleteDeviceToken();
        _deviceToken = null;
        _permissionCheckedOnce = false;
      }
    } catch (e) {
      print(e);
    }
  }

  void _listenForClipboardCopy() {
    _controller.addJavaScriptHandler(handlerName: "copyText", callback: (text) {
      final String clipboardText = text[0];
      print(clipboardText);
      FlutterClipboard.copy(clipboardText);
    });
  }

  String _getTokenFromCookies(String cookie) {
    const tokenSearchText = "token=";
    final tokenStartIndex = cookie.lastIndexOf(tokenSearchText);
    final tokenEndIndex = tokenStartIndex + tokenSearchText.length;
    return cookie.substring(tokenEndIndex).replaceAll("\"", "");
  }

  void _listenForPushNotifications() {
    _cloudMessagingBloc.cloudMessagingStream.listen((String routeUrl) {
      if (_controller != null) {
        _controller.loadUrl(url: routeUrl);
      }
    });
  }

  void _listenForEvents() {
    _listenForJSEvents();
    _listenForPushNotifications();
    _listenForClipboardCopy();
  }

  Future<ShouldOverrideUrlLoadingAction> _handleUrlRequests(ShouldOverrideUrlLoadingRequest request) async {
    /*
    if (request.url.endsWith(".pdf")) {
      _controller.loadUrl("https://docs.google.com/gview?embedded=true&url=${request.url}");
      return NavigationDecision.prevent;
    }
     */
    if (request.url.startsWith("https://dev.ppl.do") || request.url.startsWith("https://ppldo.net")) {
      return ShouldOverrideUrlLoadingAction.ALLOW;
    }
    if (await launch(request.url, universalLinksOnly: true)) {
      return ShouldOverrideUrlLoadingAction.CANCEL;
    } else {
      _chromeSafariBrowser.open(url: request.url,options: ChromeSafariBrowserClassOptions(
          android: AndroidChromeCustomTabsOptions(addDefaultShareMenuItem: false),
          ios: IOSSafariOptions(barCollapsingEnabled: true))
      );
      return ShouldOverrideUrlLoadingAction.CANCEL;
    }
  }

  _loadErrorWidget(String message) {
    if (message != null) {
      if (message == "net::ERR_INTERNET_DISCONNECTED") {
        _connectivityBloc.setIsNetworkError(true);
      }
    }
  }

  Widget _errorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Platform.isAndroid ? CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ) : CupertinoActivityIndicator(),
          SizedBox(
            height: 10.0,
          ),
          Text(
            "No connection available..."
          )
        ],
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
