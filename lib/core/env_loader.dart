import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvLoader {
  static Future<void> init() async {
    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    await dotenv.load(fileName: '.env.$env');
  }
}