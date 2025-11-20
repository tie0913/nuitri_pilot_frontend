import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'package:nuitri_pilot_frontend/core/network.dart';
import 'package:nuitri_pilot_frontend/core/storage/keys.dart';
import 'package:nuitri_pilot_frontend/core/storage/local_storage.dart';

class SuggestionRepo {

  Future<InterfaceResult<dynamic>> seekingSuggestion(File file) async {
    Uint8List? value = LocalStorage().get(LOCAL_TOKEN_KEY);
    String token = utf8.decode(Uint8List.fromList(value!));
    return await post('/suggestion/ask', {'img': file}, token: token);
  }


  Future<InterfaceResult> getSuggestionsList(String? lastId) async {
    Uint8List? value = LocalStorage().get(LOCAL_TOKEN_KEY);
    String token = utf8.decode(Uint8List.fromList(value!));
    return await post('/suggestion/get', {'last_id': lastId}, token:token);
  }
}
