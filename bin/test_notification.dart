import 'dart:io';
import 'dart:convert';
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
  
  // Ambil sembarang user_id dari tabel users yang punya fcm_token
  final users = await client.from('users').select('id, fcm_token').not('fcm_token', 'is', null).limit(1);
  if (users.isEmpty) {
    print('Tidak ada user dengan fcm_token');
    return;
  }
  
  final userId = users.first['id'];
  print('Mengirim ke user: $userId');
  
  try {
    final response = await client.functions.invoke('send-push-notification', body: {
      'userId': userId,
      'title': 'Test Title',
      'body': 'Test Body',
      'dataPayload': {'type': 'test'}
    });
    
    print('Response status: ${response.status}');
    print('Response data: ${response.data}');
  } catch (e) {
    print('Error invoke: $e');
  }
}
