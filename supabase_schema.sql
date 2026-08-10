CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT NOT NULL,
  phone TEXT,
  avatar_url TEXT,
  role TEXT DEFAULT 'guest' CHECK (role IN ('guest', 'admin')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own profile" ON public.users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.users FOR UPDATE USING (auth.uid() = id);

CREATE TABLE public.hotels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  address TEXT NOT NULL,
  city TEXT NOT NULL,
  province TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  star_rating INT CHECK (star_rating BETWEEN 1 AND 5),
  thumbnail_url TEXT,
  avg_rating NUMERIC(2,1) DEFAULT 0,
  total_reviews INT DEFAULT 0,
  facilities TEXT[] DEFAULT '{}',
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.hotels ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Hotels are viewable by everyone" ON public.hotels FOR SELECT USING (is_active = TRUE);
CREATE POLICY "Only admins can manage hotels" ON public.hotels FOR ALL
  USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin'));

CREATE TABLE public.hotel_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  hotel_id UUID REFERENCES public.hotels(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.hotel_images ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Hotel images viewable by everyone" ON public.hotel_images FOR SELECT USING (TRUE);

CREATE TABLE public.rooms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  hotel_id UUID REFERENCES public.hotels(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  room_type TEXT NOT NULL CHECK (room_type IN ('standard','deluxe','suite','presidential')),
  price_per_night BIGINT NOT NULL,
  max_guests INT DEFAULT 2,
  total_rooms INT DEFAULT 1,
  thumbnail_url TEXT,
  amenities TEXT[] DEFAULT '{}',
  is_available BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Rooms viewable by everyone" ON public.rooms FOR SELECT USING (is_available = TRUE);

CREATE TABLE public.bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  hotel_id UUID REFERENCES public.hotels(id),
  room_id UUID REFERENCES public.rooms(id),
  check_in DATE NOT NULL,
  check_out DATE NOT NULL,
  total_guests INT DEFAULT 1,
  total_nights INT GENERATED ALWAYS AS (check_out - check_in) STORED,
  total_price BIGINT NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending','confirmed','checked_in','checked_out','cancelled')),
  special_request TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own bookings" ON public.bookings FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create bookings" ON public.bookings FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE TABLE public.payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id UUID REFERENCES public.bookings(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.users(id),
  midtrans_order_id TEXT UNIQUE NOT NULL,
  midtrans_transaction_id TEXT,
  payment_type TEXT,
  gross_amount BIGINT NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending','capture','settlement','deny','cancel','expire','refund')),
  snap_token TEXT,
  snap_redirect_url TEXT,
  payment_response JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own payments" ON public.payments FOR SELECT USING (auth.uid() = user_id);

CREATE TABLE public.reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  hotel_id UUID REFERENCES public.hotels(id) ON DELETE CASCADE,
  booking_id UUID REFERENCES public.bookings(id),
  rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, booking_id)
);

ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Reviews viewable by everyone" ON public.reviews FOR SELECT USING (TRUE);
CREATE POLICY "Users can create own review" ON public.reviews FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Buat bucket untuk hotel images
INSERT INTO storage.buckets (id, name, public) VALUES ('hotel-images', 'hotel-images', TRUE);
INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', TRUE);

-- Storage policies
CREATE POLICY "Hotel images publicly accessible"
  ON storage.objects FOR SELECT USING (bucket_id = 'hotel-images');

CREATE POLICY "Admins can upload hotel images"
  ON storage.objects FOR INSERT WITH CHECK (
    bucket_id = 'hotel-images'
    AND EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Users can upload own avatar"
  ON storage.objects FOR INSERT WITH CHECK (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = auth.uid()::TEXT
  );

CREATE POLICY "Avatars publicly accessible"
  ON storage.objects FOR SELECT USING (bucket_id = 'avatars');
