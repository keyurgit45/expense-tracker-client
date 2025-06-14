import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static void validateConfig() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      if (kDebugMode) {
        print('Warning: Supabase configuration is missing.');
        print('Please set SUPABASE_URL and SUPABASE_ANON_KEY in your .env file.');
        print('Copy .env.example to .env and fill in your Supabase credentials.');
      }
    }
  }
}