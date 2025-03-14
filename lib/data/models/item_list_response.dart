import 'item_list.dart';

class ItemListResponse {
  final ItemList itemList;
  final String status;
  final String message;

  ItemListResponse({
    required this.itemList,
    required this.status,
    required this.message,
  });

  factory ItemListResponse.fromJson(Map<String, dynamic> json) {
    return ItemListResponse(
      itemList: ItemList.fromJson(json['itemlist'] ?? {}),
      status: json['status'] ?? '',
      message: json['message'] ?? '',
    );
  }
}
