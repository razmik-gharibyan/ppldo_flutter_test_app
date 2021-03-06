import 'dart:async';
import 'package:clipboard/clipboard.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:people_do/bloc/bloc_provider.dart';
import 'package:people_do/bloc/cloud_messaging_bloc.dart';
import 'package:people_do/bloc/connectivity_bloc.dart';
import 'package:people_do/bloc/deeplink_bloc.dart';
import 'package:people_do/bloc/js_communication_bloc.dart';
import 'package:people_do/helper/permission_helper.dart';
import 'package:people_do/screens/contacts_screen.dart';
import 'package:people_do/services/avatar_service.dart';
import 'package:people_do/services/cloud_messaging_service.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:people_do/globals.dart' as globals;

class WebScreen extends StatefulWidget {

  static const String routeName = "/web-screen";

  @override
  _WebScreenState createState() => _WebScreenState();
}

class _WebScreenState extends State<WebScreen> with WidgetsBindingObserver {

  // Tools and Services
  PermissionHelper _permissionHelper;
  InAppWebViewController _controller;
  InAppWebViewGroupOptions _options;
  CloudMessagingService _cloudMessagingService;
  ChromeSafariBrowser _chromeSafariBrowser;
  CookieManager _cookieManager;
  AvatarService _avatarService;
  // Bloc
  ConnectivityBloc _connectivityBloc;
  DeepLinkBloc _deepLinkBloc;
  JSCommunicationBloc _jsCommunicationBloc;
  CloudMessagingBloc _cloudMessagingBloc;
  // Vars
  PermissionStatus _contactsPermissionStatus;
  bool _permissionCheckedOnce = false;
  String _deviceToken;
  bool _isDeveloperMode = false;
  bool _isLoggedIn = false;
  var _mode = globals.applicationMode;

