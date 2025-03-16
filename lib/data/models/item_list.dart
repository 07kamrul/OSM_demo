import 'package:gis_osm/data/models/name_value_pair.dart';

class ItemList {
  NameValuePair Koumoku1;
  NameValuePair Koumoku2;
  NameValuePair Koumoku3;
  NameValuePair Koumoku4;
  NameValuePair Koumoku5;
  NameValuePair Koumoku6;
  NameValuePair Koumoku7;
  NameValuePair Koumoku8;
  NameValuePair Koumoku9;
  NameValuePair Koumoku10;

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
    NameValuePair koumoku1 = new NameValuePair(name: '', values: []);
    NameValuePair koumoku2 = new NameValuePair(name: '', values: []);
    NameValuePair koumoku3 = new NameValuePair(name: '', values: []);
    NameValuePair koumoku4 = new NameValuePair(name: '', values: []);
    NameValuePair koumoku5 = new NameValuePair(name: '', values: []);
    NameValuePair koumoku6 = new NameValuePair(name: '', values: []);
    NameValuePair koumoku7 = new NameValuePair(name: '', values: []);
    NameValuePair koumoku8 = new NameValuePair(name: '', values: []);
    NameValuePair koumoku9 = new NameValuePair(name: '', values: []);
    NameValuePair koumoku10 = new NameValuePair(name: '', values: []);

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
            koumoku1.name = key;
            koumoku1.values = dynamicKoumoku;
            break;
          case 2:
            koumoku2.name = key;
            koumoku2.values = dynamicKoumoku;
            break;
          case 3:
            koumoku3.name = key;
            koumoku3.values = dynamicKoumoku;
            break;
          case 4:
            koumoku4.name = key;
            koumoku4.values = dynamicKoumoku;
            break;
          case 5:
            koumoku5.name = key;
            koumoku5.values = dynamicKoumoku;
            break;
          case 6:
            koumoku6.name = key;
            koumoku6.values = dynamicKoumoku;
            break;
          case 7:
            koumoku7.name = key;
            koumoku7.values = dynamicKoumoku;
            break;
          case 8:
            koumoku8.name = key;
            koumoku8.values = dynamicKoumoku;
            break;
          case 9:
            koumoku9.name = key;
            koumoku9.values = dynamicKoumoku;
            break;
          case 10:
            koumoku10.name = key;
            koumoku10.values = dynamicKoumoku;
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
