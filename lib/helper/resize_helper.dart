import 'dart:convert';

import 'package:ppldo_flutter_test_app/model/area.dart';

/// Top level function transforms [baseUrl], [key], [area] from avatar to encoded
/// string for resize request
String encodeResizeUrl(String baseUrl, String key, Area area, int size) {
  var jsonRequest;
  if (area == null) {
    jsonRequest = jsonEncode({
      "edits": {
        "rotate": null,
        "resize": {
          "width": size,
          "height": size
        }
      },
      "key": key
    });
  } else {
    jsonRequest = jsonEncode({
      "edits": {
        "rotate": null,
        "extract": {
          "left": area.x,
          "top": area.y,
          "width": area.width,
          "height": area.height,
        },
        "resize": {
          "width": size,
          "height": size
        }
      },
      "key": key
    });
  }
  final encodedUrl = base64Url.encode(utf8.encode(jsonRequest));
  return "$baseUrl/$encodedUrl";
}

class ResizeHelper {

  String getResizedUrlForAvatar(String baseUrl, String key, Area area) {
    return encodeResizeUrl(baseUrl, key, area, 40);
  }

}