  @override
  void initState() {
    super.initState();
    // -- Init Bloc --
    _connectivityBloc = BlocProvider.of<ConnectivityBloc>(context);
    _deepLinkBloc = DeepLinkBloc();
    _jsCommunicationBloc = JSCommunicationBloc();
    _cloudMessagingBloc = CloudMessagingBloc();
    // -- Init tools --
    WidgetsBinding.instance.addObserver(this);
    _permissionHelper = PermissionHelper();
    _cloudMessagingService = CloudMessagingService();
    _chromeSafariBrowser = ChromeSafariBrowser();
    _cookieManager = CookieManager();
    _avatarService = AvatarService();
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
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        await _checkTokenFromCookies();
        break;
      case AppLifecycleState.resumed:
    }
  }

  @override
  void dispose() async {
    _cloudMessagingBloc.dispose();
    _deepLinkBloc.dispose();
    _jsCommunicationBloc.dispose();
    _chromeSafariBrowser.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _mediaQuery = MediaQuery.of(context);

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
                child: Stack(
                  children: [
                    StreamBuilder<bool>(
                      stream: _connectivityBloc.networkErrorStream,
                      builder: (c, errorSnapshot) {
                        if (!errorSnapshot.hasData || !errorSnapshot.data) {
                          return InAppWebView(
                            initialUrl: globals.initialUrl,
                            initialOptions: _options,
                            onWebViewCreated: (InAppWebViewController webViewController) {
                              if (_controller != null) {
                                _controller = webViewController;
                              } else {
                                _controller = webViewController;
                                _listenForEvents();
                                _checkTokenFromCookies();
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
                    ),
                    _isDeveloperMode ? _switchModeWidget(_mediaQuery) : Container(),
                  ],
                )
              );
            }
          ),
        ),
    );
  }
  
  void _listenForJSEvents() {
    _jsCommunicationBloc.cookieTimerStream.listen((bool event) {
      if (event) {
        _checkTokenFromCookies();
      }
    });
  }

  Future<void> _checkTokenFromCookies() async {
    try {
      final token = await _cookieManager.getCookie(url: globals.initialUrl, name: "token");
      if (token != null && token.value != null) {
        if (!_permissionCheckedOnce) {
          _permissionCheckedOnce = true;
          globals.userToken = token.value;
          globals.resizeBaseUrl = await _avatarService.getResizeBaseUrl();
          _deviceToken = await _cloudMessagingBloc.getDeviceToken();
          setState(() {
            _isLoggedIn = true;
          });
          if (_deviceToken != null && _deviceToken.isNotEmpty) {
            await _cloudMessagingService.postDeviceToken(token.value, _deviceToken);
          }
        }
      }
      if (token == null &&_deviceToken != null && _deviceToken.isNotEmpty) {
        await _cloudMessagingBloc.deleteDeviceToken();
        _deviceToken = null;
        _permissionCheckedOnce = false;
        setState(() {
          _isLoggedIn = false;
        });
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
  
  void _listenForAddContacts() {
    _controller.addJavaScriptHandler(handlerName: "syncContacts", callback: (arguments) async {
      if (arguments.isNotEmpty) {
        globals.language = arguments[0];
        // Change locale
        EasyLocalization.of(context).locale = Locale(globals.language);
      }
      _askOrGetContactPermissions();
      //await _controller.evaluateJavascript(source: "app.vms.modals.openInvite()");
    });
  }
  
  void _listenForAddPhoneNumber() {
    _jsCommunicationBloc.addContactStream.listen((String phoneNumber) async {
      if (phoneNumber.isEmpty) {
        await _controller.evaluateJavascript(source: "app.vms.modals.openInvite()");
      } else {
        await _controller.evaluateJavascript(source: "app.vms.modals.openInvite({phone: '$phoneNumber'})");
      }
    });
  }

  void _listenForPushNotifications() {
    _cloudMessagingBloc.cloudMessagingStream.listen((String routeUrl) {
      if (_controller != null) {
        _controller.loadUrl(url: routeUrl);
      }
    });
  }

  void _listenForSiteSwitch() {
    _controller.addJavaScriptHandler(handlerName: "switchSite", callback: (_) {
      setState(() {
        _isDeveloperMode = true;
      });
    });
  }

  void _askOrGetContactPermissions() async {
    _contactsPermissionStatus = await _permissionHelper.getPermissionStatus();
    if (_contactsPermissionStatus == PermissionStatus.granted) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ContactsScreen(_jsCommunicationBloc)),);
    } else {
      _jsCommunicationBloc.addContactNumber("");
    }
  }

  void _listenForEvents() {
    _listenForJSEvents();
    _listenForPushNotifications();
    _listenForClipboardCopy();
    _listenForAddContacts();
    _listenForAddPhoneNumber();
    _listenForSiteSwitch();
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

  /// This method takes [MediaQueryData] as input and returns dropdown button
  /// positioned at top-center for switching between site modes such as DEV/RC/PROD.
  /// This method will work only if user entered developer mode.
  Widget _switchModeWidget(MediaQueryData mediaQueryData) {
    return Positioned(
      top: 0,
      child: Container(
        width: mediaQueryData.size.width,
        child: Align(
          alignment: Alignment.center,
          child: _isLoggedIn
            ? Text(
                globals.applicationMode.toString().replaceAll("Mode.", ""),
                style: TextStyle(
                  color: Color(0xFF7CB342),
                  fontSize: 10.0,
                ),
               )
            : DropdownButton(
                dropdownColor: Colors.black,
                isDense: true,
                style: TextStyle(
                  color: Color(0xFF7CB342),
                  fontSize: 10.0,
                ),
                items: globals.Mode.values.map((globals.Mode value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value.toString().replaceAll("Mode.", "")),
                  );
                }).toList(),
                value: _mode,
                onChanged: (mode) {
                  setState(() {
                    _mode = mode;
                    globals.changeMode(mode);
                    _controller.loadUrl(url: globals.initialUrl);
                  });
                },
              ),
          ),
      ),
    );
  }

  Widget _errorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7CB342)),
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            tr("webview.errors.no_internet"),
            style: TextStyle(
              color: Color(0xFF272C3C),
              fontSize: 16,
              fontWeight: FontWeight.w500
            ),
          )
        ],
      ),
    );
  }

  /// Reacting when user press back button on Android,or swipes back on iOS
  /// return [true] to go pop screen or return [false] to not react
  Future<bool> _onBackPressed() async {
    var canGoBack = await _controller.canGoBack();
    if(canGoBack) {
      _controller.goBack();
      return false;
    }
    return true;
  }
}
