import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final envFile = File('.env');
  final lines = await envFile.readAsLines();
  String url = '';
  String key = '';
  for (var line in lines) {
    if (line.startsWith('SUPABASE_URL=')) url = line.split('=')[1];
    if (line.startsWith('SUPABASE_ANON_KEY=')) key = line.split('=')[1];
  }
  
  final client = SupabaseClient(url, key);
  
  final user = await client.from('users').select('fcm_token').eq('id', 'de738695-5a26-4ec7-b0d3-b106630b0dae').single();
  print('FCM Token for Admin: ${user['fcm_token']}');
}
