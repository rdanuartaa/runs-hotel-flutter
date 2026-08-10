import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository(this._client);

  Future<String> uploadAvatar(String userId, File file) async {
    final fileExt = file.path.split('.').last;
    final fileName = '$userId/avatar.$fileExt';

    await _client.storage
        .from('avatars')
        .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

    return _client.storage.from('avatars').getPublicUrl(fileName);
  }

  Future<void> updateProfile({
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
  }
}
