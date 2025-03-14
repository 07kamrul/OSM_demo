class ItemList {
  // Dynamically created properties
  List<String> Koumoku1;
  List<String> Koumoku2;
  List<String> Koumoku3;
  List<String> Koumoku4;
  List<String> Koumoku5;
  List<String> Koumoku6;
  List<String> Koumoku7;
  List<String> Koumoku8;
  List<String> Koumoku9;
  List<String> Koumoku10;

  ItemList({
    required this.Koumoku1,
    required this.Koumoku2,
    required this.Koumoku3,
    required this.Koumoku4,
    required this.Koumoku5,
    required this.Koumoku6,
    required this.Koumoku7,
    required this.Koumoku8,
    required this.Koumoku9,
    required this.Koumoku10,
  });

  factory ItemList.fromJson(Map<String, dynamic> json) {
    // Create an empty list for each Koumoku
    List<String> koumoku1 = [];
    List<String> koumoku2 = [];
    List<String> koumoku3 = [];
    List<String> koumoku4 = [];
    List<String> koumoku5 = [];
    List<String> koumoku6 = [];
    List<String> koumoku7 = [];
    List<String> koumoku8 = [];
    List<String> koumoku9 = [];
    List<String> koumoku10 = [];

    // Use a for loop to dynamically assign values to each Koumoku property
    int counter = 1;
    json.forEach((key, value) {
      // Ensure that each key corresponds to a valid Koumoku index (1 to 10)
      if (counter <= 10) {
        List<String> dynamicKoumoku =
            (value is List) ? List<String>.from(value) : [value.toString()];

        // Assign the value to the corresponding Koumoku property
        switch (counter) {
          case 1:
            koumoku1 = dynamicKoumoku;
            break;
          case 2:
            koumoku2 = dynamicKoumoku;
            break;
          case 3:
            koumoku3 = dynamicKoumoku;
            break;
          case 4:
            koumoku4 = dynamicKoumoku;
            break;
          case 5:
            koumoku5 = dynamicKoumoku;
            break;
          case 6:
            koumoku6 = dynamicKoumoku;
            break;
          case 7:
            koumoku7 = dynamicKoumoku;
            break;
          case 8:
            koumoku8 = dynamicKoumoku;
            break;
          case 9:
            koumoku9 = dynamicKoumoku;
            break;
          case 10:
            koumoku10 = dynamicKoumoku;
            break;
        }
        counter++;
      }
    });

    // Return the ItemList object using the dynamically filled koumoku values
    return ItemList(
      Koumoku1: koumoku1,
      Koumoku2: koumoku2,
      Koumoku3: koumoku3,
      Koumoku4: koumoku4,
      Koumoku5: koumoku5,
      Koumoku6: koumoku6,
      Koumoku7: koumoku7,
      Koumoku8: koumoku8,
      Koumoku9: koumoku9,
      Koumoku10: koumoku10,
    );
  }
}
