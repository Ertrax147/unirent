import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/mfa_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/admin/admin_screen.dart';
import '../../features/listing/presentation/screens/listing_detail_screen.dart';
import '../../features/listing/presentation/screens/publish_listing_screen.dart';
import '../../features/listing/rate_user_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/role_selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/mfa',
        builder: (context, state) => const MfaScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminScreen(),
      ),
      GoRoute(
        path: '/listing/:id',
        builder: (context, state) {
          final idStr = state.pathParameters['id'] ?? '0';
          return ListingDetailScreen(index: int.tryParse(idStr) ?? 0);
        },
      ),
      GoRoute(
        path: '/publish',
        builder: (context, state) => const PublishListingScreen(),
      ),
      GoRoute(
        path: '/rate/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId'] ?? '';
          return RateUserScreen(userId: userId);
        },
      ),
    ],
    redirect: (context, state) {
      // In a real app, logic based on authState (authenticated vs unauthenticated) goes here.
      return null;
    },
  );
});
