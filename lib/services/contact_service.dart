import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ppldo_flutter_test_app/globals.dart' as globals;
import 'package:ppldo_flutter_test_app/model/ppldo_contact.dart';

class ContactService {

  Future<List<PpldoContact>> sendLocalContacts(String userToken, List<String> phones) async {
    final mutationRequest = """mutation (\$phones: [PhoneNumber!]!) {
                                makePosibleContacts(phones: \$phones){
                                  edges {
                                    is_contact
                                    node {
                                      __typename
                                      ...on ActiveUser {
                                        phone
                                        profile {
                                          first_name
                                          last_name
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            """;
    final request = jsonEncode({
      "query": mutationRequest,
      "variables": {"phones": phones}
    });
    final result = await http.post(
        globals.mainUrl,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $userToken",
          "Origin": globals.initialUrl
        },
        body: request
    );
    if (result.statusCode == 200) {
      // Response is list of contacts
      Map<String,dynamic> jsonResponse = json.decode(result.body);
      List<dynamic> edges = jsonResponse["data"]["makePosibleContacts"]["edges"];
      if (edges.isNotEmpty) {
        return edges.map((e) {
          final bool isContact = e["is_contact"];
          final String firstName = e["node"]["profile"]["first_name"];
          final String lastName = e["node"]["profile"]["last_name"];
          final String phone = e["node"]["phone"];
          return PpldoContact(name: "$firstName $lastName", phone: phone, isContact: isContact);
        }).toList();
      }
      return List<PpldoContact>();
    } else {
      throw Exception("Error receiving contact data from server");
    }
  }

}