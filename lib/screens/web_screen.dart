import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ppldo_flutter_test_app/bloc/bloc_provider.dart';
import 'package:ppldo_flutter_test_app/bloc/cloud_messaging_bloc.dart';
import 'package:ppldo_flutter_test_app/bloc/connectivity_bloc.dart';
import 'package:ppldo_flutter_test_app/bloc/contacts_bloc.dart';
import 'package:ppldo_flutter_test_app/bloc/deeplink_bloc.dart';
import 'package:ppldo_flutter_test_app/bloc/js_communication_bloc.dart';
import 'package:ppldo_flutter_test_app/helper/permission_helper.dart';
import 'package:ppldo_flutter_test_app/presentation/custom_inapp_browser.dart';
import 'package:ppldo_flutter_test_app/services/cloud_messaging_service.dart';

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
  CloudMessagingService _cloudMessagingService;
  ChromeSafariBrowser _chromeSafariBrowser;
  CustomInAppBrowser _inAppBrowser;
  // Bloc
  ConnectivityBloc _connectivityBloc;
  DeepLinkBloc _deepLinkBloc;
  JSCommunicationBloc _jsCommunicationBloc;
  CloudMessagingBloc _cloudMessagingBloc;
  ContactsBloc _contactsBloc;

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
    _chromeSafariBrowser = ChromeSafariBrowser();
    _inAppBrowser = CustomInAppBrowser(
      chromeSafariBrowser: _chromeSafariBrowser,
      cloudMessagingBloc: _cloudMessagingBloc,
      cloudMessagingService: _cloudMessagingService,
      connectivityBloc: _connectivityBloc,
      jsCommunicationBloc: _jsCommunicationBloc,
      contactsBloc: _contactsBloc,
      permissionHelper: _permissionHelper,
    );
    // -- Init operations --
    _deepLinkBloc.initUniLinks();
    _inAppBrowser.init();
  }

  @override
  void dispose() {
    _cloudMessagingBloc.dispose();
    _deepLinkBloc.dispose();
    _contactsBloc.dispose();
    _jsCommunicationBloc.dispose();
    _chromeSafariBrowser.close();
    //_inAppBrowser.close();
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
              _inAppBrowser.webViewController.loadUrl(url: deepLinkSnapshot.data);
            }
            return SafeArea(
              child: StreamBuilder<bool>(
                stream: _connectivityBloc.networkErrorStream,
                builder: (c, errorSnapshot) {
                  print("SNAPSHOT IS $errorSnapshot");
                  if (!errorSnapshot.hasData || !errorSnapshot.data) {
                    return _openInAppBrowser();
                  } else {
                    _inAppBrowser.close();
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

  Widget _openInAppBrowser() {
    if (!_inAppBrowser.isOpened()) {
      _inAppBrowser.openUrl(
          url: _initialUrl,
          options: InAppBrowserClassOptions(
              crossPlatform: InAppBrowserOptions(
                toolbarTop: false,
                hideUrlBar: false,
              ),
              android: AndroidInAppBrowserOptions(
                  progressBar: false,
                  hideTitleBar: false,
                  closeOnCannotGoBack: false
              ),
              inAppWebViewGroupOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    useShouldOverrideUrlLoading: true,
                    disableContextMenu: false,
                    javaScriptEnabled: true,
                  ),
                  android: AndroidInAppWebViewOptions(
                    hardwareAcceleration: true,
                  )
              )
          )
      );
    }
    return Container();
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
    if (_inAppBrowser.isOpened()) {
      var canGoBack = await _inAppBrowser.webViewController.canGoBack();
      if(canGoBack) {
        _inAppBrowser.webViewController.goBack();
        return false;
      } else {
        await _inAppBrowser.close();
      }
    }
    return true;
  }

}
