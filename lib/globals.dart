enum Mode {
  DEV, RC, PROD
}

Mode applicationMode = Mode.DEV;

String mainGraphqlUrl;
String initialUrl;

// Tools
String userToken;
String resizeBaseUrl;
// Language
String language;

// Methods
void changeMode(Mode mode) {
  applicationMode = mode;
  switch (mode) {
    case Mode.DEV:
      mainGraphqlUrl = "https://api-dev.ppl.do/graphql";
      initialUrl = "https://dev.ppl.do";
      break;
    case Mode.RC:
      mainGraphqlUrl = "https://api-rc.ppl.do/graphql";
      initialUrl = "https://rc.ppl.do";
      break;
    case Mode.PROD:
      mainGraphqlUrl = "https://api.ppl.do/graphql";
      initialUrl = "https://ppldo.net";
  }
}

