import 'package:gql/ast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:people_do/lizorkin/PPDNetwork/BaseBloc.dart';
import 'package:people_do/lizorkin/PPDNetwork/PPDNetwork.dart';

class MutationBloc extends BaseBloc {

  MutationBloc({bool authorized = true, DocumentNode documentNode, Map<String, dynamic> variables}): super(documentNode, variables, authorized);

  @override
  Future innerRun(DocumentNode node, Map<String, dynamic> vars) async {
    final _options = MutationOptions(
      documentNode: node,
      variables: vars,
      fetchPolicy: FetchPolicy.cacheAndNetwork,
    );
    final result = authorized ? await GQLClient().currentClient.mutate(_options) : await GQLClient().notAuthorizedClient.mutate(_options);
    if (result.hasException) {
      resultBehaviour.addError(result.exception);
      return;
    }
    resultBehaviour.add(result);
  }

}