import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'services/prayer_time_service.dart';
import 'services/azan_service.dart';
import 'services/settings_service.dart';
import 'screens/home_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit = DarwinInitializationSettings();
  const initSettings =
      InitializationSettings(android: androidInit, iOS: iosInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en'), Locale('ku')],
      path: 'assets/localization',
      fallbackLocale: const Locale('ar'),
      child: const AdhanApp(),
    ),
  );
}

class AdhanApp extends StatelessWidget {
  const AdhanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsService()),
        ChangeNotifierProvider(create: (_) => PrayerTimeService()),
        ChangeNotifierProvider(create: (_) => AzanService()),
      ],
      child: MaterialApp(
        title: 'مواقيت الأذان',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: ThemeData(
          primaryColor: const Color(0xFF0F6B5C),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0F6B5C),
            brightness: Brightness.light,
          ),
          fontFamily: 'Cairo',
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0F6B5C),
            brightness: Brightness.dark,
          ),
          fontFamily: 'Cairo',
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
