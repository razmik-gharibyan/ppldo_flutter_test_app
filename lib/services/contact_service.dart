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
          final String id = e["node"]["id"];
          final String firstName = e["node"]["profile"]["first_name"];
          final String lastName = e["node"]["profile"]["last_name"];
          final String phone = e["node"]["phone"];
          final Map<String,dynamic> avatar = e["node"]["avatar"];
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
            id: id,
            avatarUrl: avatarUrl,
            avatarKey: avatarKey
          );
        }).toList();
      }
      return List<PpldoContact>();
    } else {
      throw Exception("Error receiving contact data from server");
    }
  }

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