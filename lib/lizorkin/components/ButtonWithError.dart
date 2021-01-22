import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ButtonWithError extends StatefulWidget
{

  final ValueNotifier<String> errorText;
  final ValueNotifier<String> buttonText;
  final ValueNotifier<bool> enabled;
  final Function() action;

  const ButtonWithError(
      {Key key, this.errorText, this.buttonText, this.enabled, this.action})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ButtonWithErrorState();

}

class _ButtonWithErrorState extends State<ButtonWithError> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PlatformButton(
          child: Text(widget.buttonText.value),
          onPressed: widget.enabled.value ? widget.action : null,
          androidFlat: (_) => MaterialFlatButtonData(),
        ),
        AnimatedContainer(
          duration: Duration(seconds: 1),
          child: Text(
            widget.errorText.value,
            style: TextStyle(
              color: Colors.red[300],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    widget.errorText.addListener(() {setState(() {});});
    widget.buttonText.addListener(() {setState(() {});});
    widget.enabled.addListener(() {setState(() {});});
  }


}