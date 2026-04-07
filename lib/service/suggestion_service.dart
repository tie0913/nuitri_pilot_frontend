import 'dart:io';

import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'package:nuitri_pilot_frontend/core/compression_util.dart';
import 'package:nuitri_pilot_frontend/data/data.dart';
import 'package:nuitri_pilot_frontend/repo/suggestion_repo.dart';

class SuggestionService {
  SuggestionRepo repo;
  final ImageCompressionService compressionService;
  SuggestionService(this.repo, this.compressionService);

  Future<Result<Error, FeedItem?>> seekingSuggestion(File file) async {
    File? compressedFile;
    try{
        compressedFile = await compressionService.compressImage(file);
        return await repo.seekingSuggestion(compressedFile);
    }on Exception {
      return Err(AppError("Compressing Image has error"));
    }finally{
      await compressedFile?.delete();
    }
  }


  Future<Result<Error, List<FeedItem>?>> getSuggestionsList(String? lastId) async {
    Result<Error, List<FeedItem>?> res = await repo.getSuggestionsList(lastId);
    return res;
  }

  Future<Result<Error, bool>> deleteRecordById(String id) async {
    return await repo.deleteRecordById(id);
  }
}
