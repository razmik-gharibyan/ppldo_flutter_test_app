import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:ppldo_flutter_test_app/model/ppldo_contact.dart';

class ContactsHelper {

  Future<List<PpldoContact>> formatContactList(List<Contact> contacts) async {
    final libPhoneNumber = FlutterLibphonenumber();
    return contacts.map((contact) {
      final phoneNumber = libPhoneNumber.formatNumberSync(contact.phones.toList()[0].value);
      return PpldoContact(name: contact.displayName, phone: phoneNumber);
    }).toList();
  }

}