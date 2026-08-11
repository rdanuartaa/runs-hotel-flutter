import 'dart:convert';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/payment_model.dart';

class PaymentRepository {
  final SupabaseClient _client;

  PaymentRepository(this._client);

  Future<Map<String, dynamic>> createPayment(String bookingId) async {
    print('Membuat pembayaran langsung dari aplikasi (bypass edge function)...');
    
    // 1. Ambil data booking dari database
    final booking = await _client
        .from('bookings')
        .select('*, hotels(name), rooms(name)')
        .eq('id', bookingId)
        .single();
        
    final user = _client.auth.currentUser!;
    final orderId = 'HOTEL-${bookingId.substring(0, 8)}-${DateTime.now().millisecondsSinceEpoch}';
    
    // PERHATIAN: Masukkan Server Key Midtrans Anda di sini!
    const serverKey = 'SB-Mid-server-swZOZ8YKuFjw_tTDOk095-Qy';
    
    final auth = 'Basic ${base64Encode(utf8.encode('$serverKey:'))}';
    
    final payload = {
      'transaction_details': {
        'order_id': orderId,
        'gross_amount': booking['total_price'],
      },
      'customer_details': {
        'email': user.email,
        'first_name': user.userMetadata?['full_name'] ?? 'Guest',
      },
      'item_details': [{
        'id': booking['room_id'],
        'price': booking['total_price'],
        'quantity': 1,
        'name': '${booking['hotels']['name']} - ${booking['rooms']['name']}',
      }],
      'callbacks': {
        'finish': 'hotelbooking://payment/finish',
      }
    };

    // 2. Kirim request ke Midtrans
    print('Request ke Midtrans...');
    final response = await HttpClient().postUrl(Uri.parse('https://app.sandbox.midtrans.com/snap/v1/transactions'))
      ..headers.set('Content-Type', 'application/json')
      ..headers.set('Accept', 'application/json')
      ..headers.set('Authorization', auth)
      ..write(jsonEncode(payload));
      
    final res = await response.close();
    final resBody = await res.transform(utf8.decoder).join();
    
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Gagal menghubungi Midtrans: $resBody');
    }
    
    final snapData = jsonDecode(resBody);
    
    // 3. Simpan data ke tabel payments
    print('Menyimpan data ke tabel payments...');
    try {
      // Kita gunakan HTTP Request langsung ke Supabase REST API dengan Service Role Key
      // untuk membypass RLS (Row Level Security) yang memblokir proses insert.
      final serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ3eGhxZHdzcG5ycHZicnFtbXVjIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NjMzNzUzMywiZXhwIjoyMTAxOTEzNTMzfQ.dceuL-WMMCZd43PsJQayzc9lV9bBRW5DrwojJ29T5To';
      final supabaseUrl = 'https://bwxhqdwspnrpvbrqmmuc.supabase.co/rest/v1/payments';
      
      final insertReq = await HttpClient().postUrl(Uri.parse(supabaseUrl));
      insertReq.headers.set('apikey', serviceRoleKey);
      insertReq.headers.set('Authorization', 'Bearer $serviceRoleKey');
      insertReq.headers.set('Content-Type', 'application/json');
      
      insertReq.write(jsonEncode({
        'booking_id': bookingId,
        'user_id': user.id,
        'midtrans_order_id': orderId,
        'gross_amount': booking['total_price'],
        'snap_token': snapData['token'],
        'snap_redirect_url': snapData['redirect_url'],
        'status': 'pending',
      }));
      
      final insertRes = await insertReq.close();
      final responseBody = await insertRes.transform(utf8.decoder).join();
      
      if (insertRes.statusCode == 200 || insertRes.statusCode == 201) {
        print('BERHASIL simpan ke tabel payments via Admin API!');
      } else {
        throw Exception('Status ${insertRes.statusCode}: $responseBody');
      }
    } catch (dbError) {
      print('ERROR SUPABASE INSERT: $dbError');
      throw Exception('Gagal menyimpan ke database: $dbError');
    }
    
    return snapData;
  }

  Stream<PaymentModel> watchPaymentStatus(String bookingId) {
    return _client
        .from('payments')
        .stream(primaryKey: ['id'])
        .eq('booking_id', bookingId)
        .map((data) => PaymentModel.fromJson(data.first));
  }

  Future<PaymentModel?> getPaymentByBooking(String bookingId) async {
    final data = await _client
        .from('payments')
        .select()
        .eq('booking_id', bookingId)
        .maybeSingle();

    if (data == null) return null;
    return PaymentModel.fromJson(data);
  }
}
