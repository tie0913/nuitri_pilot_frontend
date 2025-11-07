
class WellnessItem {
  final String id;
  final String name;
  const WellnessItem({required this.id, required this.name});

  factory WellnessItem.fromJson(Map<String, dynamic> json){
    return WellnessItem(id: json['_id'], name: json['name']);
  }
}

class UserChronic {
  List<String> selectedIds;
  List<WellnessItem> chronics;
  UserChronic({required this.selectedIds, required this.chronics});

  factory UserChronic.fromJson(Map<String, dynamic> json) {
    List<dynamic> rawList = json['chronics'];
    List<WellnessItem> chronics = rawList.map((e) => WellnessItem.fromJson(e)).toList();

    List<dynamic> rawIdList = json['selectedIds'];
    List<String> selectedIds = rawIdList.map((e) => e.toString()).toList();
    return UserChronic(selectedIds: selectedIds, chronics: chronics);
  }

  getChronics(){
    return chronics;
  }
}
