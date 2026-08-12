import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/hotel/presentation/screens/hotel_list_screen.dart';
import '../../features/hotel/presentation/screens/hotel_detail_screen.dart';
import '../../features/hotel/presentation/cubit/hotel_cubit.dart';
import '../../features/hotel/data/models/hotel_model.dart';
import '../../features/hotel/data/models/room_model.dart';
import '../../features/booking/presentation/screens/booking_form_screen.dart';
import '../../features/booking/presentation/screens/booking_summary_screen.dart';
import '../../features/booking/presentation/screens/booking_history_screen.dart';
import '../../features/booking/presentation/cubit/booking_cubit.dart';
import '../../features/booking/data/models/booking_model.dart';
import '../../features/payment/presentation/screens/payment_screen.dart';
import '../../features/payment/presentation/screens/payment_webview_screen.dart';
import '../../features/payment/presentation/screens/payment_status_screen.dart';
import '../../features/payment/presentation/cubit/payment_cubit.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/admin/presentation/screens/admin_hotels_screen.dart';
import '../../features/admin/presentation/screens/admin_add_hotel_screen.dart';
import '../../features/admin/presentation/screens/admin_rooms_screen.dart';
import '../../features/admin/presentation/screens/admin_add_room_screen.dart';
import '../../features/admin/presentation/screens/admin_bookings_screen.dart';
import '../../features/admin/presentation/screens/admin_reports_screen.dart';
import '../../injection_container.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(getIt<AuthCubit>().stream),
    redirect: (context, state) {
      final authState = getIt<AuthCubit>().state;
      final isAuth = authState is AuthAuthenticated;
      final isInitial = authState is AuthInitial;
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      final isSplash = state.matchedLocation == '/splash';

      if (isInitial) {
        return isSplash ? null : '/splash';
      }

      if (!isAuth && !isAuthRoute) return '/login';
      
      if (isAuth) {
        final isAdmin = authState.user.isAdmin;
        
        // Prevent logged in user from going to login/register or splash
        if (isAuthRoute || isSplash) {
          return isAdmin ? '/admin' : '/';
        }
        
        // Prevent admin from going to customer home/search/booking
        if (isAdmin && (state.matchedLocation == '/' || state.matchedLocation == '/hotels' || state.matchedLocation == '/bookings')) {
          return '/admin';
        }
        
        // Prevent customer from going to admin pages
        if (!isAdmin && state.matchedLocation.startsWith('/admin')) {
          return '/';
        }
      }
      return null;
    },
    routes: [
      // Auth routes (no bottom nav)
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => _MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => BlocProvider(
              create: (_) => getIt<HomeCubit>(),
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/hotels',
            builder: (context, state) => BlocProvider(
              create: (_) => getIt<HotelCubit>(),
              child: const HotelListScreen(),
            ),
          ),
          GoRoute(
            path: '/bookings',
            builder: (context, state) => BlocProvider(
              create: (_) => getIt<BookingCubit>(),
              child: const BookingHistoryScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/admin',
            builder: (context, state) => BlocProvider(
              create: (_) => getIt<HotelCubit>()..loadHotels(),
              child: const AdminHotelsScreen(),
            ),
          ),
          GoRoute(
            path: '/admin/bookings',
            builder: (context, state) => BlocProvider(
              create: (_) => getIt<BookingCubit>()..loadAllBookings(),
              child: const AdminBookingsScreen(),
            ),
          ),
          GoRoute(
            path: '/admin/reports',
            builder: (context, state) => BlocProvider(
              create: (_) => getIt<BookingCubit>()..loadAllBookings(),
              child: const AdminReportsScreen(),
            ),
          ),
        ],
      ),

      // Full screen routes (no bottom nav)
      GoRoute(
        path: '/admin/add-hotel',
        builder: (context, state) {
          final hotel = state.extra as HotelModel?;
          return BlocProvider(
            create: (_) => getIt<HotelCubit>(),
            child: AdminAddHotelScreen(hotel: hotel),
          );
        },
      ),
      GoRoute(
        path: '/admin/hotels/:id/rooms',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<HotelCubit>()..loadHotelDetail(state.pathParameters['id']!),
          child: AdminRoomsScreen(hotelId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/admin/hotels/:id/add-room',
        builder: (context, state) {
          final room = state.extra as RoomModel?;
          return BlocProvider(
            create: (_) => getIt<HotelCubit>(),
            child: AdminAddRoomScreen(hotelId: state.pathParameters['id']!, room: room),
          );
        },
      ),
      GoRoute(
        path: '/hotel/:id',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<HotelCubit>()..loadHotelDetail(state.pathParameters['id']!),
          child: HotelDetailScreen(hotelId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/booking',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return BlocProvider(
            create: (_) => getIt<BookingCubit>(),
            child: BookingFormScreen(
              hotel: extra['hotel'] as HotelModel,
              room: extra['room'] as RoomModel,
            ),
          );
        },
      ),
      GoRoute(
        path: '/booking-summary',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return BlocProvider(
            create: (_) => getIt<BookingCubit>(),
            child: BookingSummaryScreen(
              hotel: extra['hotel'] as HotelModel,
              room: extra['room'] as RoomModel,
              checkIn: extra['checkIn'] as DateTime,
              checkOut: extra['checkOut'] as DateTime,
              guests: extra['guests'] as int,
              totalPrice: extra['totalPrice'] as int,
              specialRequest: extra['specialRequest'] as String?,
            ),
          );
        },
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return BlocProvider(
            create: (_) => getIt<PaymentCubit>(),
            child: PaymentScreen(booking: extra['booking'] as BookingModel),
          );
        },
      ),
      GoRoute(
        path: '/payment-webview',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return PaymentWebViewScreen(
            snapRedirectUrl: extra['redirectUrl'] as String,
            bookingId: extra['bookingId'] as String,
          );
        },
      ),
      GoRoute(
        path: '/payment-status',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return PaymentStatusScreen(status: extra['status'] as String);
        },
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
    ],
  );
}

