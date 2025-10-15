// lib/main.dart

import 'theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/bottom_nav_bar.dart';
import 'services/notification_service.dart';
import 'models/subscription_model.dart';
import 'provider/simplified_subscription_provider.dart';
import 'provider/simplified_gamification.dart';

final NotificationService notificationService = NotificationService();

Future<void> main() async {
  // --- Standard Initializations ---
  WidgetsFlutterBinding.ensureInitialized();

  // Load theme preference BEFORE anything else
  final prefs = await SharedPreferences.getInstance();
  final savedThemeIndex = prefs.getInt('themeModeIndex') ?? 0;

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: savedThemeIndex == 1 ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: savedThemeIndex == 1 ? Brightness.light : Brightness.dark,
    ),
  );

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  // --- Service and Database Initializations ---
  await Hive.initFlutter();
  Hive.registerAdapter(SubscriptionAdapter());
  await notificationService.init();
  await notificationService.requestPermissions();

  // --- Provider Initializations ---
  final subscriptionProvider = SimplifiedSubscriptionProvider();
  await subscriptionProvider.init();

  final gamificationProvider = SimplifiedGamification();

  // --- Run the App ---
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: subscriptionProvider),
        ChangeNotifierProvider.value(value: gamificationProvider),
      ],
      child: MyApp(initialThemeIndex: savedThemeIndex),
    ),
  );
}

class MyApp extends StatefulWidget {
  final int initialThemeIndex;

  const MyApp({super.key, required this.initialThemeIndex});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late int _themeModeIndex;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _themeModeIndex = widget.initialThemeIndex; // Use the pre-loaded theme
    WidgetsBinding.instance.addObserver(this);
    _finishLoading();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final gamification = Provider.of<SimplifiedGamification>(context, listen: false);
        gamification.checkDailyActivity();
      } catch (e) {
        // Provider not ready yet, will be called from HomePage
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    // This can be used to sync with system theme changes if desired in the future
  }

  void _finishLoading() {
    // Small delay to ensure providers are ready
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _updateSystemUI() {
    final isDark = _themeModeIndex == 1;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  void _toggleTheme() async {
    HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeModeIndex = (_themeModeIndex + 1) % 3;
      prefs.setInt('themeModeIndex', _themeModeIndex);
    });
    _updateSystemUI();
  }

  ThemeData getCurrentTheme() {
    switch (_themeModeIndex) {
      case 0:
        return lightThemeData;
      case 1:
        return darkThemeData;
      case 2:
        return barbieThemeData;
      default:
        return lightThemeData;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = getCurrentTheme();

    if (_isLoading) {
      final Color loadingColor = currentTheme.colorScheme.primary;
      final Color textColor = currentTheme.textTheme.bodyLarge?.color ?? Colors.black;

      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: currentTheme, // Use current theme for loading screen
        home: Scaffold(
          backgroundColor: currentTheme.scaffoldBackgroundColor,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 120,
                  height: 120,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.eco_rounded,
                    size: 80,
                    color: loadingColor,
                  ),
                ),
                const SizedBox(height: 24),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  "Tr'Hack",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: loadingColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Loading your subscriptions...",
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Tr'Hack",
      theme: currentTheme,
      home: BottomNavBar(
        onToggleTheme: _toggleTheme,
        onChangeAccentColor: (Color value) {},
        onResetAccentColor: () {},
        currentThemeIndex: _themeModeIndex,
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            padding: MediaQuery.of(context).padding,
          ),
          child: child!,
        );
      },
    );
  }
}