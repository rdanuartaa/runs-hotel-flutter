import 'dart:convert';
import 'dart:io';

void main() async {
  final url = 'https://bwxhqdwspnrpvbrqmmuc.supabase.co/auth/v1/admin/users';
  final serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ3eGhxZHdzcG5ycHZicnFtbXVjIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NjMzNzUzMywiZXhwIjoyMTAxOTEzNTMzfQ.dceuL-WMMCZd43PsJQayzc9lV9bBRW5DrwojJ29T5To';
  
  final client = HttpClient();
  try {
    print('Membuat akun admin di Supabase Auth...');
    final request = await client.postUrl(Uri.parse(url));
    request.headers.set('apikey', serviceRoleKey);
    request.headers.set('Authorization', 'Bearer $serviceRoleKey');
    request.headers.set('Content-Type', 'application/json');
    
    final payload = jsonEncode({
      'email': 'adminhotel2@gmail.com',
      'password': 'adminhotel123',
      'email_confirm': true,
      'user_metadata': {'full_name': 'Super Admin'}
    });
    
    request.write(payload);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(responseBody);
      final userId = jsonResponse['id'];
      print('BERHASIL: Akun Auth terbuat dengan ID: $userId');
      
      print('Membuat profil admin di tabel users...');
      final restUrl = 'https://bwxhqdwspnrpvbrqmmuc.supabase.co/rest/v1/users';
      final insertReq = await client.postUrl(Uri.parse(restUrl));
      insertReq.headers.set('apikey', serviceRoleKey);
      insertReq.headers.set('Authorization', 'Bearer $serviceRoleKey');
      insertReq.headers.set('Content-Type', 'application/json');
      insertReq.headers.set('Prefer', 'resolution=merge-duplicates');
      
      final insertPayload = jsonEncode({
        'id': userId,
        'email': 'adminhotel2@gmail.com',
        'full_name': 'Super Admin',
        'role': 'admin'
      });
      insertReq.write(insertPayload);
      final insertRes = await insertReq.close();
      final insertResBody = await insertRes.transform(utf8.decoder).join();
      print('BERHASIL: Profil dibuat (Status: ${insertRes.statusCode})');
      print('SELESAI! Silakan coba login sekarang.');
    } else {
      print('GAGAL: ${response.statusCode}');
      print('Alasan: $responseBody');
    }
  } catch (e) {
    print('Error fatal: $e');
  } finally {
    client.close();
  }
}
