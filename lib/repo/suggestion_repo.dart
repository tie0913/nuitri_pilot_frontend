import 'dart:io';

import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'package:nuitri_pilot_frontend/core/network.dart';
import 'package:nuitri_pilot_frontend/core/storage/keys.dart';
import 'package:nuitri_pilot_frontend/core/storage/local_storage.dart';
import 'package:nuitri_pilot_frontend/data/data.dart';

class SuggestionRepo {

  Future<Result<Error, FeedItem>> seekingSuggestion(File file) async {
    String? token = await LocalStorage().get(LOCAL_TOKEN_KEY);
    return await post('/suggestion/ask', {'img': file}, token: token, decoder:(json) => FeedItem.fromJson(json));
  }

  Future<Result<Error, List<FeedItem>>> getSuggestionsList(String? lastId) async {
    String? token = await LocalStorage().get(LOCAL_TOKEN_KEY);
    Result<Error, List<FeedItem>> result = await post('/suggestion/get', {'last_id': lastId}, token:token,
    decoder: (json) {
      if(json is List){
        List<FeedItem> list = [];
        for(int i = 0; i < json.length; i++){
          list.add(FeedItem.fromJson(json[i]));
        }
        return list;
      }else{
        return List.empty();
      }
    });
    return result;
  }

  Future<Result<Error, bool>> deleteRecordById(String id) async {
    String? token = await LocalStorage().get(LOCAL_TOKEN_KEY);
    return await post('/suggestion/delete_by_id', {'id': id}, token: token, decoder: (json) => json);
  }
}
