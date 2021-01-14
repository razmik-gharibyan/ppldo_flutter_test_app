class Area {

  final int x;
  final int y;
  final int width;
  final int height;

  Area({this.x, this.y, this.width, this.height});

  factory Area.fromJson(Map<String,dynamic> json) {
    if (json == null) return null;
    return Area(
      x: json["x"],
      y: json["y"],
      width: json["width"],
      height: json["height"],
    );
  }

  Map<String, dynamic> toJson() =>
    {
      "x": x,
      "y": y,
      "width": width,
      "height": height,
    };
}