import 'dart:io';

import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'package:nuitri_pilot_frontend/core/network.dart';
import 'package:nuitri_pilot_frontend/core/storage/keys.dart';
import 'package:nuitri_pilot_frontend/core/storage/local_storage.dart';

class SuggestionRepo {

  Future<InterfaceResult<dynamic>> seekingSuggestion(File file) async {
    String? token = await LocalStorage().get(LOCAL_TOKEN_KEY);
    return await post('/suggestion/ask', {'img': file}, token: token);
  }


  Future<InterfaceResult> getSuggestionsList(String? lastId) async {
    String? token = await LocalStorage().get(LOCAL_TOKEN_KEY);
    return await post('/suggestion/get', {'last_id': lastId}, token:token);
  }
}
