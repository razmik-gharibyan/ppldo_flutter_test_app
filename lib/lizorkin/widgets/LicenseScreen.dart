import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:people_do/lizorkin/GlobalVariables.dart';
import 'package:people_do/lizorkin/LoginWindow.dart';

class LicenseScreen extends StatelessWidget {
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
                  flex: 40,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30.0),
                    child: Align(
                      child: TextualLogo(
                        white: true,
                        long: false,
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
                Expanded(
                  flex: 20,
                  child: AutoSizeText(
                    'Закрытый клуб продуктивных людей',
                    maxLines: 3,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 100,
                        fontWeight: FontWeight.bold),
                    wrapWords: false,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  flex: 30,
                  child: AutoSizeText(
                    'People do обьединяет специалистов со всего мира и делает их совместную работу максимально эффективной.',
                    maxLines: 4,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Expanded(
                  flex: 13,
                  child: Center(
                      child: PlatformButton(
                    child: Text('Войти'),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(platformPageRoute(
                          context: context,
                          builder: (_) {
                            return LoginWidget();
                          }));
                    },
                  )),
                ),
                Expanded(
                  flex: 15,
                  child: AutoSizeText(
                    'Нажимая кнопку ВОЙТИ вы соглашаетесь с условиями Соглашения на предоставление услуг и Политикой конфиденциальности',
                    maxLines: 3,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
