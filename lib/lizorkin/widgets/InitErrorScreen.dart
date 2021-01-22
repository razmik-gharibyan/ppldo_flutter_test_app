import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:people_do/lizorkin/GlobalVariables.dart';
import 'package:people_do/lizorkin/widgets/LoadingScreen.dart';

class InitErrorScreen extends StatelessWidget{

  final String errorString;

  const InitErrorScreen({Key key, this.errorString}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      body: SizedBox.expand(
        child: Container(
          color: Color(0xff7DB343),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 50.0),
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Center(
                    child: TextualLogo(white: true, long: false,),
                  ),
                )    ,
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AutoSizeText('Ошибка при подключении к серверу:', style: TextStyle(color: Colors.white, fontSize: 20), maxLines: 1,),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AutoSizeText(errorString, style: TextStyle(color: Colors.white, fontSize: 20), maxLines: 3,),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: PlatformButton(
                      child: Text("Повторить"),
                      onPressed: () {Navigator.of(context).pushReplacement(
                          platformPageRoute(context: context, builder: (_) {
                            return LoadingScreen();
                          }
                          )
                      );}
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}