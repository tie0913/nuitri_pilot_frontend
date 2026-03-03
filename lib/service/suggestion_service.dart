import 'dart:io';

import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'package:nuitri_pilot_frontend/data/data.dart';
import 'package:nuitri_pilot_frontend/repo/suggestion_repo.dart';

class SuggestionService {
  SuggestionRepo repo;
  SuggestionService(this.repo);

  Future<Result<Error, FeedItem?>> seekingSuggestion(File file) async {
    return await repo.seekingSuggestion(file);
  }


  Future<Result<Error, List<FeedItem>?>> getSuggestionsList(String? lastId) async {
    Result<Error, List<FeedItem>?> res = await repo.getSuggestionsList(lastId);
    return res;
  }

  Future<Result<Error, bool>> deleteRecordById(String id) async {
    return await repo.deleteRecordById(id);
  }
}
