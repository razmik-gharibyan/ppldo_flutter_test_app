import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ppldo_flutter_test_app/globals.dart' as globals;
import 'package:ppldo_flutter_test_app/model/ppldo_contact.dart';

class ContactService {
  /// request validated contact list from server by giving local [phones]  and [countryCode] from
  /// sim card
  Future<List<PpldoContact>> sendLocalContacts(String userToken, List<String> phones, String countryCode) async {
    final mutationRequest = """mutation (\$phones: [String!]!, \$countryCode: String!) {
                                makePosibleContacts(phones: \$phones, countryCode: \$countryCode){
                                  edges {
                                    is_contact
                                    raw_phone
                                    internationalized_phone
                                    node {
                                      __typename
                                      ...on ActiveUser {
                                        id
                                        phone
                                        profile {
                                          first_name
                                          last_name
                                        }
                                        avatar {
                                          url
                                          key
                                        }
                                      }  
                                    } 
                                  }
                                }
                              }
                            """;
    final request = jsonEncode({
      "query": mutationRequest,
      "variables": {
        "phones": phones,
        "countryCode": "AM" //TODO change to sim country code
      }
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
          final node = e["node"];
          final rawPhone = e["raw_phone"];
          if (node != null) {
            // Contact is registered in PPLDO
            final String id = node["id"];
            final String firstName = node["profile"]["first_name"];
            final String lastName = node["profile"]["last_name"];
            final String phone = node["phone"];
            final Map<String,dynamic> avatar = node["avatar"];
            String avatarUrl;
            String avatarKey;
            if (avatar != null) {
              avatarUrl = avatar["url"];
              avatarKey = avatar["key"];
            }
            return PpldoContact(
                name: "$firstName $lastName",
                phone: phone,
                isContact: isContact,
                inPPLDO: true,
                rawPhone: rawPhone,
                id: id,
                avatarUrl: avatarUrl,
                avatarKey: avatarKey
            );
          } else {
            final internationalizedPhone = e["internationalized_phone"];
            return PpldoContact(
                name: null,
                phone: internationalizedPhone,
                rawPhone: rawPhone,
                isContact: isContact,
                inPPLDO: false);
          }
        }).toList();
      }
      return List<PpldoContact>();
    } else {
      throw Exception("Error receiving contact data from server");
    }
  }

  /// Add contact with [id] to user contact list in server
  Future<bool> addContact(String userToken, String id) async {
    final mutationRequest = """mutation addContact (\$userId: ID!) {
                                addContact (user_id: \$userId) {
                                  __typename
                                }
                               }
                            """;
    final request = jsonEncode({
      "query": mutationRequest,
      "variables": {"userId": id}
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
      var activeUser = jsonResponse["data"]["addContact"]["__typename"];
      if (activeUser == "ActiveUser") {
        return true;
      }
      return false;
    } else {
      throw Exception("Error adding contact data from server");
    }
  }

}