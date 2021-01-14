class Area {

  final int x;
  final int y;
  final int width;
  final int height;

  Area({this.x, this.y, this.width, this.height});

  Area.fromJson(Map<String,dynamic> json)
    : x = json["x"],
      y = json["y"],
      width = json["width"],
      height = json["height"];
}