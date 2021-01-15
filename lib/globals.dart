// Main
enum Mode {
  DEVELOPMENT, PRODUCTION
}

Mode applicationMode = Mode.DEVELOPMENT;

final String mainGraphqlUrl =
  applicationMode == Mode.DEVELOPMENT ? "https://api-dev.ppl.do/graphql" : "https://api.ppl.do/graphql";
final String initialUrl =
  applicationMode == Mode.DEVELOPMENT ? "https://dev.ppl.do" : "https://ppldo.net";

// Tools
String userToken;
String resizeBaseUrl;
// Language
String language;

