import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ppldo_flutter_test_app/globals.dart' as globals;

class CloudMessagingService {

  Future postDeviceToken(String userToken, String deviceToken) async {
    final mutationRequest = """mutation { 
                                addPushToken(token: "$deviceToken") 
                               }
                            """;
    final request = jsonEncode({
      "query": mutationRequest
    });
    final result = await http.post(
        globals.mainUrlDevChannel,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $userToken",
          "Origin": globals.initialUrlDevChannel
        },
        body: request
    );
    if (result.statusCode == 200) {
      // Push notifications are ready to be received
      Map<String,dynamic> jsonResponse = json.decode(result.body);
      print(jsonResponse);
    }
  }

}