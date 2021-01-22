import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:people_do/lizorkin/LoginWindow2.dart';
import 'package:people_do/lizorkin/PPDNetwork/MutationBloc.dart';
import 'package:people_do/lizorkin/components/ButtonWithError.dart';
import 'package:people_do/lizorkin/graphql/MakeOTP.data.gql.dart';
import 'PPDSharedWidgets.dart';
import 'package:people_do/lizorkin/graphql/MakeOTP.ast.gql.dart';

class LoginWidget extends StatelessWidget {

  final ValueNotifier<String> _phone = ValueNotifier<String>("");
  final ValueNotifier<String> _error = ValueNotifier<String>("");
  final ValueNotifier<bool> _buttonEnabled = ValueNotifier<bool>(false);


  @override
  Widget build(BuildContext context) {
    var sendPhone = MutationBloc(documentNode: document, authorized: false);
    sendPhone.resultStream.listen((result) {
      if(result == null){
        return;
      }
      var converted = $MakeOTP(result.data);
      Navigator.of(context).push(
          platformPageRoute(context: context, builder: (_) {
            return SmsCodeDialog(data: converted, phone: _phone.value,);
          }
          )
      );

    }, onError: (error){
      _buttonEnabled.value = true;
      if(error is OperationException && error.graphqlErrors.length>0){
        _error.value = error.graphqlErrors[0].message;
      }
      else{
        _error.value = 'Неизвестная ошибка';
      }
    });
    return PlatformScaffold(
      iosContentPadding: true,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: ListView(
              physics: const ClampingScrollPhysics(),
              shrinkWrap: true,
              children: <Widget>[
//                TextualLogo(),
//                SizedBox(
//                  height: 20,
//                ),
                Text('Телефон',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 15,
                ),
                Text(
                  'Введите номер телефона.\nМы отправим SMS с кодом активации на указанный номер.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 40,
                ),
                PPDLabeledInput(
                  labelText: "Номер телефона",
                  inputType: TextInputType.phone,
                  inputFormatters: [
                    MaskTextInputFormatter(
                        mask: '+# (###) ###-##-##',
                        filter: {"#": RegExp(r'[0-9]')})
                  ],
                  onChanged: (val) {
                    _error.value = '';
                    String realPhone = val.replaceAll(new RegExp(r'[\+\(\) -]'), '');
                    _phone.value = realPhone;
                    if(_phone.value.length==11){
                      _buttonEnabled.value=true;
                    }
                    else{
                      _buttonEnabled.value = false;
                    }
                  },
                ),
                SizedBox(
                  height: 30,
                ),
            ButtonWithError(
                      enabled: _buttonEnabled,
                      errorText: _error,
                      buttonText: ValueNotifier<String>("Войти"),
                      action: (){
                        _buttonEnabled.value = false;
                        sendPhone.variables = {"phone": _phone.value};
                        sendPhone.run().then((value){_buttonEnabled.value = true;});
                      },
            )

//                fgql.Mutation(
//                  options: fgql.MutationOptions(
//                      documentNode: DocumentNode(
//                        definitions: [MakeOTP],
//                      ),
//                      variables: {
//                        "phone": _phone.value
//                      },
//                  ),
//                  builder: (fgql.RunMutation runMutation,
//                      fgql.QueryResult result,) {
//                    if(result.loading){
//                      return Center(child: PlatformCircularProgressIndicator());
//                    }
//                    if(result.hasException){
//                      _error.value = result.exception.graphqlErrors.length>0?
//                      result.exception.graphqlErrors[0].message :
//                      result.exception.clientException.message;
//                      _buttonEnabled.value = false;
//                    }
//                    else if (result.data != null) {
//                      final res = $MakeOTP(result.data);
//                      if ((res?.makeOTP?.oneTimeLogin ?? "").isNotEmpty) {
//                        Navigator.of(context).push(
//                            platformPageRoute(context: context, builder: (_) {
//                              return SmsCodeDialog(
//                                phone: _phone.value,
//                                data: res.makeOTP,
//                              );
//                            }
//                            )
//                        );
//                      }
//                      return Center(child: PlatformCircularProgressIndicator());
//                    }
//                    return ButtonWithError(
//                      enabled: _buttonEnabled,
//                      errorText: _error,
//                      buttonText: ValueNotifier<String>("Войти"),
//                      action: () => runMutation(
//                          {"phone": _phone.value}
//                      ),
//                    );
//                  },
//                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

