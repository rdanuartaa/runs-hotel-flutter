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
  final response = await client.from('hotels').select('id, name, city, latitude, longitude');
  
  for (var hotel in response) {
    print('Hotel: ${hotel['name']}');
    print('City: ${hotel['city']}');
    print('Lat: ${hotel['latitude']}');
    print('Lon: ${hotel['longitude']}');
    print('---');
  }
}
