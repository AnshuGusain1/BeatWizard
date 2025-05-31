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

// Service to track visited routes
class RouteVisitTracker {
  static final RouteVisitTracker _instance = RouteVisitTracker._internal();
  factory RouteVisitTracker() => _instance;
  RouteVisitTracker._internal();

  final Set<String> _visitedRoutes = <String>{};

  bool hasVisited(String route) {
    return _visitedRoutes.contains(route);
  }

  void markAsVisited(String route) {
    _visitedRoutes.add(route);
  }

  void reset() {
    _visitedRoutes.clear();
  }
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const LandingPage(),
    ),
    GoRoute(
      path: '/auth/signin',
      name: 'signin',
      builder: (context, state) => const SignInPage(),
    ),
    // Strategy Dashboard - main page after login
    GoRoute(
      path: '/strategy',
      name: 'strategy',
      builder: (context, state) => MainLayout(
        currentRoute: '/strategy',
        child: const StrategyDashboard(),
      ),
    ),
    // Profile creation (no nav bar)
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfilePage(),
    ),
    // Profile display (with nav bar)
    GoRoute(
      path: '/profile/display',
      name: 'profile_display',
      builder: (context, state) => MainLayout(
        currentRoute: '/profile',
        child: const ProfileDisplayPage(),
      ),
    ),
    // Authenticated routes with navigation bar
    GoRoute(
      path: '/explore',
      name: 'explore',
      builder: (context, state) => MainLayout(
        currentRoute: '/explore',
        child: const ExplorePage(),
      ),
    ),
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) => MainLayout(
        currentRoute: '/search',
        child: const SearchPage(),
      ),
    ),
    GoRoute(
      path: '/upload',
      name: 'upload',
      builder: (context, state) => MainLayout(
        currentRoute: '/upload',
        child: const UploadPage(),
      ),
    ),
  ],
);

class ConditionalAnimationPageTransitionsBuilder
    extends PageTransitionsBuilder {
  const ConditionalAnimationPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Use the route name or fall back to the route path
    final routeIdentifier =
        route.settings.name ?? route.settings.arguments?.toString() ?? '';
    final tracker = RouteVisitTracker();

    // Check if this route has been visited before
    final hasBeenVisited = tracker.hasVisited(routeIdentifier);

    // Mark this route as visited for next time
    tracker.markAsVisited(routeIdentifier);

    if (hasBeenVisited) {
      // No animation for subsequent visits
      return child;
    } else {
      // Animate on first visit - using a smooth fade and slide animation
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 0.1), // Slide up slightly
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: FadeTransition(
          opacity: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          )),
          child: child,
        ),
      );
    }
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
        // Updated page transitions theme
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android:
                ConditionalAnimationPageTransitionsBuilder(),
            TargetPlatform.iOS: ConditionalAnimationPageTransitionsBuilder(),
            TargetPlatform.linux: ConditionalAnimationPageTransitionsBuilder(),
            TargetPlatform.macOS: ConditionalAnimationPageTransitionsBuilder(),
            TargetPlatform.windows:
                ConditionalAnimationPageTransitionsBuilder(),
          },
        ),
      ),
    );
  }
}
