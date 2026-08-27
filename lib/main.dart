// lib/main.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';
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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'provider/user_profile_provider.dart';
import 'pages/onboarding_page.dart';

final NotificationService notificationService = NotificationService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Note: .env not loaded (using secure environment configuration)");
  }

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

  await Hive.initFlutter();
  Hive.registerAdapter(SubscriptionAdapter());
  await notificationService.init();

  final subscriptionProvider = SimplifiedSubscriptionProvider();
  await subscriptionProvider.init();

  final gamificationProvider = SimplifiedGamification();

  final userProfileProvider = UserProfileProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: subscriptionProvider),
        ChangeNotifierProvider.value(value: gamificationProvider),
        ChangeNotifierProvider.value(value: userProfileProvider),
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
    _themeModeIndex = widget.initialThemeIndex;
    WidgetsBinding.instance.addObserver(this);
    _finishLoading();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final gamification = Provider.of<SimplifiedGamification>(context, listen: false);
        gamification.checkDailyActivity();
      } catch (e) {
        // Provider not ready yet
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {}

  void _finishLoading() {
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
      // ... (Loading screen remains the same) ...
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: currentTheme,
        home: Scaffold(
          // ...
        ),
      );
    }

    // ✅ ADD: Watch the UserProfileProvider to get onboarding status
    final hasCompletedOnboarding =
        context.watch<UserProfileProvider>().hasCompletedOnboarding;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "SubFlow",
      theme: currentTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: hasCompletedOnboarding
          ? BottomNavBar(
        key: bottomNavBarKey,
        onToggleTheme: _toggleTheme,
        onChangeAccentColor: (Color value) {},
        onResetAccentColor: () {},
        currentThemeIndex: _themeModeIndex,
      )
          : const OnboardingPage(),
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

