import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    // MENGGUNAKAN JALUR BELAKANG (Admin API) UNTUK BYPASS EMAIL VERIFICATION
    final adminClient = SupabaseClient(
      'https://bwxhqdwspnrpvbrqmmuc.supabase.co', 
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ3eGhxZHdzcG5ycHZicnFtbXVjIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NjMzNzUzMywiZXhwIjoyMTAxOTEzNTMzfQ.dceuL-WMMCZd43PsJQayzc9lV9bBRW5DrwojJ29T5To'
    );

    try {
      final response = await adminClient.auth.admin.createUser(
        AdminUserAttributes(
          email: email,
          password: password,
          emailConfirm: true, // INI YANG BIKIN LANGSUNG AKTIF
          userMetadata: {'full_name': fullName},
        ),
      );

      if (response.user == null) {
        throw Exception('Registrasi gagal. Silakan coba lagi.');
      }

      // Login biasa untuk mendapatkan session di aplikasi
      return await signInWithEmail(email: email, password: password);
    } catch (e) {
      if (e.toString().contains('already registered')) {
        throw Exception('Email ini sudah terdaftar.');
      }
      throw Exception('Gagal mendaftar: $e');
    }
  }

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Email atau password salah.');
    }

    // Periksa apakah profil di public.users sudah ada
    final existing = await _client
        .from('users')
        .select()
        .eq('id', response.user!.id)
        .maybeSingle();

    // Jika belum ada (misal dibuat manual dari Dashboard), buatkan profil default
    if (existing == null) {
      await _client.from('users').insert({
        'id': response.user!.id,
        'email': response.user!.email,
        'full_name': response.user!.userMetadata?['full_name'] ?? 'User',
        'role': response.user!.email == 'adminhotel@gmail.com' ? 'admin' : 'guest',
      });
    }

    return await getUserProfile(response.user!.id);
  }

  Future<UserModel?> signInWithGoogle() async {
    const webClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

    final googleSignIn = GoogleSignIn(
      serverClientId: webClientId,
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null || idToken == null) {
      throw Exception('Google sign-in gagal.');
    }

    final response = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    if (response.user == null) {
      throw Exception('Google sign-in gagal.');
    }

    // Check if user profile exists, create if not
    final existing = await _client
        .from('users')
        .select()
        .eq('id', response.user!.id)
        .maybeSingle();

    if (existing == null) {
      await _client.from('users').insert({
        'id': response.user!.id,
        'email': response.user!.email,
        'full_name': response.user!.userMetadata?['full_name'] ??
            googleUser.displayName ??
            'User',
        'avatar_url': googleUser.photoUrl,
      });
    }

    return await getUserProfile(response.user!.id);
  }

  Future<UserModel> getUserProfile(String userId) async {
    final data = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (data == null) {
      final user = _client.auth.currentUser;
      if (user != null && user.id == userId) {
        // Coba insert profil jika belum ada
        try {
          await _client.from('users').insert({
            'id': userId,
            'email': user.email ?? '',
            'full_name': user.userMetadata?['full_name'] ?? 'User',
          });
          final newData = await _client.from('users').select().eq('id', userId).single();
          return UserModel.fromJson(newData);
        } catch (e) {
          throw Exception('Gagal membuat profil: $e');
        }
      }
      throw Exception('Profil tidak ditemukan');
    }

    return UserModel.fromJson(data);
  }

  Future<UserModel> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (fullName != null) updates['full_name'] = fullName;
    if (phone != null) updates['phone'] = phone;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    await _client.from('users').update(updates).eq('id', userId);

    return await getUserProfile(userId);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }
}
