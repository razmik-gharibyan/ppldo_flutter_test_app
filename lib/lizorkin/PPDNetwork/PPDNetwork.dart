
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:people_do/lizorkin/GlobalVariables.dart';
import 'package:people_do/lizorkin/LocalSettings.dart';
import 'package:people_do/lizorkin/graphql/schema.schema.gql.dart';
//import 'package:people_do/graphql/subscriptions.ast.gql.dart';


String uuidFromObject(Object object) {
  if (object is Map<String, Object>) {
    final String typeName = object['__typename'] as String;
    final String id = object['id'].toString();
    if (typeName != null && id != null) {
      return <String>[typeName, id].join('/');
    }
  }
  return null;
}

class ProcessedException{
  final OperationException exception;
  bool isAuthorizedException = false;
  String userMessage;

  ProcessedException(this.exception){
    if(exception?.clientException?.message?.contains("Bad credentials") != null){
      isAuthorizedException = true;
    }
    userMessage = exception?.clientException?.message;
    if(userMessage == null){
      userMessage = exception?.graphqlErrors[0]?.message;
    }
    if(userMessage == null) {
      userMessage = 'Неизвестная ошибка';
    }
  }
}

class GQLClient {
  static final GQLClient _singleton = GQLClient._internal();

  GQLClient._internal() {
    notAuthorizedClient = _getClient(uri: GlobalVariables.httpUrl);
    currentClient = _renewCurrentClient();
    LocalSettings().token.addListener(() {
      currentClient = _renewCurrentClient();
    });
  }

  factory GQLClient() {
    return _singleton;
  }

  WebSocketLink _websocketLink;

  ValueNotifier<bool> socketConnected = ValueNotifier<bool>(false);

  Stream<FetchResult> subscription;

  GraphQLClient _renewCurrentClient() {
    var ret = _getClient(
        uri: GlobalVariables.httpUrl,
        token: LocalSettings().token.value,
        subscriptionUri: GlobalVariables.wsUrl);
//    if (LocalSettings().token.value.isNotEmpty) {
//      messageSubscription = ret.subscribe(Operation(
//        documentNode: document,
//      ));
//    }
    return ret;
  }

  GraphQLClient _getClient({
    @required String uri,
    String token = '',
    String subscriptionUri = '',
  }) {
    Link link;
    if (token == null || token.isEmpty) {
      link = HttpLink(uri: uri);
      return GraphQLClient(link: link, cache: cache);
    } else {
      final AuthLink authLink = AuthLink(getToken: () async => "Bearer $token");
//      link = authLink.concat(link);

      if (subscriptionUri.isNotEmpty) {
        _websocketLink = WebSocketLink(
          url: subscriptionUri,
          config: SocketClientConfig(
            autoReconnect: true,
            inactivityTimeout: Duration(seconds: 20),
            initPayload: () async => {
//              "type": "connection_init",
//              "payload": {
//                  "version":"20.6.29",
//                "Authorization": "Bearer $token"
//              }
//              "version":"20.6.29",
              "Authorization": "Bearer $token"
            },
          ),
        );

//        link = authLink.concat(_websocketLink);
        link = _websocketLink;
        socketConnected.value = true;

//        _websocketLink.connectOrReconnect();
        //        print("Connection options: init ${_websocketLink.config.}")

      } else {
        link = authLink.concat(HttpLink(uri: uri));
        socketConnected.value = false;
      }
    }
    var ret = GraphQLClient(link: link, cache: cache);
    //subscription = ret.subscribe(Operation(documentNode: document)).asBroadcastStream();
    return ret;
  }

  static List<ErrorType> getErrorTypes(List<GraphQLError> resultErrors) {
    List<ErrorType> ret = List<ErrorType>();
    resultErrors.forEach((element) {
      if ((element?.raw ?? Map()).containsKey("extensions")) {
        ret.add(ErrorType(element.raw["extensions"]["errorType"].toString()));
      }
    });
    return ret;
  }


  static checkException(OperationException exception) {
    exception.graphqlErrors.forEach((element) {
      if (ErrorType(element.message) == ErrorType.BAD_CREDENTIALS) {
        LocalSettings().token.value = "";
      }
    });
  }

  GraphQLClient currentClient;
  GraphQLClient notAuthorizedClient;
}

final OptimisticCache cache = OptimisticCache(
  dataIdFromObject: uuidFromObject,
);

final LocalSettings settings = LocalSettings();

//GraphQLClient getCurrentClient(bool authorized) {
//  return getClient(
//      uri: GlobalVariables.httpUrl,
//      token: authorized ? LocalSettings().token.value : '',
//      subscriptionUri: GlobalVariables.wsUrl);
//}

//ValueNotifier<GraphQLClient> clientFor({
//  @required String uri,
//  String token,
//  String subscriptionUri,
//}) {
//  return ValueNotifier<GraphQLClient>(
//    getClient(uri: uri, token: token, subscriptionUri: subscriptionUri),
//  );
//}

class LoginProvider extends StatelessWidget {
  final ValueNotifier<GraphQLClient> client;
  final Widget child;

  LoginProvider({@required String uri, @required this.child})
      : client = ValueNotifier<GraphQLClient>(
          GraphQLClient(
            link: HttpLink(uri: uri),
          ),
        );

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: child,
    );
  }
}

/// Wraps the root application with the `graphql_flutter` client.
/// We use the cache for all state management.
//class ClientProvider extends StatelessWidget {
//  ClientProvider({
//    @required this.child,
//    @required String uri,
//    String token = "",
//    String subscriptionUri = "",
//  }) : client = clientFor(
//          uri: uri,
//          token: token,
//          subscriptionUri: subscriptionUri,
//        );
//
//  final Widget child;
//  final ValueNotifier<GraphQLClient> client;
//
//  @override
//  Widget build(BuildContext context) {
//    return GraphQLProvider(
//      client: client,
//      child: CacheProvider(
//        child: child,
//      ),
//    );
//  }
//
//
//}
