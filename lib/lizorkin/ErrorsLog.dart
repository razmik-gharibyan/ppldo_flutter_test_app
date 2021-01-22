
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

enum PriorityLevel { System, Information, Warning, Error, Critical }

class Error {
  final DateTime dateTime;
  final String errorText;
  final PriorityLevel errorPriority;
  bool isSuppressed = false;

  Error(
      {@required this.dateTime,
      @required this.errorText,
      @required this.errorPriority,
      this.isSuppressed}) {
    debugPrint(this.toString());
  }

  @protected
  String priorityToString(PriorityLevel level) {
    return level.toString().substring(level.toString().indexOf('.') + 1);
  }

  @override
  String toString() {
    return "$dateTime: ${priorityToString(errorPriority)}. $errorText";
  }
}

class ErrorsLog {
  ValueListenable<Error> lastError;

  List<Error> errors = List<Error>();

  static final ErrorsLog _instance = ErrorsLog._internal();

  ErrorsLog._internal() {
    addMessage('Start application', PriorityLevel.System);
  }

  factory ErrorsLog() {
    return _instance;
  }

  void addMessage(String message, PriorityLevel level,
      {bool suppressed = true}) {
    errors.add(Error(
        dateTime: DateTime.now(),
        errorText: message,
        errorPriority: level,
        isSuppressed: suppressed));
  }

  void addErrorMessage(String ownDescription,
      [String exceptionMessage = "",
      bool suppressed = true,
      bool isCritical = false]) {
    addMessage(
        "$ownDescription" +
            (exceptionMessage.isEmpty ? "" : ": $exceptionMessage"),
        isCritical ? PriorityLevel.Critical : PriorityLevel.Error);
  }
}
