import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/hotel/data/repositories/hotel_repository.dart';
import 'features/hotel/presentation/cubit/hotel_cubit.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/booking/data/repositories/booking_repository.dart';
import 'features/booking/presentation/cubit/booking_cubit.dart';
import 'features/payment/data/repositories/payment_repository.dart';
import 'features/payment/presentation/cubit/payment_cubit.dart';
import 'features/profile/data/repositories/profile_repository.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  final client = SupabaseConfig.client;

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(client));
  getIt.registerLazySingleton<HotelRepository>(() => HotelRepository(client));
  getIt.registerLazySingleton<BookingRepository>(() => BookingRepository(client));
  getIt.registerLazySingleton<PaymentRepository>(() => PaymentRepository(client));
  getIt.registerLazySingleton<ProfileRepository>(() => ProfileRepository(client));

  // Cubits
  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepository>()));
  getIt.registerFactory<HotelCubit>(() => HotelCubit(getIt<HotelRepository>()));
  getIt.registerFactory<HomeCubit>(() => HomeCubit(getIt<HotelRepository>()));
  getIt.registerFactory<BookingCubit>(() => BookingCubit(getIt<BookingRepository>()));
  getIt.registerFactory<PaymentCubit>(() => PaymentCubit(getIt<PaymentRepository>()));
}
