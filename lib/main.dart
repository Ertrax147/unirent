import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Try to initialize Firebase. If google-services.json is missing, this will throw.
  // We catch it so the app can still run in "UI-only" mock mode if needed.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  runApp(const ProviderScope(child: UniRentApp()));
}

class UniRentApp extends ConsumerWidget {
  const UniRentApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'UniRent',
      theme: AppTheme.lightTheme,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
