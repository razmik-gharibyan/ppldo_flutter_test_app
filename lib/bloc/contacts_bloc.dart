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
  final _addContactController = StreamController<bool>();
  // Sinks
  Sink<List<PpldoContact>> get _inContactsController => _contactsController.sink;
  Sink<bool> get _inAddContactController => _addContactController.sink;
  // Streams
  Stream<List<PpldoContact>> get contactsStream => _contactsController.stream;
  Stream<bool> get addContactStream => _addContactController.stream;
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
    final multipleNumberContactList = _checkMultiplePhoneNumbers(validContactList);
    final formattedContacts = await ContactsHelper().formatContactList(multipleNumberContactList);
    final phones = formattedContacts.map((contact) => contact.phone).toList();
    final remoteContacts = await _contactService.sendLocalContacts(globals.userToken, phones);
    final resultContacts = _compareLocalAndRemoteContacts(formattedContacts, remoteContacts);
    _contacts = resultContacts;
    _inContactsController.add(resultContacts);
  }

  List<PpldoContact> _checkMultiplePhoneNumbers(List<Contact> contacts) {
    List<PpldoContact> resultList = List<PpldoContact>();
    for (var contact in contacts) {
      for (var phone in contact.phones.toList()) {
        resultList.add(PpldoContact(name: contact.displayName, phone: phone.value));
      }
    }
    return resultList;
  }

  List<PpldoContact> _compareLocalAndRemoteContacts(List<PpldoContact> localContacts, List<PpldoContact> remoteContacts) {
    List<PpldoContact> resultContacts = List<PpldoContact>();
    if (remoteContacts.isEmpty) {
      resultContacts.addAll(localContacts);
    } else {
      for (var localContact in localContacts) {
        for (var remoteContact in remoteContacts) {
          if (localContact.phone == remoteContact.phone) {
            // if isContact is true, then don't add this contact to contact list on UI
            if (!remoteContact.isContact) {
              resultContacts.add(remoteContact);
            }
            break;
          }
          final index = remoteContacts.indexOf(remoteContact);
          if (index == (remoteContacts.length - 1)) {
            // Check if index is last index of for loop
            resultContacts.add(localContact);
          }
        }
      }
    }
    return resultContacts;
  }

  void addContactsToContactsController(List<PpldoContact> contacts) {
    _inContactsController.add(contacts);
  }

  void addContact(String id) async {
    try {
      final isContactAdded = await _contactService.addContact(globals.userToken, id);
      _inAddContactController.add(isContactAdded);
    } catch (exception) {
      //TODO handle exception when could not add user to contact list
    }

  }

  @override
  void dispose() {
    _contactsController.close();
    _addContactController.close();
  }

}