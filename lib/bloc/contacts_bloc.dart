import 'dart:async';

import 'package:contacts_service/contacts_service.dart';

import 'bloc.dart';

class ContactsBloc implements Bloc {

  Timer _timer;

  final _contactsController = StreamController<List<Contact>>();

  Sink<List<Contact>> get _inContactsController => _contactsController.sink;
  Stream<List<Contact>> get contactsStream => _contactsController.stream;

  void startContactsSession() {
    _timer = Timer.periodic(new Duration(seconds: 5), (timer) async {
      Iterable<Contact> contacts = await ContactsService.getContacts();
      _inContactsController.add(contacts.toList());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _contactsController.close();
  }

}