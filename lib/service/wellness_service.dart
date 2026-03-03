import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'package:nuitri_pilot_frontend/data/data.dart';
import 'package:nuitri_pilot_frontend/repo/wellness_repo.dart';

class WellnessService {
  WellnessRepo repo;
  WellnessService(this.repo);

  Future<Result<Error, WellnessCatagory?>> getWellnessCatagory(String tag) async {
    return await repo.getWellnessCatagory(tag);
  }

  Future<Result<Error, CatagoryItem?>> addItem(String tag, String name) async {
    return await repo.addCatalogItem(tag, name);
  }

  Future<Result<Error, bool>> saveUserSelection(String tag, List<String> selectedIds) async {
    return await repo.saveUserSelectedIds(
      tag,
      selectedIds,
    );
  }
}
