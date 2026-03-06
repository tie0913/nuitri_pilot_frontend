import 'dart:io';

import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'package:nuitri_pilot_frontend/core/di.dart';
import 'package:nuitri_pilot_frontend/data/data.dart';
import 'package:nuitri_pilot_frontend/repo/suggestion_repo.dart';

class SuggestionService {
  final SuggestionRepo repo;

  SuggestionService(this.repo);

  /// Ask AI for a single suggestion based on image file.
  /// Returns FeedItem on success, null on error (error shown by messageHandler).
  Future<FeedItem?> seekingSuggestion(File file) async {
    final InterfaceResult<dynamic> res = await repo.seekingSuggestion(file);

    if (DI.I.messageHandler.isErr(res)) {
      DI.I.messageHandler.handleErr(res);
      return null;
    }

    final v = res.value;
    if (v == null) {
      // Backend returned success but no data
      // Keep it simple: treat as error at UI level by returning null.
      return null;
    }

    return FeedItem.fromJson(v);
  }

  /// Get list of past suggestions (pagination by lastId).
  /// Returns [] on error or if no data.
  Future<List<FeedItem>> getSuggestionsList(String? lastId) async {
    final InterfaceResult<dynamic> res = await repo.getSuggestionsList(lastId);

    if (DI.I.messageHandler.isErr(res)) {
      DI.I.messageHandler.handleErr(res);
      return [];
    }

    final v = res.value;
    if (v == null) return [];

    if (v is List) {
      return v.map((e) => FeedItem.fromJson(e)).toList();
    }

    // If backend returns something unexpected, don’t crash UI.
    return [];
  }
}
