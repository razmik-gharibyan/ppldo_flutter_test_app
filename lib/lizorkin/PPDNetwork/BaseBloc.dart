import 'package:flutter/cupertino.dart';
import 'package:gql/ast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:people_do/lizorkin/LocalSettings.dart';
import 'package:people_do/lizorkin/PPDNetwork/PPDNetwork.dart';
import 'package:rxdart/subjects.dart';

abstract class BaseBloc {
  final bool authorized;

  DocumentNode documentNode;
  Map<String, dynamic> variables;

  @protected
  final BehaviorSubject<dynamic> resultBehaviour = BehaviorSubject<dynamic>();

  Stream<dynamic> get resultStream => resultBehaviour.stream;

  BaseBloc(this.documentNode, this.variables, this.authorized) {
    var taskHash = documentNode.hashCode;
    print("$taskHash running task: ${documentNode.definitions[0].toString()}");
    resultBehaviour.listen((value) {
      if(value != null){
        print("$taskHash task done: $value");
      }
    }, onError: (error) {
      if (error is OperationException) {
        print("$taskHash with server error: ${error.graphqlErrors.isNotEmpty ? error
            .graphqlErrors[0].message : error.clientException.message}");
      }
      else if (error is NetworkException) {
        print("$taskHash with network error: ${error.message}");
      }
      else {
        print("$taskHash with unknown error of type ${error.runtimeType.toString()}");
      }
    });
  }


  Future<void> run() async {
    resultBehaviour.add(null);

    await innerRun(documentNode, variables);
  }

  @protected
  Future innerRun(DocumentNode node, Map<String, dynamic> vars);

}