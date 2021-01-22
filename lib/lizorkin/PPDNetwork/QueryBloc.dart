import 'package:gql/ast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:people_do/lizorkin/PPDNetwork/BaseBloc.dart';
import 'package:people_do/lizorkin/PPDNetwork/PPDNetwork.dart';

class QueryBloc extends BaseBloc{

  QueryBloc({bool authorized = true, DocumentNode documentNode, Map<String, dynamic> variables}): super(documentNode, variables, authorized);

  Future<void> fetchMore(Map<String, dynamic> fetchVariables) async {
    resultBehaviour.add(null);
    var _variables = variables;
    _variables.addAll(fetchVariables);
    innerRun(documentNode, _variables);
  }

  @override
  Future innerRun(DocumentNode node, Map<String, dynamic> vars) async {
    final _options = WatchQueryOptions(
      documentNode: node,
      variables: vars,
      fetchPolicy: FetchPolicy.cacheAndNetwork,
    );
    final result = authorized ? await GQLClient().currentClient.query(_options) : await GQLClient().notAuthorizedClient.query(_options);
    if (result.hasException) {
      resultBehaviour.addError(result.exception);
      return;
    }
    resultBehaviour.add(result);
  }

}