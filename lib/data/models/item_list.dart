class ItemList {
  final List<String> Koumoku1; // "性別" (seibetsu)
  final List<String> Koumoku2; // "趣味" (shumi)
  final List<String> Koumoku3; // "年齢" (nenrei)
  final List<String> Koumoku4; // "地域" (chiiki)

  ItemList({
    required this.Koumoku1,
    required this.Koumoku2,
    required this.Koumoku3,
    required this.Koumoku4,
  });

  factory ItemList.fromJson(Map<String, dynamic> json) {
    return ItemList(
      Koumoku1: List<String>.from(json['性別'] ?? []),
      Koumoku2: List<String>.from(json['趣味'] ?? []),
      Koumoku3: List<String>.from(json['年齢'] ?? []),
      Koumoku4: List<String>.from(json['地域'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '性別': Koumoku1,
      '趣味': Koumoku2,
      '年齢': Koumoku3,
      '地域': Koumoku4,
    };
  }
}
