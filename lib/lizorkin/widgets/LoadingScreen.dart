import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:people_do/lizorkin/GlobalVariables.dart';
import 'package:people_do/lizorkin/LocalSettings.dart';
import 'package:people_do/lizorkin/LoginWindow.dart';
import 'package:people_do/lizorkin/MainWidget.dart';
import 'package:people_do/lizorkin/PPDNetwork/Parsers.dart';
import 'package:people_do/lizorkin/PPDNetwork/QueryBloc.dart';
import 'package:people_do/lizorkin/PPDNetwork/PPDNetwork.dart';
import 'package:people_do/lizorkin/graphql/loadme.query.ast.gql.dart' as loadMe;
import 'package:people_do/lizorkin/graphql/getSettings.ast.gql.dart' as getSettings;
import 'package:people_do/lizorkin/graphql/loadme.query.data.gql.dart';
//import 'package:people_do/graphql/schema.schema.gql.dart';
//import 'package:people_do/widgets/old/FlowWidget.dart';
import 'package:people_do/lizorkin/widgets/InitErrorScreen.dart';

class LoadingScreen extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    var horizontalPadding = 50.0;
    return PlatformScaffold(
      body: SizedBox.expand(
        child: Container(
          color: Color(0xff7DB343),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                Expanded(
                  flex: 30,
                  child: Align(
                      child: TextualLogo(white: true, long: false,),
                    alignment: Alignment.centerLeft,
                  ),
                ),
                Expanded(
                  flex: 13,
                  child: AutoSizeText(
                    'Желаем продуктивного дня',
                    maxLines: 3,
                    style: TextStyle(color: Colors.white, fontSize: 100, fontWeight: FontWeight.bold),
                    wrapWords: false,
                  ),
                ),
                SizedBox(height: 40,),
                Expanded(
                  flex: 7,
                  child: AutoSizeText(
                      'Обновление данных. Это займет некоторое время.',
                    maxLines: 2,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Expanded(
                  flex: 13,
                  child: Center(
                      child: LoaderWithProgress()
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

class LoaderWithProgress extends StatefulWidget {
  const LoaderWithProgress({
    Key key,
  }) : super(key: key);

  @override
  _LoaderWithProgressState createState() => _LoaderWithProgressState();
}

class _LoaderWithProgressState extends State<LoaderWithProgress> {

  double _value = 0.0;

  QueryBloc _loadMeQuery;
  QueryBloc _loadSettings;

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      backgroundColor: Color(0x42000000),
      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      value: _value,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadMeQuery = QueryBloc(documentNode: loadMe.document);
    _loadSettings = QueryBloc(documentNode: getSettings.document, authorized: false);
    _loadSettings.run().then((value){
      setState(() {
        _value = 0.5;
      });
    });
    _loadSettings.resultStream.listen((result) {
      if(result == null){
        return;
      }

      _loadMeQuery.run().then((value){
        setState(() {
          _value = 1.0;
        });
      });

    }, onError: (error){
      Navigator.of(context).pushReplacement(
          platformPageRoute(context: context, builder: (_) {
            return InitErrorScreen(errorString: 'Не могу подключиться к серверу ${GlobalVariables.httpUrl}',);
          }
          )
      );
    });

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
  }

}