import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ppldo_flutter_test_app/bloc/cloud_messaging_bloc.dart';
import 'package:ppldo_flutter_test_app/bloc/connectivity_bloc.dart';
import 'package:ppldo_flutter_test_app/bloc/contacts_bloc.dart';
import 'package:ppldo_flutter_test_app/bloc/js_communication_bloc.dart';
import 'package:ppldo_flutter_test_app/helper/permission_helper.dart';
import 'package:ppldo_flutter_test_app/services/cloud_messaging_service.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomInAppBrowser extends InAppBrowser {

  final CloudMessagingService cloudMessagingService;
  final ChromeSafariBrowser chromeSafariBrowser;
  final ConnectivityBloc connectivityBloc;
  final JSCommunicationBloc jsCommunicationBloc;
  final CloudMessagingBloc cloudMessagingBloc;
  final ContactsBloc contactsBloc;
  final PermissionHelper permissionHelper;

  CustomInAppBrowser({this.cloudMessagingService,
    this.chromeSafariBrowser,
    this.connectivityBloc,
    this.jsCommunicationBloc,
    this.cloudMessagingBloc,
    this.contactsBloc,
    this.permissionHelper,
  });

  // Vars
  PermissionStatus _contactsPermissionStatus;
  bool _permissionCheckedOnce = false;
  String _deviceToken;

  void init() async {
    // -- Init Tools --
    cloudMessagingBloc.initCloudMessaging();
    // -- Listen for changes --
    connectivityBloc.checkConnectionStatus();
    jsCommunicationBloc.startSession();
    _listenForEvents();
    _getCookies();
  }

  @override
  Future<ShouldOverrideUrlLoadingAction> shouldOverrideUrlLoading(ShouldOverrideUrlLoadingRequest request) async {
    /*
    if (request.url.endsWith(".pdf")) {
      _controller.loadUrl("https://docs.google.com/gview?embedded=true&url=${request.url}");
      return NavigationDecision.prevent;
    }
     */
    return await _handleUrlRequests(request);
  }

  @override
  void onLoadError(String url, int code, String message) {
    _loadErrorWidget(message);
    super.onLoadError(url, code, message);
  }

  @override
  void onExit() {
    jsCommunicationBloc.dispose();
    contactsBloc.dispose();
    super.onExit();
  }



  void _listenForJSEvents() {
    jsCommunicationBloc.cookieTimerStream.listen((bool event) {
      if (event) {
        _getCookies();
      }
    });
  }

  void _getCookies() async {
    try {
      final String cookie = await this.webViewController.evaluateJavascript(source: "document.cookie");
      if (cookie != null && cookie.isNotEmpty && cookie != "null" && cookie != "\"\"") {
        final token = _getTokenFromCookies(cookie);
        if (token != null && token.isNotEmpty) {
          if (!_permissionCheckedOnce) {
            //_getPermissions();
            _permissionCheckedOnce = true;
            _deviceToken = await cloudMessagingBloc.getDeviceToken();
            if (_deviceToken != null && _deviceToken.isNotEmpty) {
              await cloudMessagingService.postDeviceToken(token, _deviceToken);
            }
          }
        }
      }
      if (cookie.isEmpty && _deviceToken != null && _deviceToken.isNotEmpty) {
        await cloudMessagingBloc.deleteDeviceToken();
        _deviceToken = null;
      }
    } catch (e) {
      print(e);
    }
  }

  String _getTokenFromCookies(String cookie) {
    const tokenSearchText = "token=";
    final tokenStartIndex = cookie.lastIndexOf(tokenSearchText);
    final tokenEndIndex = tokenStartIndex + tokenSearchText.length;
    return cookie.substring(tokenEndIndex).replaceAll("\"", "");
  }

  void _getPermissions() async {
    _contactsPermissionStatus = await permissionHelper.getPermissionStatus();
    if (_contactsPermissionStatus == PermissionStatus.granted) {
      contactsBloc.startContactsSession();
    }
  }

  void _listenForPushNotifications() {
    cloudMessagingBloc.cloudMessagingStream.listen((String routeUrl) {
      if (this.webViewController != null) {
        this.webViewController.loadUrl(url: routeUrl);
      }
    });
  }

  void _listenForContacts() {
    contactsBloc.contactsStream.listen((List<Contact> contacts) {

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
      chromeSafariBrowser.open(url: request.url,options: ChromeSafariBrowserClassOptions(
          android: AndroidChromeCustomTabsOptions(addDefaultShareMenuItem: false),
          ios: IOSSafariOptions(barCollapsingEnabled: true))
      );
      return ShouldOverrideUrlLoadingAction.CANCEL;
    }
  }

  _loadErrorWidget(String message) {
    if (message != null) {
      if (message == "net::ERR_INTERNET_DISCONNECTED") {
        connectivityBloc.setIsNetworkError(true);
      }
    }
  }

}