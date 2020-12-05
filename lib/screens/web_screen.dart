import 'dart:async';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ppldo_flutter_test_app/bloc/bloc_provider.dart';
import 'package:ppldo_flutter_test_app/bloc/cloud_messaging_bloc.dart';
import 'package:ppldo_flutter_test_app/bloc/connectivity_bloc.dart';
import 'package:ppldo_flutter_test_app/bloc/contacts_bloc.dart';
import 'package:ppldo_flutter_test_app/bloc/deeplink_bloc.dart';
import 'package:ppldo_flutter_test_app/bloc/js_communication_bloc.dart';
import 'package:ppldo_flutter_test_app/helper/permission_helper.dart';
import 'package:ppldo_flutter_test_app/services/cloud_messaging_service.dart';
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
  // Bloc
  ConnectivityBloc _connectivityBloc;
  DeepLinkBloc _deepLinkBloc;
  JSCommunicationBloc _jsCommunicationBloc;
  CloudMessagingBloc _cloudMessagingBloc;
  ContactsBloc _contactsBloc;
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
    _contactsBloc = ContactsBloc();
    // -- Init tools --
    _permissionHelper = PermissionHelper();
    _cloudMessagingService = CloudMessagingService();
    _options = InAppWebViewGroupOptions();
    _options.crossPlatform.useShouldOverrideUrlLoading = true;
    // -- Init operations --
    _deepLinkBloc.initUniLinks();
    _cloudMessagingBloc.initCloudMessaging();
    // -- Listen for changes --
    //_connectivityBloc.checkConnectionStatus();
    _jsCommunicationBloc.startSession();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _deviceToken = await _cloudMessagingBloc.getDeviceToken();
  }

  @override
  void dispose() {
    _cloudMessagingBloc.dispose();
    _deepLinkBloc.dispose();
    _contactsBloc.dispose();
    _jsCommunicationBloc.dispose();
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
              child: InAppWebView(
                initialUrl: _initialUrl,
                initialOptions: _options,
                onWebViewCreated: (InAppWebViewController webViewController) {
                  _controller = webViewController;
                  _listenForEvents();
                  _getCookies();
                },
                shouldOverrideUrlLoading: (controller, request) async {
                  return await _handleUrlRequests(request);
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
    final String cookie = await _controller.evaluateJavascript(source: "document.cookie");
    if (cookie != null && cookie.isNotEmpty && cookie != "null" && cookie != "\"\"") {
      final token = _getTokenFromCookies(cookie);
      if (token != null && token.isNotEmpty) {
        if (!_permissionCheckedOnce) {
          //_getPermissions();
          _permissionCheckedOnce = true;
          if (_deviceToken != null && _deviceToken.isNotEmpty) {
            await _cloudMessagingService.postDeviceToken(token, _deviceToken);
          }
        }
      }
    }
  }

  String _getTokenFromCookies(String cookie) {
    const tokenSearchText = "token=";
    final tokenStartIndex = cookie.lastIndexOf(tokenSearchText);
    final tokenEndIndex = tokenStartIndex + tokenSearchText.length;
    return cookie.substring(tokenEndIndex).replaceAll("\"", "");
  }

  void _getPermissions() async {
    _contactsPermissionStatus = await _permissionHelper.getPermissionStatus();
    if (_contactsPermissionStatus == PermissionStatus.granted) {
      _contactsBloc.startContactsSession();
    }
  }

  void _listenForPushNotifications() {
    _cloudMessagingBloc.cloudMessagingStream.listen((String routeUrl) {
      if (_controller != null) {
        _controller.loadUrl(url: routeUrl);
      }
    });
  }

  void _listenForContacts() {
    _contactsBloc.contactsStream.listen((List<Contact> contacts) {

    });
  }

  void _listenForEvents() {
    _listenForJSEvents();
    _listenForPushNotifications();
    _listenForContacts();
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
      _controller.loadUrl(url: request.url); //TODO открыть custom tab
      return ShouldOverrideUrlLoadingAction.ALLOW;
    }
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
