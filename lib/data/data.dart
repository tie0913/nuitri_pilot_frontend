class CatagoryItem {
  final String id;
  final String name;
  const CatagoryItem({required this.id, required this.name});

  factory CatagoryItem.fromJson(Map<String, dynamic> json) {
    return CatagoryItem(id: json['_id'], name: json['name']);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CatagoryItem && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class WellnessCatagory {
  List<String> selectedIds;
  List<CatagoryItem> items;
  WellnessCatagory({required this.selectedIds, required this.items});

  factory WellnessCatagory.fromJson(Map<String, dynamic> json) {
    List<dynamic> rawList = json['items'];
    List<CatagoryItem> items = rawList
        .map((e) => CatagoryItem.fromJson(e))
        .toList();

    List<dynamic> rawIdList = json['selectedIds'];
    List<String> selectedIds = rawIdList.map((e) => e.toString()).toList();
    return WellnessCatagory(selectedIds: selectedIds, items: items);
  }

  getItems() {
    return items;
  }
}
