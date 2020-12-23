import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';
import 'package:ppldo_flutter_test_app/model/ppldo_contact.dart';

class ContactsHelper {

  Future<List<PpldoContact>> formatContactList(List<Contact> contacts) async {
    final libPhoneNumber = FlutterLibphonenumber();
    final code = await FlutterSimCountryCode.simCountryCode;
    final countries = CountryManager().countries;
    final phoneCode = countries.firstWhere((country) => country.countryCode == code).phoneCode;
    List<PpldoContact> formattedContacts = List<PpldoContact>();

    for (var contact in contacts) {
      final phoneNumber = libPhoneNumber.formatNumberSync(contact.phones.toList()[0].value)
          .replaceAll(RegExp(r"\W"), "");
      try {
        final result= await libPhoneNumber.parse(phoneNumber);
        formattedContacts.add(PpldoContact(name: contact.displayName, phone: result["e164"]));
      } catch (exception) {
        try {
          final result = await libPhoneNumber.parse("+$phoneCode$phoneNumber");
          formattedContacts.add(PpldoContact(name: contact.displayName, phone: result["e164"]));
        } catch (exception) {
          print("invalid contact in contact list should be ignored");
        }
      }
    };
    return formattedContacts;
  }

}