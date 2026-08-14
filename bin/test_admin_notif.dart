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
  
  // Kirim ke Admin
  final userId = 'de738695-5a26-4ec7-b0d3-b106630b0dae';
  
  try {
    final response = await client.functions.invoke('send-push-notification', body: {
      'userId': userId,
      'title': 'Test Push Notif Admin',
      'body': 'Ini adalah test notifikasi untuk admin. Jika ini muncul, berarti sistem push notification berjalan lancar.',
      'dataPayload': {'type': 'test'}
    });
    
    print('Response status: ${response.status}');
  } catch (e) {
    print('Error invoke: $e');
  }
}