class _MainShell extends StatelessWidget {
  final Widget child;
  const _MainShell({required this.child});

  int _currentIndex(BuildContext context, bool isAdmin) {
    final location = GoRouterState.of(context).matchedLocation;
    if (isAdmin) {
      if (location == '/admin') return 0;
      if (location == '/admin/bookings') return 1;
      if (location == '/admin/reports') return 2;
      if (location == '/profile') return 3;
      return 0;
    } else {
      if (location == '/') return 0;
      if (location == '/hotels') return 1;
      if (location == '/bookings') return 2;
      if (location == '/profile') return 3;
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final isAdmin = authState is AuthAuthenticated && authState.user.isAdmin;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex(context, isAdmin),
          onDestinationSelected: (index) {
            if (isAdmin) {
              switch (index) {
                case 0:
                  context.go('/admin');
                case 1:
                  context.go('/admin/bookings');
                case 2:
                  context.go('/admin/reports');
                case 3:
                  context.go('/profile');
              }
            } else {
              switch (index) {
                case 0:
                  context.go('/');
                case 1:
                  context.go('/hotels');
                case 2:
                  context.go('/bookings');
                case 3:
                  context.go('/profile');
              }
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: AppColors.primarySurface,
          destinations: isAdmin 
          ? const [
              NavigationDestination(
                icon: Icon(Icons.hotel_outlined),
                selectedIcon: Icon(Icons.hotel, color: AppColors.primary),
                label: 'Kelola Hotel',
              ),
              NavigationDestination(
                icon: Icon(Icons.list_alt_outlined),
                selectedIcon: Icon(Icons.list_alt, color: AppColors.primary),
                label: 'Pesanan',
              ),
              NavigationDestination(
                icon: Icon(Icons.attach_money_outlined),
                selectedIcon: Icon(Icons.attach_money, color: AppColors.primary),
                label: 'Laporan',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
                label: 'Profil Admin',
              ),
            ]
          : const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search_rounded, color: AppColors.primary),
                label: 'Cari',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmark_border_rounded),
                selectedIcon: Icon(Icons.bookmark_rounded, color: AppColors.primary),
                label: 'Booking',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
                label: 'Profil',
              ),
            ],
        ),
      ),
    );
  }
}
