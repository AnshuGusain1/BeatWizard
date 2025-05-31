import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'screens/landing_page.dart';
import 'screens/profile_page.dart';
import 'screens/profile_display_page.dart';
import 'screens/upload_page.dart';
import 'screens/explore_page.dart';
import 'screens/search_page.dart';
import 'screens/auth/signin_page.dart';
import 'screens/strategy_dashboard.dart';
import 'widgets/main_layout.dart';
import 'services/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const BeatWizardApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingPage(),
    ),
    GoRoute(
      path: '/auth/signin',
      builder: (context, state) => const SignInPage(),
    ),
    // Strategy Dashboard - main page after login
    GoRoute(
      path: '/strategy',
      builder: (context, state) => MainLayout(
        currentRoute: '/strategy',
        child: const StrategyDashboard(),
      ),
    ),
    // Profile creation (no nav bar)
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
    // Profile display (with nav bar)
    GoRoute(
      path: '/profile/display',
      builder: (context, state) => MainLayout(
        currentRoute: '/profile',
        child: const ProfileDisplayPage(),
      ),
    ),
    // Authenticated routes with navigation bar
    GoRoute(
      path: '/explore',
      builder: (context, state) => MainLayout(
        currentRoute: '/explore',
        child: const ExplorePage(),
      ),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => MainLayout(
        currentRoute: '/search',
        child: const SearchPage(),
      ),
    ),
    GoRoute(
      path: '/upload',
      builder: (context, state) => MainLayout(
        currentRoute: '/upload',
        child: const UploadPage(),
      ),
    ),
  ],
);

class NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  const NoAnimationPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Use a FadeTransition with zero duration for an instant transition
    return FadeTransition(
      opacity: Tween<double>(begin: 1.0, end: 1.0).animate(animation), // Keep opacity at 1.0
      child: child,
    );
  }
}

class BeatWizardApp extends StatelessWidget {
  const BeatWizardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BeatWizard',
      routerConfig: _router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        // Add these lines for page transitions
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: NoAnimationPageTransitionsBuilder(),
            TargetPlatform.iOS: NoAnimationPageTransitionsBuilder(),
            TargetPlatform.linux: NoAnimationPageTransitionsBuilder(),
            TargetPlatform.macOS: NoAnimationPageTransitionsBuilder(),
            TargetPlatform.windows: NoAnimationPageTransitionsBuilder(),
          },
        ),
      ),
    );
  }
}
