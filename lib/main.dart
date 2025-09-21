import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/post_provider.dart';
import 'providers/user_provider.dart';
import 'providers/sneaker_provider.dart';
import 'screens/intro_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/post_detail_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/followers_screen.dart';
import 'screens/following_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with proper configuration
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization skipped: $e');
    print('App will use direct backend authentication');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => SneakerProvider()),
      ],
      child: MaterialApp(
        title: 'SoleHead',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/intro': (context) => const IntroScreen(),
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/post':
              final postId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => PostDetailScreen(postId: postId),
              );
            case '/user-profile':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => UserProfileScreen(
                  userId: args['userId'],
                  initialUser: args['initialUser'],
                ),
              );
            case '/followers':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => FollowersScreen(
                  userId: args['userId'],
                  username: args['username'],
                  isCurrentUser: args['isCurrentUser'] ?? false,
                ),
              );
            case '/following':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => FollowingScreen(
                  userId: args['userId'],
                  username: args['username'],
                  isCurrentUser: args['isCurrentUser'] ?? false,
                ),
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool? _isFirstTime;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('isFirstTime') ?? true;
      setState(() {
        _isFirstTime = isFirstTime;
        _isLoading = false;
      });
      print('AuthWrapper: First time user: $isFirstTime');
    } catch (e) {
      print('AuthWrapper: Error checking first time: $e');
      setState(() {
        _isFirstTime = true; // Default to showing intro if error
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('AuthWrapper: build() called');

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00F5FF)),
          ),
        ),
      );
    }

    // If it's the first time, show intro screen
    if (_isFirstTime == true) {
      print('AuthWrapper: First time user - showing IntroScreen');
      return const IntroScreen();
    }

    // Not first time, check authentication
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        print(
          'AuthWrapper: Consumer builder called - isLoggedIn: ${authProvider.isLoggedIn}',
        );

        if (authProvider.isLoggedIn) {
          print('AuthWrapper: User logged in - showing HomeScreen');
          return const HomeScreen();
        } else {
          print('AuthWrapper: User not logged in - showing LoginScreen');
          return const LoginScreen();
        }
      },
    );
  }
}
