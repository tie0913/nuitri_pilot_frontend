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

class Feedback {
  final String level;
  final String explaination;
  const Feedback({required this.level, required this.explaination});

  factory Feedback.fromJson(Map<String, dynamic> json){
    String level = json['level'].toString();
    String explaination = json['explaination'].toString();
    return Feedback(level:level, explaination: explaination);
  }
}

class FeedItem {
  final String id;
  final int mark;
  final String thumbnail;
  final DateTime time;
  final Feedback feedback;
  final List<String> recommendation;

  const FeedItem({
    required this.id,
    required this.mark,
    required this.thumbnail,
    required this.time,
    required this.feedback,
    required this.recommendation
  });

  factory FeedItem.fromJson(Map<String, dynamic> json){

    List<String> rr = List<String>.from(json['recommendation']);
    Feedback feedback = Feedback.fromJson(json['feedback']);
    FeedItem item = FeedItem(id: json['_id'], mark:json['mark'], thumbnail: json['thumbnail'], time: DateTime.parse(json['time']).toLocal(), feedback: feedback, recommendation: rr);
    return item;
  }
}