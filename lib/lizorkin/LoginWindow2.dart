import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:people_do/lizorkin/MainWidget.dart';
import 'package:people_do/lizorkin/PPDNetwork/MutationBloc.dart';
import 'package:people_do/lizorkin/PPDNetwork/Parsers.dart';
import 'package:people_do/lizorkin/PPDNetwork/QueryBloc.dart';
import 'package:people_do/lizorkin/graphql/OtpToToken.data.gql.dart';
import 'package:people_do/lizorkin/widgets/InitErrorScreen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'GlobalVariables.dart';
import 'LocalSettings.dart';
import 'LoginWindow.dart';
import 'PPDNetwork/PPDNetwork.dart';
import 'graphql/MakeOTP.data.gql.dart';
import 'graphql/OtpToToken.ast.gql.dart' as otpDoc;
import 'package:people_do/lizorkin/graphql/loadme.query.ast.gql.dart' as loadMe;

import 'graphql/loadme.query.data.gql.dart';

class SmsCodeDialog extends StatelessWidget {
  final String phone;
  final $MakeOTP data;
  final ValueNotifier<String> _error = ValueNotifier<String>("");
  final ValueNotifier<bool> _checking = ValueNotifier<bool>(false);

  SmsCodeDialog({Key key, this.phone, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _loadMeQuery = QueryBloc(documentNode: loadMe.document);
    _loadMeQuery.resultStream.listen((result) {
      if(result == null){
        return;
      }
      LocalSettings().user = UserProfileParser.myProfile($loadMe(result.data).result);
      Navigator.of(context).pushReplacement(
          platformPageRoute(context: context, builder: (_) {
            return MainWidget();
          }
          )
      );

    }, onError: (error){
      Widget route;
      if (error is OperationException) {
        var _error = ProcessedException(error);
        if (_error.isAuthorizedException) {
          route = LoginWidget();
        }
        else{
          route = InitErrorScreen(errorString: _error.userMessage);
        }
      }
      else {
        route = InitErrorScreen(errorString: 'Неизвестная ошибка');
      }
      Navigator.of(context).pushReplacement(
          platformPageRoute(context: context, builder: (_) {
            return route;
          }
          )
      );
    });
    var _mutationBloc = MutationBloc(documentNode: otpDoc.document, authorized: false);
    _mutationBloc.resultStream.listen((result) {
      if(result == null){
        return;
      }
      var converted = $OtpToToken(result.data).otpToToken.token;
      LocalSettings().token.value = converted.token;
      LocalSettings().expiration.value = converted.expiration;
      LocalSettings().expirationDate.value = DateTime.tryParse(converted.expiration_date.value);

      _loadMeQuery.run().then((_){
        _checking.value = false;
      });
    }, onError: (error){
      if(error is OperationException && error.graphqlErrors.length>0){
        _error.value = error.graphqlErrors[0].message;
      }
      else{
        _error.value = 'Неизвестная ошибка';
      }
    });
    return Material(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(30.0),
          child: Center(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                TextualLogo(),
                SizedBox(
                  height: 30,
                ),
                Text(
                  'Введите код из смс',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(
                  height: 40,
                ),
            PinCodeTextField(
              appContext: context,
              length: 4,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                shape: isMaterial(context)
                    ? PinCodeFieldShape.box
                    : PinCodeFieldShape.underline,
                borderRadius: isMaterial(context)
                  ? BorderRadius.circular(5)
                  : null,
                fieldHeight: 50,
                fieldWidth: 40,
                activeColor: _error.value.length>0
                    ? GlobalVariables.errorCode
                    : GlobalVariables.accentColor,
                inactiveColor: GlobalVariables.inactiveColor,
              ),

              animationDuration: Duration(milliseconds: 300),
              backgroundColor: Colors.transparent,

              enabled: !_checking.value,

              onChanged: (_){_error.value = '';},
              onCompleted: (v) {
                _mutationBloc.variables ={
                  'login': data.makeOTP.oneTimeLogin,
                  "password": v
                };
                _mutationBloc.run();
              },
              keyboardType: TextInputType.number,
            ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  'Код выслан на $phone',
                  textAlign: TextAlign.center,
                ),
                PlatformButton(
                  child: Text(
                    "Получить новый код",
                    style: TextStyle(color: GlobalVariables.accentColor),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  materialFlat: (_, __) => MaterialFlatButtonData(),
                ),
                PlatformButton(
                  child: Text(
                    "Ввести другой номер",
                    style: TextStyle(color: GlobalVariables.accentColor),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  materialFlat: (_, __) => MaterialFlatButtonData(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class TextTimer extends StatefulWidget {
  final Duration duration;
  final Function() onFinished;

  TextTimer({this.duration, this.onFinished});

  @override
  State<StatefulWidget> createState() => _TextTimerState();
}

class _TextTimerState extends State<TextTimer> {
  int _secondsLeft;

  _TextTimerState();

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.duration == null ? 0 : widget.duration.inSeconds;
    if (_secondsLeft <= 0) {
      _secondsLeft = 0;
      widget.onFinished();
    } else {
      Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _secondsLeft--;
          if (_secondsLeft < 0) {
            _secondsLeft = 0;
          }
        });
        if (_secondsLeft <= 0) {
          timer.cancel();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DateFormat format =
        _secondsLeft > 3600 ? DateFormat("HH:mm:ss") : DateFormat("mm:ss");
    String text =
        format.format(DateTime.fromMillisecondsSinceEpoch(_secondsLeft * 1000));
    return Text(
      text,
    );
  }
}
