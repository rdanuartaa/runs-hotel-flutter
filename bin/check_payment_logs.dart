import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final envFile = File('.env');
  final lines = await envFile.readAsLines();
  String url = '';
  String key = '';
  for (var line in lines) {
    if (line.startsWith('SUPABASE_URL=')) url = line.split('=')[1];
    if (line.startsWith('SUPABASE_ANON_KEY=')) key = line.split('=')[1]; // Wait, I need service role key or just query payments
  }
  
  final client = SupabaseClient(url, key);
  final response = await client.from('payments').select('id, status, payment_type, updated_at').order('updated_at', ascending: false).limit(5);
  
  for (var payment in response) {
    print(payment);
  }
}
