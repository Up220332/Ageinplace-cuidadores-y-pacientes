import 'dart:async';
import 'dart:core';
import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:geodesy/geodesy.dart';
import 'package:intl/intl.dart';

import '../Cuidador/screen_Paciente.dart';
import '../Cuidador/screen_Pacientes.dart';
import '../models/wearable.dart';
import '../base_de_datos/influx.dart';
import '../base_de_datos/postgres.dart';

class TiempoRealPage extends StatefulWidget {
  final Pacientes paciente;
  final Wearable wearable;
  final List<Habitaciones> habitaciones;
  final List<Casa> casas;

  const TiempoRealPage({
    super.key,
    required this.paciente,
    required this.wearable,
    required this.habitaciones,
    required this.casas,
  });

  @override
  _TiempoRealPageState createState() => _TiempoRealPageState();
}

class _TiempoRealPageState extends State<TiempoRealPage> {
  List<AlarmasPaciente> AlarmasPacienteList = [];
  int nivelBateria = 0;
  int nivelHumedad = 0;
  int nivelTemperatura = 0;
  var roomList = <RoomData>[];
  var LongList = <LongData>[];
  var LatList = <LatData>[];
  var AlarmsList = <AlarmaData>[];
  String ubicacionActual = '';
  Timer? timer;
  late LatLng coordinates;
  late final MapController mapController;
  DateTime now = DateTime.now();
  bool switchValue = false;
  List<Coordenas> routeCoordinates = [];
  List<Marker> markers = [];
  var AlarmsListStat = <AlarmaData2>[];
  List<AlarmaData2> AlamrHistory = [];
  var AlarmsListHistory = <AlarmaData2>[];

  final colorPrimario = const Color.fromARGB(255, 25, 144, 234);

  LatLng midPoint(LatLng p1, LatLng p2) {
    return LatLng(
      (p1.latitude + p2.latitude) / 2,
      (p1.longitude + p2.longitude) / 2,
    );
  }

  Map<String, String> alarmTranslations = {
    'HABITACION PROHIBIDA': 'HABITACION PROHIBIDA',
    'PUNTO PROHIBIDO': 'PUNTO PROHIBIDO',
    'AUSENCIA': 'AUSENCIA',
    'SEDENTARISMO': 'SEDENTARISMO',
    'RANGO DE ACCION': 'RANGO DE ACCION',
    'FRECUENCIA': 'FRECUENCIA',
    'Alarma Caida': 'Fall Alarm',
    'Boton Panico': 'Panic Button',
  };

  Map<String, String> alarmTranslationsEN = {
    'HABITACION PROHIBIDA': 'FORBIDDEN ROOM',
    'PUNTO PROHIBIDO': 'FORBIDDEN POINT',
    'AUSENCIA': 'ABSENCE',
    'SEDENTARISMO': 'SEDENTARY',
    'RANGO DE ACCION': 'RANGE OF ACTION',
    'FRECUENCIA': 'FREQUENCY',
    'Alarma Caida': 'Fall Alarm',
    'Boton Panico': 'Panic Button',
  };

  Map<String, String> roomTypeTranslations = {
    'Baño': 'Bathroom',
    'Buhardilla': 'Attic',
    'Cocina': 'Kitchen',
    'Comedor': 'Dining Room',
    'Despacho': 'Office',
    'Dormitorio': 'Bedroom',
    'Entrada': 'Entrance',
    'Estudio': 'Study',
    'Garaje': 'Garage',
    'Habitación': 'Room',
    'Hall': 'Hall',
    'Laboratorio': 'Laboratory',
    'Pasillo': 'Hallway',
    'Patio': 'Patio',
    'Salón': 'Living Room',
    'Sótano': 'Basement',
    'Trastero': 'Storage Room',
    'Otros': 'Others',
  };

