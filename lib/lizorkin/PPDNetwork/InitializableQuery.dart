import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class InitializableQuery extends Query {
  const InitializableQuery({
    final Key key,
    this.init,
    @required this.options,
    @required this.builder,
  }) : super(key: key);

  final QueryOptions options;
  final QueryBuilder builder;
  final Function() init;

  @override
  ExpandedQueryState createState() => ExpandedQueryState(init);
}

class ExpandedQueryState extends QueryState{

  final Function() init;

  ExpandedQueryState(this.init):super();

  @override
  void initState() {
    super.initState();
    init();
  }
}