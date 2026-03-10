import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageCompressionService {

  Future<File> compressImage(File file) async {

    final tempDir = await getTemporaryDirectory();

    final targetPath =
        "${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
      minWidth: 1280,
      minHeight: 1280,
    );

    if (result == null) {
      throw Exception("Image compression failed");
    }

    return File(result.path);
  }
}