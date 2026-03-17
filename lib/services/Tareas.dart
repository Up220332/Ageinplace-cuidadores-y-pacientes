import 'dart:async';
import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../services/notificaciones.dart';

var CodUsuarioCuidador;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('icono_notificacion');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> showNotification() async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    'IMP Tracker',
    'IMP Tracker',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidNotificationDetails,
  );

  await flutterLocalNotificationsPlugin.show(
      1,
      'Titulo de notificacion',
      'Esta es una notificación de prueba para mostrar en el canal. Los quiero mucho.',
      notificationDetails);
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  // const AndroidNotificationChannel channel = AndroidNotificationChannel(
  //   'IMP  Tracker', // id
  //   'IMP  Tracker', // title
  //   description: 'Esto es una prueba', // description
  //   importance: Importance.low, // importance must be at low or higher level
  // );

  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //     FlutterLocalNotificationsPlugin();

  // if (Platform.isIOS || Platform.isAndroid) {
  //   await flutterLocalNotificationsPlugin.initialize(
  //     const InitializationSettings(
  //       iOS: DarwinInitializationSettings(),
  //       android: AndroidInitializationSettings('ic_bg_service_small'),
  //     ),
  //   );
  // }

  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //         AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,

      // notificationChannelId: 'my_foreground',
      // initialNotificationTitle: 'AWESOME SERVICE',
      // initialNotificationContent: 'Initializing',
      // foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fe
    ),
  );

  service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // bring to foreground
  Timer.periodic(const Duration(seconds: 10), (timer) async {
    if (service is AndroidServiceInstance) {
      // Acceso directo a UsuarioCuidador
      print('object');
      await getIntegerFromMemory().then((value) {
        CodUsuarioCuidador = value!;
      });

      print('Valor actual de UsuarioCuidador: $CodUsuarioCuidador');
      CheckAlarm(CodUsuarioCuidador);
    }

    /// you can see this log in logcat
    print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');
  });
}

Future<int?> getIntegerFromMemory() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? storedValue = prefs.getInt('CodUsuarioCuidador');
  print('Integer retrieved from memory: $storedValue');
  return storedValue;
}
