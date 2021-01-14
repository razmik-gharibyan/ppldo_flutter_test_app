import 'dart:async';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';
import 'package:ppldo_flutter_test_app/bloc/bloc.dart';
import 'package:ppldo_flutter_test_app/helper/contacts_helper.dart';
import 'package:ppldo_flutter_test_app/model/ppldo_contact.dart';
import 'package:ppldo_flutter_test_app/services/contact_service.dart';

import 'package:ppldo_flutter_test_app/globals.dart' as globals;

class ContactsBloc implements Bloc {

  // Tools
  ContactService _contactService = ContactService();
  // Controllers
  final _contactsController = StreamController<List<PpldoContact>>();
  // Sinks
  Sink<List<PpldoContact>> get _inContactsController => _contactsController.sink;
  // Streams
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
    final multipleNumberContactList = _checkMultiplePhoneNumbers(validContactList);
    final nonDuplicatedContacts = _removeContactsWithDuplicatePhoneNumbers(multipleNumberContactList);
    final formattedContacts = await ContactsHelper().formatContactList(nonDuplicatedContacts);
    final phones = formattedContacts.map((contact) => contact.phone).toList();
    final countryCode = await FlutterSimCountryCode.simCountryCode;
    final remoteContacts = await _contactService.sendLocalContacts(globals.userToken, phones, countryCode);
    final resultContacts = _compareLocalAndRemoteContacts(formattedContacts, remoteContacts);
    resultContacts.sort((a, b) {
      // This sorting mechanism checks if inPPLDO from element a and element b both are true or both are false
      // if so then sort elements in list in alphabetical order, otherwise check which element is greater then
      // other and move it up [-1] or down [+1] in list. Up of list is considered as element 0,1,2 etc.
      if (a.inPPLDO == b.inPPLDO) {
        return a.name.compareTo(b.name);
      } else if (a.inPPLDO && !b.inPPLDO) {
        return -1;
      } else if (!a.inPPLDO && b.inPPLDO) {
        return 1;
      }
      return 0;
    });
    _contacts = resultContacts;
    if (!_contactsController.isClosed) _inContactsController.add(resultContacts);
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

  List<PpldoContact> _removeContactsWithDuplicatePhoneNumbers(List<PpldoContact> contacts) {

    List<PpldoContact> resultList = List<PpldoContact>();
    for (var contact in contacts) {
      if (resultList.isNotEmpty) {
        final maybeDuplicateContact = resultList.indexWhere((element) =>
          element.phone.replaceAll(RegExp(r"\W"), "").replaceAll(" ", "") == contact.phone.replaceAll(RegExp(r"\W"), "").replaceAll(" ", ""));
        if (maybeDuplicateContact == -1) {
          // Contact number is not duplicate
          resultList.add(contact);
        }
      } else {
        resultList.add(contact);
      }
    }
    return resultList;
  }

  List<PpldoContact> _compareLocalAndRemoteContacts(List<PpldoContact> localContacts, List<PpldoContact> remoteContacts) {
    List<PpldoContact> resultContacts = List<PpldoContact>();
    for (var localContact in localContacts) {
      for (var remoteContact in remoteContacts) {
        if (localContact.phone == remoteContact.rawPhone) {
          if (remoteContact.phone != null) {
            // User have valid international number
            if (remoteContact.name != null) {
              // User is registered in PPLDO
              if (!remoteContact.isContact) {
                resultContacts.add(remoteContact);
              }
            } else {
              final mixedContact = PpldoContact(
                name: localContact.name,
                phone: remoteContact.phone,
                isContact: remoteContact.isContact,
                rawPhone: remoteContact.rawPhone,
                inPPLDO: false
              );
              resultContacts.add(mixedContact);
            }
          }
          break;
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
      if (isContactAdded) {
        _contacts = _contacts.map((contact) {
          if(contact.id == id) {
            // Find correct contact by id
            contact.isContact = true;
          }
          return contact;
        }).toList();
        _inContactsController.add(_contacts);
      }
    } catch (exception) {
      //TODO handle exception when could not add user to contact list
    }

  }

  @override
  void dispose() {
    _contactsController.close();
  }

}