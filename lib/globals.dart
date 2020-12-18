enum Mode {
  DEVELOPER, PRODUCTION
}

Mode applicationMode = Mode.DEVELOPER;

final String mainUrl =
  applicationMode == Mode.DEVELOPER ? "https://api-dev.ppl.do/graphql" : "https://api.ppl.do/graphql";
final String initialUrl =
  applicationMode == Mode.DEVELOPER ? "https://dev.ppl.do" : "https://ppldo.net";



