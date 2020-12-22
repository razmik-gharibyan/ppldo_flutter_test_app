import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ppldo_flutter_test_app/globals.dart' as globals;

class ContactService {

  Future sendLocalContacts(String userToken, List<String> contacts) async {
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
      "variables": {"phones": contacts}
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
      print(jsonResponse);
    }
  }

}