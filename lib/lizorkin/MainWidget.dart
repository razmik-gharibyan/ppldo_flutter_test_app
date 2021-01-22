import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:people_do/lizorkin/GlobalVariables.dart';
import 'package:people_do/lizorkin/LocalSettings.dart';
import 'package:people_do/lizorkin/LoginWindow.dart';
//import 'package:people_do/widgets/old/FlowWidget.dart';

import 'PPDNetwork/PPDNetwork.dart';

class PageData {
  final IconData icon;
  final String titleText;

  PageData(this.icon, this.titleText);
}

class MainWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  List<PageData> _pages;

  @override
  Widget build(BuildContext context) {
    _pages = [
      PageData(PlatformIcons(context).conversationBubble, "Поток"),
      PageData(PlatformIcons(context).book, "Задачи"),
      PageData(Icons.add_alert, "Напоминания"),
      PageData(PlatformIcons(context).group, "Контакты"),
      PageData(PlatformIcons(context).settings, "Профиль"),
    ];
    return PlatformTabScaffold(
      android: (context) => MaterialTabScaffoldData(
        controller: MaterialTabController(),
      ),
      androidTabs: (context) => MaterialNavBarData(
        selectedItemColor: GlobalVariables.accentColor,
        unselectedItemColor: GlobalVariables.inactiveColor,
      ),
      appBarBuilder: (context, pageNum) {
        return PlatformAppBar(
            backgroundColor: GlobalVariables.accentColor,
            android: (context){
              return MaterialAppBarData(
                brightness: Brightness.dark
              );
            },
            leading: Icon(
              _pages[pageNum].icon,
              color: Colors.white,
            ),
            title: Text(
              _pages[pageNum].titleText,
              style: TextStyle(color: Colors.white),
            ));
      },
      items: getBottomItems(context),
      bodyBuilder: (context, pageNum) {
        Widget widget =ProfileWidget();
        /*
        if(pageNum < 4){
          widget = FlowWidget(mainIndex: pageNum+1,);
        }

         */
        return GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: widget,
        );
      },
    );
  }

  List<BottomNavigationBarItem> getBottomItems(BuildContext context) {
    List<BottomNavigationBarItem> ret = List<BottomNavigationBarItem>();
    _pages.forEach((pageData) {
      ret.add(BottomNavigationBarItem(
        icon: Icon(pageData.icon),
        title: isMaterial(context) ? Text(pageData.titleText) : null,
      ));
    });
    return ret;
  }

  @override
  void initState() {
    super.initState();
  }
}

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
//            shrinkWrap: true,
        children: <Widget>[
          Text(
            "В производстве",
            textAlign: TextAlign.center,
            style:
                TextStyle(fontSize: 30, color: GlobalVariables.errorCode),
          ),
          Text(LocalSettings().user.firstName),
          SizedBox(
            height: 30,
          ),
          PlatformButton(
            child: Text("Выйти"),
            androidFlat: (_) => MaterialFlatButtonData(),
            onPressed: () {
              settings.token.value = "";
              Navigator.of(context).pushReplacement(
                  platformPageRoute(context: context, builder: (_) {
                    return LoginWidget();
                  }
                  )
              );
            },
          ),
          Text(
            "Выход не подразумевает действий на сервере, а просто обнуляет текущий токен и переводит на страницу входа.",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
