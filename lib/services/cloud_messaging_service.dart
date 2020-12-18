import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ppldo_flutter_test_app/globals.dart' as globals;

class CloudMessagingService {

  Future postDeviceToken(String userToken, String deviceToken) async {
    final mutationRequest = """mutation (\$token: String!) { 
                                addPushToken(token: \$token) 
                               }
                            """;
    final request = jsonEncode({
      "query": mutationRequest,
      "variables": {"token": deviceToken}
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
      // Push notifications are ready to be received
      Map<String,dynamic> jsonResponse = json.decode(result.body);
      print(jsonResponse);
    }
  }

  /*
  mutation ($phones: [PhoneNumber!]!) {
  makePosibleContacts(phones: $phones){
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
variables "phones": ["79123273936", "18085550101"]
   */

}