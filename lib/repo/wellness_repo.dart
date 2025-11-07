

import 'dart:convert';
import 'dart:typed_data';

import 'package:nuitri_pilot_frontend/core/common_result.dart';
import 'package:nuitri_pilot_frontend/core/network.dart';
import 'package:nuitri_pilot_frontend/core/storage/keys.dart';
import 'package:nuitri_pilot_frontend/core/storage/local_storage.dart';
import 'package:nuitri_pilot_frontend/data/data.dart';

class WellnessRepo{

  Future<InterfaceResult<UserChronic>> getUserChronics() async {
    Uint8List? value = LocalStorage().get(LOCAL_TOKEN_KEY);
    String token = utf8.decode(Uint8List.fromList(value!));
    InterfaceResult<dynamic> res =  await post('/wellness/user_chronics', {}, (json) => json.toString(), token:token);

    return InterfaceResult(UserChronic.fromJson(res.value!));
  }
}