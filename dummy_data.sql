-- 1. Matikan RLS sementara untuk memudahkan insert data dummy (jika belum dimatikan)
ALTER TABLE public.hotels DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.rooms DISABLE ROW LEVEL SECURITY;

-- 2. Hapus data lama agar tidak duplikat jika dijalankan berulang
DELETE FROM public.rooms;
DELETE FROM public.hotels;

-- 3. Masukkan Data Dummy Hotel
INSERT INTO public.hotels (id, name, description, address, city, province, latitude, longitude, star_rating, thumbnail_url, avg_rating, total_reviews, facilities, is_active)
VALUES
('a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'Grand Antares Hotel', 'Hotel mewah di pusat kota dengan pemandangan indah dan fasilitas yang sangat lengkap. Cocok untuk perjalanan bisnis maupun liburan.', 'Jl. Sudirman No. 123', 'Jakarta', 'DKI Jakarta', -6.2088, 106.8456, 5, 'https://images.unsplash.com/photo-1566073771259-6a8506099945?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', 4.8, 120, ARRAY['WiFi', 'Pool', 'Gym', 'Restaurant', 'Parking'], TRUE),

('b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e', 'Bali Resort & Spa', 'Resort pinggir pantai yang tenang cocok untuk liburan keluarga. Nikmati sunset langsung dari kamar Anda.', 'Jl. Pantai Kuta No. 45', 'Badung', 'Bali', -8.7185, 115.1686, 4, 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', 4.6, 340, ARRAY['WiFi', 'Pool', 'Spa', 'Restaurant', 'Beach Access'], TRUE),

('c3d4e5f6-a7b8-9c0d-1e2f-3a4b5c6d7e8f', 'Bandung City View', 'Penginapan sejuk di dataran tinggi Bandung dengan city view memukau, dikelilingi oleh alam yang asri.', 'Jl. Setiabudi No. 88', 'Bandung', 'Jawa Barat', -6.8286, 107.6046, 3, 'https://images.unsplash.com/photo-1542314831-c6a4d27ce6a2?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', 4.2, 85, ARRAY['WiFi', 'Parking', 'Restaurant'], TRUE);

-- 4. Masukkan Data Dummy Kamar (Rooms)
INSERT INTO public.rooms (hotel_id, name, description, room_type, price_per_night, max_guests, total_rooms, thumbnail_url, amenities, is_available)
VALUES
-- Kamar untuk Grand Antares
('a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'Deluxe City View', 'Kamar luas dengan jendela besar menampilkan pemandangan kota Jakarta.', 'deluxe', 1200000, 2, 10, 'https://images.unsplash.com/photo-1611892440504-42a792e24d32?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', ARRAY['AC', 'TV', 'Mini Bar', 'Bathtub'], TRUE),
('a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'Executive Suite', 'Suite mewah dengan ruang tamu terpisah dan fasilitas eksklusif.', 'suite', 2500000, 2, 5, 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', ARRAY['AC', 'TV', 'Mini Bar', 'Bathtub', 'Living Room'], TRUE),

-- Kamar untuk Bali Resort & Spa
('b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e', 'Ocean View Standard', 'Kamar nyaman yang menghadap langsung ke lautan luas.', 'standard', 850000, 2, 20, 'https://images.unsplash.com/photo-1590490360182-c33d57733427?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', ARRAY['AC', 'TV', 'Balcony'], TRUE),
('b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e', 'Presidential Suite', 'Suite paling mewah di pinggir pantai dengan kolam renang pribadi.', 'presidential', 5500000, 4, 2, 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', ARRAY['AC', 'Private Pool', 'Kitchen', 'Living Room', 'Bathtub'], TRUE),

-- Kamar untuk Bandung City View
('c3d4e5f6-a7b8-9c0d-1e2f-3a4b5c6d7e8f', 'Standard Room', 'Kamar minimalis dan sejuk untuk istirahat setelah berkeliling kota.', 'standard', 450000, 2, 15, 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', ARRAY['AC', 'TV', 'WiFi'], TRUE);
