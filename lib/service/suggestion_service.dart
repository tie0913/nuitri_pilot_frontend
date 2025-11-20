import 'dart:io';

import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'package:nuitri_pilot_frontend/core/di.dart';
import 'package:nuitri_pilot_frontend/data/data.dart';
import 'package:nuitri_pilot_frontend/repo/suggestion_repo.dart';

class SuggestionService {
  SuggestionRepo repo;
  SuggestionService(this.repo);

  Future<FeedItem?> seekingSuggestion(File file) async {
    InterfaceResult<dynamic> res = await repo.seekingSuggestion(file);
    if (DI.I.messageHandler.isErr(res)) {
      DI.I.messageHandler.handleErr(res);
      return null;
    } else {
      return FeedItem.fromJson(res.value!);
    }
  }


  Future<List<FeedItem>> getSuggestionsList(String? lastId) async {
    InterfaceResult<dynamic> res = await repo.getSuggestionsList(lastId);

    if (DI.I.messageHandler.isErr(res)) {
      DI.I.messageHandler.handleErr(res);
      return [];
    } else {
      if(res.value == null){
        return [];
      }else if(res.value is List){
        List<FeedItem> list = [];
        for(int i = 0; i < res.value.length; i++){
          list.add(FeedItem.fromJson(res.value[i]));
        }
        return list;
        //return res.value.map((e) => FeedItem.fromJson(e)).toList();
      }
      return [];
    }

  }
}
