import 'dart:async';

import 'package:people_do/bloc/bloc.dart';

class SearchContactsBloc implements Bloc {

  final _searchContactsController = StreamController<String>();

  Sink<String> get inSearchContactsController => _searchContactsController.sink;
  Stream<String> get searchContactsStream => _searchContactsController.stream;

  @override
  void dispose() {
    _searchContactsController.close();
  }

}