import 'package:ageinplace/SplashScreen/splash_screen.dart';
import 'package:ageinplace/localization/locales.dart';
import 'package:ageinplace/notifications/noti_service.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sizer/sizer.dart';

import '../route/route_generator.dart';

import 'dart:io';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if ((Platform.isAndroid || Platform.isIOS)) {
    // Estos paquetes solo funcionan para Android e IoS
    final notiService = NotiService();
    await notiService.initNotification();

    await AndroidAlarmManager.initialize();
  }

  await initializeDateFormatting('en_ES', null);

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await FlutterLocalization.instance.ensureInitialized();

  runApp(ImpTracker());
}

class ImpTracker extends StatefulWidget {
  const ImpTracker({super.key});

  @override
  State<ImpTracker> createState() => _ImpTrackerState();
}

class _ImpTrackerState extends State<ImpTracker> {
  final FlutterLocalization localization = FlutterLocalization.instance;

  @override
  void initState() {
    super.initState();
    configureLocalization();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'AgeInPlace',
          home: SplashScreen(), 
          supportedLocales: localization.supportedLocales,
          localizationsDelegates: localization.localizationsDelegates,
          onGenerateRoute: RouteGenerator.GenerateRoute,
        );
      },
    );
  }

void configureLocalization() {
  localization.init(mapLocales: locales, initLanguageCode: "es");
  localization.onTranslatedLanguage = (Locale? locale) {
    setState(() {}); 
  };
}

  void onTranslatedLanguage(Locale? locale) {
    setState(() {}); 
  }
}