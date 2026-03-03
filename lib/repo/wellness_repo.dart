import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'package:nuitri_pilot_frontend/core/network.dart';
import 'package:nuitri_pilot_frontend/core/storage/keys.dart';
import 'package:nuitri_pilot_frontend/core/storage/local_storage.dart';
import 'package:nuitri_pilot_frontend/data/data.dart';

class WellnessRepo {
  Future<Result<Error, WellnessCatagory?>> getWellnessCatagory(String tag) async {
    String? token = await LocalStorage().get(LOCAL_TOKEN_KEY);
    return await post(
      '/wellness/get_user_wellness_and_items?catalogName=$tag',
      {},
      token: token,
      decoder: (json) => WellnessCatagory.fromJson(json)
    );
  }

  Future<Result<Error, CatagoryItem?>> addCatalogItem(
    String tag,
    String name,
  ) async {
    String? token = await LocalStorage().get(LOCAL_TOKEN_KEY);
    return await post('/wellness/add_wellness_catalog_item?catalogName=$tag', {
      "name": name,
    }, token: token,
    decoder: (json) => CatagoryItem.fromJson(json)
    );
  }

  Future<Result<Error,bool>> saveUserSelectedIds(tag, selectedIds) async {
    String? token = await LocalStorage().get(LOCAL_TOKEN_KEY);
    return await post('/wellness/save_user_selected_ids?catalogName=$tag', {
      "selectedIds": selectedIds,
    }, token: token,
    decoder: (json) => json
    );
  }
}
