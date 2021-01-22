import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class InnerErrorWidget extends StatelessWidget
{

  final String errorMessage;
  final Function() repeatAction;

  const InnerErrorWidget({Key key, this.errorMessage = "Неизвестная ошибка", this.repeatAction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AutoSizeText(errorMessage, maxLines: 3,),
        PlatformButton(
          child: Text("Повторить"),
          onPressed: repeatAction,
        )
      ],
    );
  }


}