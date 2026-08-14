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
  
  final payments = await client.from('payments').select('id, user_id, status').order('updated_at', ascending: false).limit(3);
  
  for (var payment in payments) {
    print('Payment: ${payment['id']} User: ${payment['user_id']} Status: ${payment['status']}');
    final user = await client.from('users').select('fcm_token').eq('id', payment['user_id']).maybeSingle();
    print('  FCM Token: ${user?['fcm_token'] != null ? 'EXISTS' : 'MISSING'}');
  }
}
