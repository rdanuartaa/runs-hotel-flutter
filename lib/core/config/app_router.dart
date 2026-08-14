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
import '../../features/admin/presentation/screens/admin_booking_detail_screen.dart';
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
import '../../features/admin/presentation/screens/admin_scanner_screen.dart';
import '../../injection_container.dart';

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
            path: '/admin/bookings/detail',
            builder: (context, state) {
              BookingModel booking;
              bool isFromScanner = false;
              
              if (state.extra is Map<String, dynamic>) {
                final extra = state.extra as Map<String, dynamic>;
                booking = extra['booking'] as BookingModel;
                isFromScanner = extra['isFromScanner'] as bool? ?? false;
              } else {
                booking = state.extra as BookingModel;
              }
              
              return BlocProvider(
                create: (_) => getIt<BookingCubit>(),
                child: AdminBookingDetailScreen(booking: booking, isFromScanner: isFromScanner),
              );
            },
          ),
          GoRoute(
            path: '/admin/scanner',
            builder: (context, state) => BlocProvider(
              create: (_) => getIt<BookingCubit>()..loadAllBookings(),
              child: const AdminScannerScreen(),
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
      if (location == '/admin/scanner') return 2;
      if (location == '/admin/reports') return 3;
      if (location == '/profile') return 4;
      return 0;
    } else {
      if (location == '/') return 0;
      if (location == '/bookings') return 1;
      if (location == '/hotels') return 2;
      if (location == '/profile') return 3;
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final isAdmin = authState is AuthAuthenticated && authState.user.isAdmin;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final navBgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final selectedColor = isDark ? const Color(0xFF56A8E5) : const Color(0xFF2171C4);

    return Scaffold(
      backgroundColor: bgColor,
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBgColor,
          border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
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
                  context.go('/admin/scanner');
                case 3:
                  context.go('/admin/reports');
                case 4:
                  context.go('/profile');
              }
            } else {
              switch (index) {
                case 0:
                  context.go('/');
                case 1:
                  context.go('/bookings');
                case 2:
                  context.go('/hotels');
                case 3:
                  context.go('/profile');
              }
            }
          },
          backgroundColor: navBgColor,
          elevation: 0,
          indicatorColor: Colors.transparent, // Remove pill background
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: isAdmin 
          ? [
              NavigationDestination(
                icon: const Icon(Icons.hotel_outlined, color: Colors.grey),
                selectedIcon: Icon(Icons.hotel, color: selectedColor),
                label: 'Kelola Hotel',
              ),
              NavigationDestination(
                icon: const Icon(Icons.list_alt_outlined, color: Colors.grey),
                selectedIcon: Icon(Icons.list_alt, color: selectedColor),
                label: 'Pesanan',
              ),
              NavigationDestination(
                icon: const Icon(Icons.qr_code_scanner_outlined, color: Colors.grey),
                selectedIcon: Icon(Icons.qr_code_scanner, color: selectedColor),
                label: 'Scan QR',
              ),
              NavigationDestination(
                icon: const Icon(Icons.attach_money_outlined, color: Colors.grey),
                selectedIcon: Icon(Icons.attach_money, color: selectedColor),
                label: 'Laporan',
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline, color: Colors.grey),
                selectedIcon: Icon(Icons.person_rounded, color: selectedColor),
                label: 'Profil Admin',
              ),
            ]
          : [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined, color: Colors.grey),
                selectedIcon: Icon(Icons.home, color: selectedColor),
                label: 'Home',
              ),
              NavigationDestination(
                icon: const Icon(Icons.book_outlined, color: Colors.grey),
                selectedIcon: Icon(Icons.book, color: selectedColor),
                label: 'Booking',
              ),
              NavigationDestination(
                icon: const Icon(Icons.bed_outlined, color: Colors.grey),
                selectedIcon: Icon(Icons.bed, color: selectedColor),
                label: 'Rooms',
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline, color: Colors.grey),
                selectedIcon: Icon(Icons.person, color: selectedColor),
                label: 'Account',
              ),
            ],
        ),
      ),
    );
  }
}
