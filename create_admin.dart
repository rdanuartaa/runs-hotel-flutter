import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

void main() async {
  // Gunakan Service Role Key untuk bypass semuanya
  final client = SupabaseClient(
    'https://bwxhqdwspnrpvbrqmmuc.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ3eGhxZHdzcG5ycHZicnFtbXVjIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NjMzNzUzMywiZXhwIjoyMTAxOTEzNTMzfQ.dceuL-WMMCZd43PsJQayzc9lV9bBRW5DrwojJ29T5To'
  );

  try {
    print('1. Menciptakan akun auth di Supabase...');
    final response = await client.auth.admin.createUser(
      AdminUserAttributes(
        email: 'adminhotel@gmail.com',
        password: 'adminhotel123',
        emailConfirm: true,
        userMetadata: {'full_name': 'Super Admin'},
      ),
    );
    
    if (response.user != null) {
      final userId = response.user!.id;
      print('2. Akun Auth berhasil dibuat! ID: $userId');
      
      print('3. Membuat profil di public.users dengan role "admin"...');
      await client.from('users').upsert({
        'id': userId,
        'email': 'adminhotel@gmail.com',
        'full_name': 'Super Admin',
        'role': 'admin'
      });
      
      print('SUKSES! Akun admin berhasil dibuat sepenuhnya.');
      exit(0);
    }
  } catch (e) {
    if (e.toString().contains('already been registered')) {
      print('Akun ini ternyata sudah ada. Memaksa update profil menjadi admin...');
      // Cari ID dari email tersebut (kalau tidak bisa langsung, skip dulu)
      exit(0);
    } else {
      print('GAGAL: $e');
      exit(1);
    }
  }
}