  num calcularDistancia(LatLng punto1, LatLng punto2) {
    final geodesy = Geodesy();
    final distancia = geodesy.distanceBetweenTwoGeoPoints(
      LatLng(punto1.latitude, punto1.longitude),
      LatLng(punto2.latitude, punto2.longitude),
    );
    return distancia;
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      markers.clear();
      for (var i = 0; i < widget.casas.length; i++) {
        if (i == 0) {
          markers.add(
            Marker(
              point: LatLng(widget.casas[i].Latitud, widget.casas[i].Longitud),
              child: Container(
                child: Icon(Icons.home, color: Colors.red, size: 50.0),
              ),
            ),
          );
        } else {
          int red = Random().nextInt(256);
          int green = Random().nextInt(256);
          int blue = Random().nextInt(256);
          Color randomColor = Color.fromRGBO(red, green, blue, 1.0);
          markers.add(
            Marker(
              point: LatLng(widget.casas[i].Latitud, widget.casas[i].Longitud),
              child: Container(
                child: Icon(Icons.home, color: randomColor, size: 50.0),
              ),
            ),
          );
        }
      }
      updateData();
    });
    mapController = MapController();
    timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      updateData();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Map<String, String> translationsPais = {
    'España': 'Spain',
    'México': 'Mexico',
    'Argentina': 'Argentina',
    'Colombia': 'Colombia',
    'Perú': 'Peru',
    'Venezuela': 'Venezuela',
    'Chile': 'Chile',
    'Guatemala': 'Guatemala',
    'Cuba': 'Cuba',
    'Bolivia': 'Bolivia',
    'República Dominicana': 'Dominican Republic',
    'Honduras': 'Honduras',
    'Paraguay': 'Paraguay',
    'El Salvador': 'El Salvador',
    'Nicaragua': 'Nicaragua',
    'Costa Rica': 'Costa Rica',
    'Puerto Rico': 'Puerto Rico',
    'Panamá': 'Panama',
    'Uruguay': 'Uruguay',
    'Ecuador': 'Ecuador',
    'Estados Unidos': 'United States',
    'Brasil': 'Brazil',
    'Canadá': 'Canada',
    'Reino Unido': 'United Kingdom',
    'Francia': 'France',
    'Alemania': 'Germany',
    'Italia': 'Italy',
    'Japón': 'Japan',
    'China': 'China',
    'Rusia': 'Russia',
    'India': 'India',
    'Irlanda': 'Ireland',
    'Australia': 'Australia',
  };

  String translateAlarmString(String original, bool isSpanish) {
    if (isSpanish) {
      return original;
    } else {
      for (String key in alarmTranslationsEN.keys) {
        if (original.contains(key)) {
          return original.replaceAll(key, alarmTranslationsEN[key]!);
        }
      }
    }
    return original;
  }

  String translateCountryInAddress(String address, bool isSpanish) {
    if (!isSpanish) {
      for (String country in translationsPais.keys) {
        if (address.contains(country)) {
          return address.replaceAll(
            country,
            translationsPais[country] ?? country,
          );
        }
      }
    }
    return address;
  }

  String translateRoomType(String roomType, bool isSpanish) {
    if (!isSpanish) {
      for (String key in roomTypeTranslations.keys) {
        if (roomType.contains(key)) {
          return roomType.replaceAll(key, roomTypeTranslations[key]!);
        }
      }
    }
    return roomType;
  }

  void updateData() async {
    var DbAlarma = await DBPostgres().DBGetAlarmaPaciente(
      widget.paciente.CodPaciente,
      'null',
    );
    for (var p in DbAlarma[0]) {
      AlarmasPacienteList.add(
        AlarmasPaciente(p[0], p[1], p[2], p[3], p[4], p[5]),
      );
    }
    var startDate = DateTime(now.year, now.month, now.day, 0, 0, 0, 0);
    var endDate = DateTime.now();
    var startFormatted = DateFormat(
      "yyyy-MM-dd'T'HH:mm:ss'Z'",
    ).format(startDate.toUtc());
    var endFormatted = DateFormat(
      "yyyy-MM-dd'T'HH:mm:ss'Z'",
    ).format(endDate.toUtc());
    var every = "30s";

    InfluxDBService()
        .GetAlarmStats(
          widget.wearable.CodPacienteWearable,
          widget.wearable.IdWearable,
          AlarmasPacienteList,
          startFormatted,
          endFormatted,
          '30s',
        )
        .then((alarms) {
          setState(() {
            AlarmsListStat.clear();
            AlarmsListHistory.clear();
            AlamrHistory.clear();
            AlarmsListStat = alarms;

            for (AlarmasPaciente paciente in AlarmasPacienteList) {
              for (AlarmaData2 alarma in AlarmsListStat) {
                if (alarma.Alarma == "panic_button") {
                  AlarmsListHistory.add(
                    AlarmaData2("Boton Panico", alarma.Valor, alarma.timestamp),
                  );
                } else if (alarma.Alarma == "fall") {
                  AlarmsListHistory.add(
                    AlarmaData2("Alarma Caida", alarma.Valor, alarma.timestamp),
                  );
                } else if (paciente.CodAlarmaPaciente == alarma.Alarma) {
                  AlarmsListHistory.add(
                    AlarmaData2(
                      "${paciente.Alarma}: ${paciente.DesAlarma}",
                      alarma.Valor,
                      alarma.timestamp,
                    ),
                  );
                }
              }
            }
          });
        });

    InfluxDBService()
        .GetHumTempBat(
          widget.wearable.CodPacienteWearable,
          widget.wearable.IdWearable,
          startFormatted,
          endFormatted,
          every,
        )
        .then((nivel) {
          setState(() {
            nivelBateria = nivel[0];
            nivelHumedad = nivel[1];
            nivelTemperatura = nivel[2];
          });
        });

    InfluxDBService()
        .GetRoom(
          widget.wearable.CodPacienteWearable,
          widget.wearable.IdWearable,
          startFormatted,
          endFormatted,
          every,
        )
        .then((room) {
          setState(() {
            roomList = room;
          });
        });

    InfluxDBService()
        .GetAlarm(
          widget.wearable.CodPacienteWearable,
          widget.wearable.IdWearable,
          startFormatted,
          endFormatted,
          "30s",
        )
        .then((alarms) {
          setState(() {
            AlarmsList = alarms;
          });
        });

    InfluxDBService()
        .GetGPS(
          widget.wearable.CodPacienteWearable,
          widget.wearable.IdWearable,
          startFormatted,
          endFormatted,
          "30s",
        )
        .then((GPS) {
          setState(() {
            LatList = GPS[0];
            LongList = GPS[1];
            if (LongList.isNotEmpty &&
                LatList.isNotEmpty &&
                LatList.length > 3 &&
                LongList.length > 3) {
              if (LongList.length == LatList.length) {
                coordinates = LatLng(
                  widget.casas[0].Latitud,
                  widget.casas[0].Longitud,
                );
                routeCoordinates.clear();
                Geodesy geodesy = Geodesy();
                for (int i = 0; i < LongList.length; i++) {
                  var longData = LongList[i];
                  var latData = LatList[i];

                  DateTime time = longData.timestamp;
                  if (latData.Lat == 0.0000 && longData.Long == 0.0000) {
                    continue;
                  } else {
                    coordinates = LatLng(latData.Lat, longData.Long);
                  }

                  bool agregarPunto = true;
                  bool ok = true;
                  for (int j = 0; j < routeCoordinates.length; j++) {
                    num distance = geodesy.distanceBetweenTwoGeoPoints(
                      coordinates,
                      routeCoordinates[j].coordenadas,
                    );

                    if (distance <= 4) {
                      agregarPunto = false;
                      break;
                    }
                    if (widget.wearable.IdWearable.startsWith("sensecap")) {
                      if (distance <= 50) {
                        agregarPunto = false;
                        break;
                      }
                    }
                  }
                  for (int m = 0; m < widget.casas.length; m++) {
                    if (agregarPunto &&
                        coordinates.latitude == widget.casas[m].Latitud &&
                        coordinates.longitude == widget.casas[m].Longitud) {
                      ok = false;
                    }
                  }
                  if (agregarPunto &&
                      ok &&
                      coordinates.latitude != 0.0000 &&
                      coordinates.longitude != 0.0000) {
                    routeCoordinates.add(Coordenas(coordinates, time));
                  }
                }

                markers.clear();
                for (int i = 0; i < widget.casas.length; i++) {
                  if (i == 0) {
                    markers.add(
                      Marker(
                        point: LatLng(
                          widget.casas[i].Latitud,
                          widget.casas[i].Longitud,
                        ),
                        child: Container(
                          child: Icon(
                            Icons.home,
                            color: Colors.red,
                            size: 50.0,
                          ),
                        ),
                      ),
                    );
                  } else {
                    int red = Random().nextInt(256);
                    int green = Random().nextInt(256);
                    int blue = Random().nextInt(256);
                    Color randomColor = Color.fromRGBO(red, green, blue, 1.0);
                    markers.add(
                      Marker(
                        point: LatLng(
                          widget.casas[i].Latitud,
                          widget.casas[i].Longitud,
                        ),
                        child: Container(
                          child: Icon(
                            Icons.home,
                            color: randomColor,
                            size: 50.0,
                          ),
                        ),
                      ),
                    );
                  }
                }

                for (int i = 0; i < routeCoordinates.length - 1; i++) {
                  final point1 = routeCoordinates[i].coordenadas;
                  final point2 = routeCoordinates[i + 1].coordenadas;

                  final lat1 = point1.latitude * pi / 180;
                  final lon1 = point1.longitude * pi / 180;
                  final lat2 = point2.latitude * pi / 180;
                  final lon2 = point2.longitude * pi / 180;

                  final dLon = lon2 - lon1;

                  final y = math.sin(dLon) * math.cos(lat2);
                  final x =
                      math.cos(lat1) * math.sin(lat2) -
                      math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
                  var angle = math.atan2(y, x) - 80;

                  angle = (angle + 2 * pi) % (2 * pi);
                  final mid = midPoint(point1, point2);

                  markers.add(
                    Marker(
                      point: routeCoordinates[i].coordenadas,
                      child: Container(
                        child: GestureDetector(
                          onTap: () {
                            // CORREGIDO: Obtener isSpanish dentro del diálogo
                            final bool isSpanish = FlutterLocalization.instance.currentLocale?.languageCode == 'es';
                            
                            showModalBottomSheet(
                              context: context,
                              builder: (ctx) => Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      _buildInfoCard(
                                        icon: Icons.location_on,
                                        label: isSpanish ? 'Latitud' : 'Latitude',
                                        value: routeCoordinates[i]
                                            .coordenadas
                                            .latitude
                                            .toStringAsFixed(6),
                                      ),
                                      const SizedBox(height: 10),
                                      _buildInfoCard(
                                        icon: Icons.location_on,
                                        label: isSpanish ? 'Longitud' : 'Longitude',
                                        value: routeCoordinates[i]
                                            .coordenadas
                                            .longitude
                                            .toStringAsFixed(6),
                                      ),
                                      const SizedBox(height: 10),
                                      _buildInfoCard(
                                        icon: Icons.access_time,
                                        label: isSpanish ? 'Hora' : 'Time',
                                        value: DateFormat(
                                          'HH:mm:ss',
                                        ).format(routeCoordinates[i].timestamp),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          child: const Icon(Icons.location_on, size: 20),
                        ),
                      ),
                    ),
                  );

                  markers.add(
                    Marker(
                      point: mid,
                      child: Transform.rotate(
                        angle: angle,
                        child: Icon(
                          Icons.arrow_forward,
                          color: colorPrimario,
                          size: 20.0,
                        ),
                      ),
                    ),
                  );
                }

                if (routeCoordinates.isNotEmpty) {
                  markers.add(
                    Marker(
                      point: routeCoordinates.first.coordenadas,
                      child: Container(
                        child: GestureDetector(
                          onTap: () {
                            // CORREGIDO: Obtener isSpanish dentro del diálogo
                            final bool isSpanish = FlutterLocalization.instance.currentLocale?.languageCode == 'es';
                            
                            showModalBottomSheet(
                              context: context,
                              builder: (ctx) => Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      _buildInfoCard(
                                        icon: Icons.location_on,
                                        label: isSpanish ? 'Latitud' : 'Latitude',
                                        value: routeCoordinates
                                            .first
                                            .coordenadas
                                            .latitude
                                            .toStringAsFixed(6),
                                      ),
                                      const SizedBox(height: 10),
                                      _buildInfoCard(
                                        icon: Icons.location_on,
                                        label: isSpanish ? 'Longitud' : 'Longitude',
                                        value: routeCoordinates
                                            .first
                                            .coordenadas
                                            .longitude
                                            .toStringAsFixed(6),
                                      ),
                                      const SizedBox(height: 10),
                                      _buildInfoCard(
                                        icon: Icons.access_time,
                                        label: isSpanish ? 'Hora' : 'Time',
                                        value: DateFormat('HH:mm:ss').format(
                                          routeCoordinates.first.timestamp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.circle,
                            color: Colors.green,
                            size: 20.0,
                          ),
                        ),
                      ),
                    ),
                  );

                  markers.add(
                    Marker(
                      point: routeCoordinates.last.coordenadas,
                      child: Container(
                        child: GestureDetector(
                          onTap: () {
                            // CORREGIDO: Obtener isSpanish dentro del diálogo
                            final bool isSpanish = FlutterLocalization.instance.currentLocale?.languageCode == 'es';
                            
                            showModalBottomSheet(
                              context: context,
                              builder: (ctx) => Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      _buildInfoCard(
                                        icon: Icons.location_on,
                                        label: isSpanish ? 'Latitud' : 'Latitude',
                                        value: routeCoordinates
                                            .last
                                            .coordenadas
                                            .latitude
                                            .toStringAsFixed(6),
                                      ),
                                      const SizedBox(height: 10),
                                      _buildInfoCard(
                                        icon: Icons.location_on,
                                        label: isSpanish ? 'Longitud' : 'Longitude',
                                        value: routeCoordinates
                                            .last
                                            .coordenadas
                                            .longitude
                                            .toStringAsFixed(6),
                                      ),
                                      const SizedBox(height: 10),
                                      _buildInfoCard(
                                        icon: Icons.access_time,
                                        label: isSpanish ? 'Hora' : 'Time',
                                        value: DateFormat('HH:mm:ss').format(
                                          routeCoordinates.last.timestamp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.circle,
                            color: Colors.red,
                            size: 20.0,
                          ),
                        ),
                      ),
                    ),
                  );
                }
              }
            }
          });
        });
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorPrimario),
          const SizedBox(width: 10),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A2B3C),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // AGREGADO: isSpanish DENTRO del build
    final bool isSpanish = FlutterLocalization.instance.currentLocale?.languageCode == 'es';

    String formattedDate;
    if (isSpanish) {
      formattedDate = DateFormat('EEEE, d MMMM y', 'es_ES').format(now);
    } else {
      formattedDate = DateFormat('EEEE, MMMM d, y', 'en_US').format(now);
    }

    var filteredCombinedList = <dynamic>[];
    String? previousRoom;
    RoomData? lastRoomData;
    final formattedDateWithUppercase = toBeginningOfSentenceCase(formattedDate);
    List<dynamic> combinedList = [];
    AlarmaData2? lastAlarmData;

    for (var roomData in roomList) {
      combinedList.add({
        'isRoom': true,
        'isAlarm': false,
        'roomData': roomData,
      });
    }

    for (var alarmData in AlarmsListHistory) {
      combinedList.add({
        'isRoom': false,
        'isAlarm': true,
        'alarmData': alarmData,
      });
    }

    combinedList.sort((a, b) {
      DateTime timestampA, timestampB;
      if (a['isRoom']) {
        timestampA = a['roomData'].timestamp;
      } else {
        timestampA = a['alarmData'].timestamp;
      }
      if (b['isRoom']) {
        timestampB = b['roomData'].timestamp;
      } else {
        timestampB = b['alarmData'].timestamp;
      }
      return timestampA.compareTo(timestampB);
    });

    for (var item in combinedList) {
      if (item['isRoom']) {
        var roomData = item['roomData'];
        if (roomData.room != previousRoom) {
          filteredCombinedList.add(item);
          previousRoom = roomData.room;
          lastRoomData = roomData;
        } else {
          if (roomData.timestamp.isBefore(lastRoomData!.timestamp)) {
            filteredCombinedList.removeLast();
            filteredCombinedList.add(item);
            lastRoomData = roomData;
          }
        }
      } else if (item['isAlarm']) {
        var alarmData = item['alarmData'];
        if (alarmData.Valor == 1) {
          if (lastAlarmData != null && alarmData.Valor == lastAlarmData.Valor) {
            if (alarmData.timestamp.isBefore(lastAlarmData.timestamp)) {
              filteredCombinedList.removeLast();
              filteredCombinedList.add(item);
              lastAlarmData = alarmData;
            }
          } else {
            filteredCombinedList.add(item);
            lastAlarmData = alarmData;
          }
        }
      }
    }
    combinedList = filteredCombinedList;

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorPrimario.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  formattedDateWithUppercase!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorPrimario,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Lista de eventos
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: combinedList.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 30,
                                color: Colors.orange,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isSpanish
                                    ? 'Dispositivo apagado o sin conexión'
                                    : 'Device off or no connection',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: combinedList.length,
                        itemBuilder: (context, index) {
                          var item = combinedList.reversed.toList()[index];
                          final hourMinuteFormat = DateFormat('HH:mm');

                          if (item['isRoom']) {
                            var roomData = item['roomData'];
                            var tipoHabitacion = widget.habitaciones.firstWhere(
                              (tipo) =>
                                  tipo.CodHabitacionSensor == roomData.room,
                              orElse: () => Habitaciones(
                                0,
                                isSpanish
                                    ? 'Zona no sensorizada'
                                    : 'Non-sensorized zone',
                                null,
                                0,
                                '',
                                DateTime.now(),
                                null,
                                null,
                                null,
                                null,
                                null,
                              ),
                            );

                            String roomDisplay;
                            if (tipoHabitacion.TipoHabitacion == 'Otros' ||
                                tipoHabitacion.TipoHabitacion == 'Others') {
                              roomDisplay = isSpanish
                                  ? '${translateRoomType(tipoHabitacion.TipoHabitacion, isSpanish)}: ${tipoHabitacion.Observaciones}'
                                  : '${translateRoomType(tipoHabitacion.TipoHabitacion, isSpanish)}: ${tipoHabitacion.Observaciones}';
                            } else {
                              roomDisplay = isSpanish
                                  ? '${translateRoomType(tipoHabitacion.TipoHabitacion, isSpanish)}: ${tipoHabitacion.Observaciones}'
                                  : '${translateRoomType(tipoHabitacion.TipoHabitacion, isSpanish)}: ${tipoHabitacion.Observaciones}';
                            }

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: colorPrimario.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.room,
                                      size: 16,
                                      color: Color.fromARGB(255, 25, 144, 234),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    hourMinuteFormat.format(roomData.timestamp),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF1A2B3C),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      roomDisplay,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else if (item['isAlarm']) {
                            var alarmData = item['alarmData'];
                            String alarmStatus = isSpanish
                                ? 'Alarma Desactivada'
                                : 'Alarm Deactivated';
                            Color alarmColor = alarmData.Valor == 0
                                ? Colors.green
                                : Colors.red;
                            if (alarmData.Valor == 1) {
                              alarmStatus = translateAlarmString(
                                alarmData.Alarma,
                                isSpanish,
                              );
                            }
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: alarmColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: alarmColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      alarmData.Valor == 0
                                          ? Icons.check_circle
                                          : Icons.warning,
                                      size: 16,
                                      color: alarmColor,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    hourMinuteFormat.format(
                                      alarmData.timestamp,
                                    ),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: alarmColor,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      alarmStatus,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: alarmColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return null;
                        },
                      ),
              ),

              const SizedBox(height: 50.0),

              // Mapas de casas 
              ...widget.casas.asMap().entries.map((entry) {
                int i = entry.key;
                Casa casa = entry.value;
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colorPrimario.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        isSpanish
                            ? casa.Dirrecion
                            : translateCountryInAddress(
                                casa.Dirrecion,
                                isSpanish,
                              ),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: colorPrimario,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: FlutterMap(
                          key: ValueKey('map_$i'),
                          mapController: i == 0 ? mapController : null,
                          options: MapOptions(
                            initialCenter: routeCoordinates.isNotEmpty
                                ? (i < routeCoordinates.length
                                      ? routeCoordinates[i].coordenadas
                                      : LatLng(casa.Latitud, casa.Longitud))
                                : LatLng(casa.Latitud, casa.Longitud),
                            initialZoom: 15,
                            maxZoom: 18,
                            minZoom: 2,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.all,
                              enableMultiFingerGestureRace: true,
                            ),
                          ),
                          children: [
                            TileLayer(
                                        urlTemplate:
                                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        userAgentPackageName:
                                            'com.AgeInPlace_caregiver.app', 
                                      ),
                            if (switchValue && routeCoordinates.isNotEmpty)
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: routeCoordinates
                                        .take(3)
                                        .map((e) => e.coordenadas)
                                        .toList(),
                                    strokeWidth: 4.0,
                                    color: colorPrimario,
                                  ),
                                ],
                              )
                            else if (routeCoordinates.isNotEmpty)
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: routeCoordinates
                                        .map((e) => e.coordenadas)
                                        .toList(),
                                    strokeWidth: 4.0,
                                    color: colorPrimario,
                                  ),
                                ],
                              ),
                            if (markers.isNotEmpty)
                              MarkerLayer(
                                markers: switchValue
                                    ? markers.take(3 * 3).toList()
                                    : markers,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                  ],
                );
              }).toList(),

              const SizedBox(height: 20.0),

              // Switch de trayectoria/posición actual
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isSpanish ? 'Trayectoria' : 'Trajectory',
                      style: TextStyle(
                        fontSize: 14,
                        color: switchValue
                            ? Colors.grey.shade500
                            : colorPrimario,
                        fontWeight: switchValue
                            ? FontWeight.normal
                            : FontWeight.w600,
                      ),
                    ),
                    Switch(
                      activeColor: colorPrimario,
                      value: switchValue,
                      onChanged: (value) {
                        setState(() {
                          switchValue = value;
                        });
                      },
                    ),
                    Text(
                      isSpanish ? 'Posición actual' : 'Current position',
                      style: TextStyle(
                        fontSize: 14,
                        color: !switchValue
                            ? Colors.grey.shade500
                            : colorPrimario,
                        fontWeight: !switchValue
                            ? FontWeight.normal
                            : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20.0),

              // Sensores
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSensorCard(
                      icon: Icons.battery_full,
                      label: isSpanish ? 'Batería' : 'Battery',
                      value: '$nivelBateria%',
                      iconColor: nivelBateria <= 25 ? Colors.red : Colors.green,
                      valueColor: nivelBateria <= 25
                          ? Colors.red
                          : Colors.green,
                    ),
                    _buildSensorCard(
                      icon: Icons.opacity,
                      label: isSpanish ? 'Humedad' : 'Humidity',
                      value: '$nivelHumedad%',
                      iconColor: Colors.blue,
                      valueColor: const Color(0xff066163),
                    ),
                    _buildSensorCard(
                      icon: Icons.thermostat_outlined,
                      label: isSpanish ? 'Temperatura' : 'Temperature',
                      value: '$nivelTemperatura°C',
                      iconColor: Colors.red,
                      valueColor: const Color(0xff066163),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50.0),
            ],
          ),
        ),
      ),
    );
  }
}