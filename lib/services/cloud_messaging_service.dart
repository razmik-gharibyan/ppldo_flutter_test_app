import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ppldo_flutter_test_app/globals.dart' as globals;

class CloudMessagingService {

  Future postDeviceToken(String userToken, String deviceToken) async {
    final mutationRequest = """mutation { 
                                addPushToken(token: \"$deviceToken\") 
                               }
                            """;
    final request = jsonEncode({
      "query": mutationRequest
    });
    final result = await http.post(
        globals.mainUrl,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $userToken"
        },
        body: request
    );
    if (result.statusCode == 200) {
      Map<String,dynamic> jsonResponse = json.decode(result.body);
      print(jsonResponse);
    }
  }

}