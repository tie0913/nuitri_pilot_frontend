import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl => dotenv.env['API_BASE_URL']!;
  static String get env => dotenv.env['APP_ENV']!;
}