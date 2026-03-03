import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorage{

  final cache = FlutterSecureStorage();

  LocalStorage._internal();

  static final LocalStorage _instance = LocalStorage._internal();

  factory LocalStorage(){
    return _instance;
  }

  Future<void> put(String key, String value, {bool persist = false}) async => await cache.write(key: key, value: value);

  Future<String?> get(String key) async => await cache.read(key:key);

  Future<bool> containsKey(String key) async => await cache.containsKey(key:key);

  Future<void> del(String key) async => await cache.delete(key: key);
}