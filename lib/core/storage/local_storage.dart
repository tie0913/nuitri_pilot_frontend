import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorage{

  final cache = FlutterSecureStorage();

  LocalStorage._internal();

  static final LocalStorage _instance = LocalStorage._internal();

  factory LocalStorage(){
    return _instance;
  }

  void put(String key, String value, {bool persist = false}) => cache.write(key: key, value: value);

  Future<String?> get(String key) => cache.read(key:key);

  Future<bool> containsKey(String key) => cache.containsKey(key:key);

  Future<void> del(String key) => cache.delete(key: key);
}