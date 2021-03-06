import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:people_do/globals.dart' as globals;

class CloudMessagingService {

  void postDeviceToken(String userToken, String deviceToken) async {
    final mutationRequest = """mutation (\$token: String!) { 
                                addPushToken(token: \$token) 
                               }
                            """;
    final request = jsonEncode({
      "query": mutationRequest,
      "variables": {"token": deviceToken}
    });
    final result = await http.post(
        globals.mainGraphqlUrl,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $userToken",
          "Origin": globals.initialUrl
        },
        body: request
    );
    if (result.statusCode == 200) {
      // Push notifications are ready to be received
    }
  }

}