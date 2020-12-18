import 'dart:async';

import 'package:contacts_service/contacts_service.dart';
import 'package:ppldo_flutter_test_app/bloc/bloc.dart';

class ContactsBloc implements Bloc {

  // Controllers
  final _contactsController = StreamController<List<Contact>>();
  // Streams
  Sink<List<Contact>> get _inContactsController => _contactsController.sink;
  Stream<List<Contact>> get contactsStream => _contactsController.stream;
  // Vars
  List<Contact> _contacts;
  // Getters
  List<Contact> get contacts => _contacts;

  void getContactList() async {
    final result = await ContactsService.getContacts();
    final validContactList = result.toList().where((element) {
      if (element.displayName != null && element.phones.toList() != null) {
        if (element.phones.toList().isNotEmpty) {
          return element.phones.toList()[0].value != null;
        }
      }
      return false;
    }).toList();
    _contacts = validContactList;
    _inContactsController.add(validContactList);
  }

  void addToContactsController(List<Contact> contacts) {
    _inContactsController.add(contacts);
  }

  @override
  void dispose() {
    _contactsController.close();
  }

}