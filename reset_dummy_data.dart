import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final supabaseUrl = 'https://bwxhqdwspnrpvbrqmmuc.supabase.co';
  final serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ3eGhxZHdzcG5ycHZicnFtbXVjIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NjMzNzUzMywiZXhwIjoyMTAxOTEzNTMzfQ.dceuL-WMMCZd43PsJQayzc9lV9bBRW5DrwojJ29T5To';

  final supabase = SupabaseClient(supabaseUrl, serviceRoleKey);
  
  print('Menghapus data lama...');
  await supabase.from('payments').delete().neq('id', '00000000-0000-0000-0000-000000000000');
  await supabase.from('bookings').delete().neq('id', '00000000-0000-0000-0000-000000000000');
  await supabase.from('rooms').delete().neq('id', '00000000-0000-0000-0000-000000000000');
  await supabase.from('hotels').delete().neq('id', '00000000-0000-0000-0000-000000000000');
  
  print('Memasukkan data dummy...');
  
  final h1 = 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d';
  final h2 = 'b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e';
  final h3 = 'c3d4e5f6-a7b8-9c0d-1e2f-3a4b5c6d7e8f';

  await supabase.from('hotels').insert([
    {
      'id': h1,
      'name': 'Grand Antares Hotel',
      'description': 'Hotel mewah di pusat kota dengan pemandangan indah dan fasilitas yang sangat lengkap. Cocok untuk perjalanan bisnis maupun liburan.',
      'address': 'Jl. Sudirman No. 123',
      'city': 'Jakarta',
      'province': 'DKI Jakarta',
      'latitude': -6.2088,
      'longitude': 106.8456,
      'star_rating': 5,
      'thumbnail_url': 'https://loremflickr.com/800/600/hotel,building?lock=1',
      'avg_rating': 4.8,
      'total_reviews': 120,
      'facilities': ['WiFi', 'Pool', 'Gym', 'Restaurant', 'Parking'],
      'is_active': true
    },
    {
      'id': h2,
      'name': 'Bali Resort & Spa',
      'description': 'Resort pinggir pantai yang tenang cocok untuk liburan keluarga. Nikmati sunset langsung dari kamar Anda.',
      'address': 'Jl. Pantai Kuta No. 45',
      'city': 'Badung',
      'province': 'Bali',
      'latitude': -8.7185,
      'longitude': 115.1686,
      'star_rating': 4,
      'thumbnail_url': 'https://loremflickr.com/800/600/resort,beach?lock=2',
      'avg_rating': 4.6,
      'total_reviews': 340,
      'facilities': ['WiFi', 'Pool', 'Spa', 'Restaurant', 'Beach Access'],
      'is_active': true
    },
    {
      'id': h3,
      'name': 'Bandung City View',
      'description': 'Penginapan sejuk di dataran tinggi Bandung dengan city view memukau, dikelilingi oleh alam yang asri.',
      'address': 'Jl. Setiabudi No. 88',
      'city': 'Bandung',
      'province': 'Jawa Barat',
      'latitude': -6.8286,
      'longitude': 107.6046,
      'star_rating': 3,
      'thumbnail_url': 'https://loremflickr.com/800/600/hotel,city?lock=3',
      'avg_rating': 4.2,
      'total_reviews': 85,
      'facilities': ['WiFi', 'Parking', 'Restaurant'],
      'is_active': true
    }
  ]);

  await supabase.from('rooms').insert([
    {
      'hotel_id': h1,
      'name': 'Deluxe City View',
      'description': 'Kamar luas dengan jendela besar menampilkan pemandangan kota Jakarta.',
      'room_type': 'deluxe',
      'price_per_night': 1200000,
      'max_guests': 2,
      'total_rooms': 10,
      'thumbnail_url': 'https://loremflickr.com/800/600/bedroom,hotel?lock=11',
      'amenities': ['AC', 'TV', 'Mini Bar', 'Bathtub'],
      'is_available': true
    },
    {
      'hotel_id': h1,
      'name': 'Executive Suite',
      'description': 'Suite mewah dengan ruang tamu terpisah dan fasilitas eksklusif.',
      'room_type': 'suite',
      'price_per_night': 2500000,
      'max_guests': 2,
      'total_rooms': 5,
      'thumbnail_url': 'https://loremflickr.com/800/600/bedroom,hotel?lock=12',
      'amenities': ['AC', 'TV', 'Mini Bar', 'Bathtub', 'Living Room'],
      'is_available': true
    },
    {
      'hotel_id': h2,
      'name': 'Ocean View Standard',
      'description': 'Kamar nyaman yang menghadap langsung ke lautan luas.',
      'room_type': 'standard',
      'price_per_night': 850000,
      'max_guests': 2,
      'total_rooms': 20,
      'thumbnail_url': 'https://loremflickr.com/800/600/bedroom,resort?lock=13',
      'amenities': ['AC', 'TV', 'Balcony'],
      'is_available': true
    },
    {
      'hotel_id': h2,
      'name': 'Presidential Suite',
      'description': 'Suite paling mewah di pinggir pantai dengan kolam renang pribadi.',
      'room_type': 'presidential',
      'price_per_night': 5500000,
      'max_guests': 4,
      'total_rooms': 2,
      'thumbnail_url': 'https://loremflickr.com/800/600/bedroom,luxury?lock=14',
      'amenities': ['AC', 'Private Pool', 'Kitchen', 'Living Room', 'Bathtub'],
      'is_available': true
    },
    {
      'hotel_id': h3,
      'name': 'Standard Room',
      'description': 'Kamar minimalis dan sejuk untuk istirahat setelah berkeliling kota.',
      'room_type': 'standard',
      'price_per_night': 450000,
      'max_guests': 2,
      'total_rooms': 15,
      'thumbnail_url': 'https://loremflickr.com/800/600/bedroom,cozy?lock=15',
      'amenities': ['AC', 'TV', 'WiFi'],
      'is_available': true
    }
  ]);
  
  print('✅ SELESAI! Data berhasil dikembalikan ke Dummy Data.');
  exit(0);
}
