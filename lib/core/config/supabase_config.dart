import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // TODO: Replace with your actual Supabase credentials
  // For production, use --dart-define or .env
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://bwxhqdwspnrpvbrqmmuc.supabase.co',
  );
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ3eGhxZHdzcG5ycHZicnFtbXVjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYzMzc1MzMsImV4cCI6MjEwMTkxMzUzM30.0zMryF_TycZbmvxEJnXB577Bc1IYsvnMPKEDgTl9gm4',
  );

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
