import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'package:nuitri_pilot_frontend/core/di.dart';
import 'package:nuitri_pilot_frontend/data/data.dart';
import 'package:nuitri_pilot_frontend/repo/wellness_repo.dart';

class WellnessService {
  WellnessRepo repo;
  WellnessService(this.repo);

  Future<WellnessCatagory?> getWellnessCatagory(String tag) async {
    InterfaceResult<dynamic> res = await repo.getWellnessCatagory(tag);
    if (DI.I.messageHandler.isErr(res)) {
      DI.I.messageHandler.handleErr(res);
      return null;
    } else {
      return WellnessCatagory.fromJson(res.value!);
    }
  }

  Future<CatagoryItem?> addItem(String tag, String name) async {
    InterfaceResult<dynamic> res = await repo.addCatalogItem(tag, name);
    if (DI.I.messageHandler.isErr(res)) {
      DI.I.messageHandler.handleErr(res);
      return null;
    } else {
      return CatagoryItem.fromJson(res.value!);
    }
  }

  Future<bool> saveUserSelection(String tag, List<String> selectedIds) async {
    InterfaceResult<dynamic> res = await repo.saveUserSelectedIds(tag, selectedIds);
    if (DI.I.messageHandler.isErr(res)) {
      DI.I.messageHandler.handleErr(res);
      return false;
    } else {
      return true;
    }
  }
}
