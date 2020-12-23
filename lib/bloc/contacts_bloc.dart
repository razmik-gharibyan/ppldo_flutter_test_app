import 'dart:async';

import 'package:contacts_service/contacts_service.dart';
import 'package:ppldo_flutter_test_app/bloc/bloc.dart';
import 'package:ppldo_flutter_test_app/helper/contacts_helper.dart';
import 'package:ppldo_flutter_test_app/model/ppldo_contact.dart';

import 'package:ppldo_flutter_test_app/globals.dart' as globals;
import 'package:ppldo_flutter_test_app/services/contact_service.dart';

class ContactsBloc implements Bloc {

  // Tools
  ContactService _contactService = ContactService();
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
    final phones = formattedContacts.map((contact) => contact.phone).toList();
    final remoteContacts = await _contactService.sendLocalContacts(globals.userToken, phones);
    final resultContacts = _compareLocalAndRemoteContacts(formattedContacts, remoteContacts);
    _contacts = resultContacts;
    _inContactsController.add(resultContacts);
  }

  List<PpldoContact> _compareLocalAndRemoteContacts(List<PpldoContact> localContacts, List<PpldoContact> remoteContacts) {
    List<PpldoContact> resultContacts = List<PpldoContact>();
    for (var localContact in localContacts) {
      for (var remoteContact in remoteContacts) {
        if (localContact.phone == remoteContact.phone) {
          resultContacts.add(remoteContact);
          break;
        }
        final index = remoteContacts.indexOf(remoteContact);
        if (index == (remoteContacts.length - 1)) {
          // Check if index is last index of for loop
          resultContacts.add(localContact);
        }
      }
    }
    return resultContacts;
  }

  void addToContactsController(List<PpldoContact> contacts) {
    _inContactsController.add(contacts);
  }

  @override
  void dispose() {
    _contactsController.close();
  }

}