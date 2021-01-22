import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:people_do/globals.dart' as globals;

class AvatarService {

  /// Get base url for resizing images
  Future<String> getResizeBaseUrl() async {
    final queryRequest = """query {
                                 settings {
                                 resizeBaseUrl 
                              }
                            }
                         """;
    final request = jsonEncode({
      "query": queryRequest,
    });
    final result = await http.post(
      globals.mainGraphqlUrl,
      headers: {
        "Content-Type": "application/json",
        "Origin": globals.initialUrl
      },
      body: request
    );
    if (result.statusCode == 200) {
      // Response base url for resizing string
      Map<String,dynamic> jsonResponse = json.decode(result.body);
      var resizeBaseUrl = jsonResponse["data"]["settings"]["resizeBaseUrl"];
      return resizeBaseUrl;
    } else {
      throw Exception("Error getting resizeBaseUrl");
    }
  }

}