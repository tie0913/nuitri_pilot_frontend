import 'dart:convert';
import 'dart:typed_data';

import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'package:nuitri_pilot_frontend/core/network.dart';
import 'package:nuitri_pilot_frontend/core/storage/keys.dart';
import 'package:nuitri_pilot_frontend/core/storage/local_storage.dart';

class WellnessRepo {
  Future<InterfaceResult<dynamic>> getWellnessCatagory(String tag) async {
    Uint8List? value = LocalStorage().get(LOCAL_TOKEN_KEY);
    String token = utf8.decode(Uint8List.fromList(value!));
    return await post(
      '/wellness/get_user_wellness_and_items?catalogName=$tag',
      {},
      token: token,
    );
  }

  Future<InterfaceResult<dynamic>> addCatalogItem(
    String tag,
    String name,
  ) async {
    Uint8List? value = LocalStorage().get(LOCAL_TOKEN_KEY);
    String token = utf8.decode(Uint8List.fromList(value!));
    return await post('/wellness/add_wellness_catalog_item?catalogName=$tag', {
      "name": name,
    }, token: token);
  }

  Future<InterfaceResult<dynamic>> saveUserSelectedIds(tag, selectedIds) async {
    Uint8List? value = LocalStorage().get(LOCAL_TOKEN_KEY);
    String token = utf8.decode(Uint8List.fromList(value!));
    return await post('/wellness/save_user_selected_ids?catalogName=$tag', {
      "selectedIds": selectedIds,
    }, token: token);
  }
}
