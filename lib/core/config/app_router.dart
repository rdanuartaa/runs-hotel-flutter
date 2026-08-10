import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
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
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../injection_container.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final authState = context.read<AuthCubit>().state;
      final isAuth = authState is AuthAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth && isAuthRoute) return '/';
      return null;
    },
    routes: [
      // Auth routes (no bottom nav)
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
        ],
      ),

      // Full screen routes (no bottom nav)
      GoRoute(
        path: '/hotel/:id',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<HotelCubit>(),
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
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
  );
}

class _MainShell extends StatelessWidget {
  final Widget child;
  const _MainShell({required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location == '/') return 0;
    if (location == '/hotels') return 1;
    if (location == '/bookings') return 2;
    if (location == '/profile') return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
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
          selectedIndex: _currentIndex(context),
          onDestinationSelected: (index) {
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
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: AppColors.primarySurface,
          destinations: const [
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
