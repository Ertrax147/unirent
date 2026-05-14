import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Mock screens imports
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/properties/presentation/screens/properties_screen.dart';
import '../../features/properties/presentation/screens/property_detail_screen.dart';
import '../../features/properties/presentation/screens/publish_property_screen.dart';
import '../../features/rentals/presentation/screens/my_requests_screen.dart';
import '../../features/rentals/presentation/screens/incoming_requests_screen.dart';
import '../../features/reviews/presentation/screens/reviews_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/role-selection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/properties',
      builder: (context, state) => const PropertiesScreen(),
      routes: [
        GoRoute(
          path: 'publish',
          builder: (context, state) => const PublishPropertyScreen(),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return PropertyDetailScreen(propertyId: id);
          },
          routes: [
            GoRoute(
              path: 'reviews',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return ReviewsScreen(propertyId: id);
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/rentals/my-requests',
      builder: (context, state) => const MyRequestsScreen(),
    ),
    GoRoute(
      path: '/rentals/incoming',
      builder: (context, state) => const IncomingRequestsScreen(),
    ),
  ],
);
