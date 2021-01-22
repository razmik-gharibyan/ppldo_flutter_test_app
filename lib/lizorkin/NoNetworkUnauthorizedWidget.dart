import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class NoNetworkUnauthorizedWidget extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Сервер PeopleDo недоступен. Проверьте поключение и повторите попытку.', textAlign: TextAlign.center,),
            PlatformButton(
              child: Text('Повторить'),
              onPressed: (){
                //NetworkInterface().init("https://api-rc.ppl.do/graphql", NetworkInterface().preferences);
              },
            )
          ],
        ),
      ),
    );
  }

}