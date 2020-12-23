import 'dart:async';

import 'package:contacts_service/contacts_service.dart';
import 'package:ppldo_flutter_test_app/bloc/bloc.dart';
import 'package:ppldo_flutter_test_app/helper/contacts_helper.dart';
import 'package:ppldo_flutter_test_app/model/ppldo_contact.dart';

class ContactsBloc implements Bloc {

  // Controllers
  final _contactsController = StreamController<List<PpldoContact>>();
  // Streams
  Sink<List<PpldoContact>> get _inContactsController => _contactsController.sink;
  Stream<List<PpldoContact>> get contactsStream => _contactsController.stream;
  // Vars
  List<PpldoContact> _contacts;
  // Getters
  List<PpldoContact> get contacts => _contacts;

  void getContactList() async {
    final result = await ContactsService.getContacts();
    final validContactList = result.toList().where((element) {
      final name = element.displayName;
      final phoneList = element.phones.toList();
      if (name != null && phoneList != null) {
        if (phoneList.isNotEmpty) {
          return (phoneList[0].value != null && phoneList[0].value.length >= 9);
        }
      }
      return false;
    }).toList();
    final formattedContacts = await ContactsHelper().formatContactList(validContactList);
    _contacts = formattedContacts;
    _inContactsController.add(formattedContacts);
  }

  void addToContactsController(List<PpldoContact> contacts) {
    _inContactsController.add(contacts);
  }

  @override
  void dispose() {
    _contactsController.close();
  }

}