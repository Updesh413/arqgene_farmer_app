import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/domain/entities/user_entity.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'injection_container.dart' as di;
import 'screens/language_screen.dart'; 
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();
  await di.init();

  // Check if this is the first time the app is running
  final prefs = await SharedPreferences.getInstance();
  final bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

  runApp(
    EasyLocalization(
      supportedLocales: [
        Locale('en'), // English
        Locale('hi'), // Hindi
        Locale('ta'), // Tamil
        // Locale('pa'), // Punjabi
      ],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      startLocale: Locale('en'), // Default start
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => di.sl<AuthProvider>()),
        ],
        child: MyApp(isFirstRun: isFirstRun),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isFirstRun;
  const MyApp({required this.isFirstRun});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Localization Hooks
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      title: 'AgriApp',
      theme: ThemeData(primarySwatch: Colors.green),

      // LOGIC:
      // 1. If First Run -> Go to Language Screen
      // 2. If Not First Run -> Check Auth (Login or Home)
      home: isFirstRun ? LanguageScreen() : AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // Logic to determine where to go
  Future<Widget> _getLandingPage(UserEntity? user) async {
    if (user == null) {
      return LoginScreen();
    } else {
      // User is logged in, check if profile is done
      final prefs = await SharedPreferences.getInstance();
      bool isProfileDone = prefs.getBool('isProfileCompleted') ?? false;

      if (isProfileDone) {
        return HomeScreen();
      } else {
        return ProfileScreen();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserEntity?>(
      stream: context.read<AuthProvider>().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Use FutureBuilder to handle the Async SharedPreferences check
        return FutureBuilder<Widget>(
          future: _getLandingPage(snapshot.data),
          builder: (context, landingSnapshot) {
            if (landingSnapshot.connectionState == ConnectionState.done) {
              return landingSnapshot.data!;
            }
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          },
        );
      },
    );
  }
}
