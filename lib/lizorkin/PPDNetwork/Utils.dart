class Utils {
  static Map<int, String> findAllMatches(List<String> patterns, String string) {
    Map<int, String> ret = Map<int, String>();
    patterns.forEach((pattern) {
      int startPos = 0;
      while (string.contains(pattern, startPos)) {
        ret.addAll({string.indexOf(pattern, startPos): pattern});
        startPos = string.indexOf(pattern, startPos) + 1;
      }
    });
    return ret;
  }

  static String mimeStringToImageUrl(String mimeString) {
    if (mimeString.startsWith("application/pdf")) {
      return "assets/images/filetypes/pdf.svg";
    }
    if (mimeString.startsWith("image")) {
      return "assets/images/filetypes/image.svg";
    }
    if (mimeString.startsWith("audio")) {
      return "assets/images/filetypes/audio.svg";
    }
    if (mimeString.startsWith("video")) {
      return "assets/images/filetypes/video.svg";
    }
    if (mimeString.startsWith("text") ||
        mimeString.startsWith("application/vnd") ||
        mimeString.contains("msword")) {
      return "assets/images/filetypes/text.svg";
    }
    if (mimeString.contains("zip") ||
        mimeString.contains("rar") ||
        mimeString.contains("7z") ||
        mimeString.contains("tar")) {
      return "assets/images/filetypes/archive.svg";
    }
    return "assets/images/filetypes/file.svg";
  }
}
