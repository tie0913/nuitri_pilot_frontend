import 'dart:typed_data';

class LocalStorage{

  Map<String, Uint8List> cache = {};

  LocalStorage._internal();

  static final LocalStorage _instance = LocalStorage._internal();

  factory LocalStorage(){
    return _instance;
  }

  void put(String key, Uint8List value, {bool persist = false}) => cache.addAll({key: value});

  Uint8List? get(String key) => cache[key];

  bool containsKey(String key) => cache.containsKey(key);

  Uint8List? del(String key) => cache.remove(key);
}