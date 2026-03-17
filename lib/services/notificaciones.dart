import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import '../base_de_datos/influx.dart';
import '../base_de_datos/postgres.dart';
import '../Cuidador/screen_Paciente.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Icializa las funciones
Future<void> initNotifications() async {
  //Icono
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('icono_notificacion');
  //Icializacion IOS
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> showNotificacion(Pacientes paciente, String TipoAlarma) async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
        'IMP  Tracker',
        'IMP  Tracker',
        importance: Importance.max,
        priority: Priority.high,
      );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidNotificationDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    2,
    TipoAlarma,
    'El Usuario ${paciente.Nombre} ${paciente.Apellido1} ${paciente.Apellido2} esta en apuros, por favor revise su estado.',
    notificationDetails,
  );
}

Future<void> CheckAlarm(int CodUsuarioCuidador) async {
  List<Pacientes> TodoPacientesList = [];
  List<Casa> CasaList = [];
  List<Pacientes> PacientesList = [];
  List<AlarmaData> AlarmsList = [];

  print('object');

  var Dbdata = await DBPostgres().DBGetPacientesViviendasCuidador(
    CodUsuarioCuidador,
    'null',
  );
  String Estado;

  for (var p in Dbdata[0]) {
    CasaList.add(Casa(p[0], p[1], p[2], p[3], p[4]));
  }
  for (var p in Dbdata[1]) {
    if (p[9] == null) {
      Estado = 'Activo';
    } else {
      Estado = 'Inactivo';
    }
    TodoPacientesList.add(
      Pacientes(
        p[0],
        p[1],
        p[2],
        p[3],
        p[4],
        p[5],
        p[6],
        p[7],
        p[8],
        p[9],
        p[10],
        p[11],
        p[12],
        p[13],
        p[14],
        p[15],
        Estado,
      ),
    );
  }

  for (Casa casa in CasaList) {
    for (Pacientes paciente in TodoPacientesList) {
      if (paciente.CodCasa == casa.CodCasa) {
        PacientesList.add(paciente);
      }
    }
  }

  print('Successfully Fetched data');

  for (Pacientes paciente in PacientesList) {
    print('object');
    // DateTime now = DateTime.now();
    List<AlarmasPaciente> AlarmasPacienteList = [];

    var startDate = DateTime.now().subtract(Duration(seconds: 55));
    var endDate = DateTime.now();
    var startFormatted = DateFormat(
      "yyyy-MM-dd'T'HH:mm:ss'Z'",
    ).format(startDate.toUtc());
    var endFormatted = DateFormat(
      "yyyy-MM-dd'T'HH:mm:ss'Z'",
    ).format(endDate.toUtc());
    var CodPacienteWearable = paciente.CodPacienteWearable;
    //error
    AlarmsList = await InfluxDBService().GetAlarm2(
      CodPacienteWearable,
      startFormatted,
      endFormatted,
      "30s",
    );
    print(AlarmsList);
    if (AlarmsList[0].Caida == 1 && AlarmsList[0].Boton == 0) {
      await showNotificacion(paciente, 'Alarma caída');
    } else if (AlarmsList[0].Boton == 1 && AlarmsList[0].Caida == 0) {
      await showNotificacion(paciente, 'Botón pánico');
    } else if (AlarmsList[0].Boton == 1 && AlarmsList[0].Caida == 1) {
      await showNotificacion(paciente, 'Paciente en peligro');
    }
  }
}

class Pacientes {
  final int CodPaciente;
  final String Nombre;
  final String Apellido1;
  final String Apellido2;
  final String FechaNacimiento;
  final String Telefono;
  final String Email;
  final String Organizacion;
  final String DesVarSocial;
  final String VarSocial;
  final String DesVarSanitaria;
  final String VarSanitaria;
  final DateTime F_ALTA;
  final DateTime? F_BAJA_Usuario;
  final int? CodCasa;
  final String? CodPacienteWearable;
  final String Estado;

  Pacientes(
    this.CodPaciente,
    this.Nombre,
    this.Apellido1,
    this.Apellido2,
    this.FechaNacimiento,
    this.Telefono,
    this.Email,
    this.Organizacion,
    this.DesVarSocial,
    this.VarSocial,
    this.DesVarSanitaria,
    this.VarSanitaria,
    this.F_ALTA,
    this.F_BAJA_Usuario,
    this.CodCasa,
    this.CodPacienteWearable,
    this.Estado,
  );
}

class Casa {
  final int CodUsuarioCuidador;
  final int CodCasa;
  final String Dirrecion;
  final double Latitud;
  final double Longitud;

  Casa(
    this.CodUsuarioCuidador,
    this.CodCasa,
    this.Dirrecion,
    this.Latitud,
    this.Longitud,
  );
}
