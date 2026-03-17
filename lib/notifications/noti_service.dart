import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotiService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // Inicializar las notificaciones
  Future<void> initNotification() async {
    if (_isInitialized) return;

    // Inicializar zona horaria
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    // Configuración de Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/logo1');

    // Configuración de iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // Configuración general
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    // Inicializar el plugin
    await notificationsPlugin.initialize(initializationSettings);
    _isInitialized = true;
  }

  // Detalles de la notificación
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id',
        'Preguntas del Día',
        channelDescription: 'Notificaciones diarias para responder preguntas',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  // Mostrar una notificación inmediata
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    await notificationsPlugin.show(id, title, body, notificationDetails());
  }

  // Programar una notificación para una hora específica
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    // Si la hora ya pasó hoy, programa para mañana
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // repetitivo diario
    );
  }

  // Programar las notificaciones desde las 20:00 hasta las 23:00
  Future<void> scheduleDailyReminders() async {
    const String title = "Recordatorio de preguntas";
    const String body = "Por favor, conteste sus preguntas del día.";

    for (int i = 0; i <= 3; i++) {
      int hour = 20 + i; // 20, 21, 22, 23
      await scheduleNotification(
        id: 100 + i,
        title: title,
        body: body,
        hour: hour,
        minute: 0,
      );
    }
  }

  // Cancelar todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }

  // Cancelar solo las notificaciones diarias programadas (20:00 a 23:00)
  Future<void> cancelDailyNotification() async {
    for (int i = 0; i <= 3; i++) {
      int id = 100 + i;
      await notificationsPlugin.cancel(id);
    }
  }
}
