import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';
import 'package:ppldo_flutter_test_app/model/ppldo_contact.dart';

class ContactsHelper {

  final _libPhoneNumber = FlutterLibphonenumber();

  Future<List<PpldoContact>> formatContactList(List<PpldoContact> contacts) async {
    //final code = await FlutterSimCountryCode.simCountryCode;
    //final countries = CountryManager().countries;
    //final phoneCode = countries.firstWhere((country) => country.countryCode == code).phoneCode;
    List<PpldoContact> formattedContacts = List<PpldoContact>();
    /*
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
          print("invalid contact in contact list should be igored");
        }
      }
    };

     */
    for (var contact in contacts) {
      final phoneNumber = _libPhoneNumber.formatNumberSync(contact.phone)
          .replaceAll(RegExp(r"\W"), "");
      try {
        final result= await _libPhoneNumber.parse(phoneNumber);
        final String internationalNumber = result["e164"];
        //final String formattedInternationalNumber = internationalNumber.replaceAll(RegExp(r"\W"), "");
        formattedContacts.add(PpldoContact(name: contact.name, phone: internationalNumber));
      } catch (exception) {
        // Phone number is not international
        formattedContacts.add(PpldoContact(name: contact.name, phone: phoneNumber));
      }
    };
    return formattedContacts;
  }

  String e164ToBeautifulInternational(String phoneNumber) {
    return _libPhoneNumber.formatNumberSync(phoneNumber);
  }

}