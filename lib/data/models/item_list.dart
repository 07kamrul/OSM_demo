class ItemList {
  List<String> koumoku1;
  List<String> koumoku2;
  List<String> koumoku3;
  List<String> koumoku4;
  List<String> koumoku5;
  List<String> koumoku6;
  List<String> koumoku7;
  List<String> koumoku8;
  List<String> koumoku9;
  List<String> koumoku10;

  ItemList({
    required this.koumoku1,
    required this.koumoku2,
    required this.koumoku3,
    required this.koumoku4,
    required this.koumoku5,
    required this.koumoku6,
    required this.koumoku7,
    required this.koumoku8,
    required this.koumoku9,
    required this.koumoku10,
  });

  factory ItemList.fromJson(Map<String, dynamic> json) {
    return ItemList(
      koumoku1: List<String>.from(json['koumoku1'] ?? []),
      koumoku2: List<String>.from(json['koumoku2'] ?? []),
      koumoku3: List<String>.from(json['koumoku3'] ?? []),
      koumoku4: List<String>.from(json['koumoku4'] ?? []),
      koumoku5: List<String>.from(json['koumoku5'] ?? []),
      koumoku6: List<String>.from(json['koumoku6'] ?? []),
      koumoku7: List<String>.from(json['koumoku7'] ?? []),
      koumoku8: List<String>.from(json['koumoku8'] ?? []),
      koumoku9: List<String>.from(json['koumoku9'] ?? []),
      koumoku10: List<String>.from(json['koumoku10'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "koumoku1": koumoku1,
      "koumoku2": koumoku2,
      "koumoku3": koumoku3,
      "koumoku4": koumoku4,
      "koumoku5": koumoku5,
      "koumoku6": koumoku6,
      "koumoku7": koumoku7,
      "koumoku8": koumoku8,
      "koumoku9": koumoku9,
      "koumoku10": koumoku10,
    };
  }
}
