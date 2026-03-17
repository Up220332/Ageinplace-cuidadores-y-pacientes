import 'dart:core';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:geodesy/geodesy.dart';
import 'package:proj4dart/proj4dart.dart' as proj4;

import '../Cuidador/screen_Paciente.dart';
import '../Cuidador/screen_Pacientes.dart';
import '../base_de_datos/postgres.dart';

class AlarmasInactPage extends StatefulWidget {
  final Pacientes paciente;
  List<Habitaciones> HabitacionesList;
  List<Casa> CasaList;

  AlarmasInactPage({
    super.key,
    required this.paciente,
    required this.HabitacionesList,
    required this.CasaList,
  });

  @override
  _AlarmasInactPageState createState() => _AlarmasInactPageState();
}

class _AlarmasInactPageState extends State<AlarmasInactPage> {
  late var selectedAlarma;
  late int selectedCodAlarma;
  List<AlarmaParametros> filteredParametros = [];
  List<Map<String, dynamic>> listaParametros = [];
  bool showParametrosDropdown = false;

  late double selectedLatitude;
  late double selectedLongitude;
  bool isLoading = true;
  List<String> parametros = [];
  late int codAlarmaParametro = 0;
  late int codAlarmaParametroLatitud = 0;
  late int codAlarmaParametroLongitud = 0;
  List<AlarmaParametros> AlarmaParametrosList = [];
  List<AlarmaParametros> ParametrosList = [];
  List<Alarmas> AlarmasList = [];
  List<AlarmasPaciente> AlarmasPacienteList = [];
  List<AlarmasParametrosValor> AlarmasPacienteParametroList = [];
  List<AlarmasParametrosValor> ParametrosValorList = [];

  final colorPrimario = const Color.fromARGB(255, 25, 144, 234);
  
  // Variable para idioma
  late bool isSpanish;

  Map<String, String> alarmTranslationsEN = {
    'HABITACION PROHIBIDA': 'FORBIDDEN ROOM',
    'PUNTO PROHIBIDO': 'FORBIDDEN POINT',
    'AUSENCIA': 'ABSENCE',
    'SEDENTARISMO': 'SEDENTARY',
    'RANGO DE ACCION': 'RANGE OF ACTION',
    'FRECUENCIA': 'FREQUENCY',
  };

  final _mapController = MapController();

  final _sphericalMercatorProjection = proj4.Projection.add(
    'EPSG:3857',
    '+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 '
        '+x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext '
        '+no_defs',
  );

  Future<String> getData() async {
    AlarmasPacienteList.clear();
    AlarmaParametrosList.clear();
    AlarmasPacienteParametroList.clear();
    AlarmasList.clear();
    ParametrosList.clear();
    var Dbdata = await DBPostgres().DBGetAlarmaParametros();
    var DbAlarma = await DBPostgres().DBGetAlarmaPaciente(
      widget.paciente.CodPaciente,
      'not null',
    );

    setState(() {
      for (var p in Dbdata[0]) {
        AlarmaParametrosList.add(
          AlarmaParametros(
            p[0],
            p[1],
            p[2],
            p[3],
            p[4],
            p[5],
            p[6],
            p[7],
            p[8],
          ),
        );
      }
      for (var p in Dbdata[1]) {
        AlarmasList.add(Alarmas(p[0], p[1], p[2], p[3]));
      }
      for (var p in DbAlarma[0]) {
        AlarmasPacienteList.add(
          AlarmasPaciente(p[0], p[1], p[2], p[3], p[4], p[5]),
        );
      }
      for (var p in DbAlarma[1]) {
        AlarmasPacienteParametroList.add(
          AlarmasParametrosValor(p[0], p[1], p[2], p[3], p[4], p[5]),
        );
      }
    });
    isLoading = false;
    return 'Successfully Fetched data';
  }

  @override
  void initState() {
    super.initState();
    
    // Inicializar idioma y listener
    FlutterLocalization.instance.onTranslatedLanguage = _onLanguageChanged;
    isSpanish = FlutterLocalization.instance.currentLocale?.languageCode == 'es';
    
    getData();
  }

  void _onLanguageChanged(Locale? locale) {
    if (mounted) {
      setState(() {
        isSpanish = locale?.languageCode == 'es';
      });
    }
  }

  @override
  void dispose() {
    FlutterLocalization.instance.onTranslatedLanguage = null;
    super.dispose();
  }

  String translateAlarm(String alarm) {
    if (isSpanish) {
      return alarm;
    } else {
      return alarmTranslationsEN[alarm] ?? alarm;
    }
  }

  bool _esHoraFinMenor(TimeOfDay inicio, TimeOfDay fin) {
    final inicioMinutos = inicio.hour * 60 + inicio.minute;
    final finMinutos = fin.hour * 60 + fin.minute;
    return finMinutos < inicioMinutos;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PacientesCuidadorScreen()),
        );
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: colorPrimario))
                : AlarmasPacienteList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isSpanish
                              ? 'No hay alarmas inactivas'
                              : 'No inactive alarms',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isSpanish
                              ? 'Las alarmas desactivadas aparecerán aquí'
                              : 'Deactivated alarms will appear here',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: AlarmasPacienteList.length,
                    itemBuilder: (context, index) {
                      final alarma = AlarmasPacienteList[index];

                      return GestureDetector(
                        onTap: () {
                          _mostrarActivarAlarma(context, index);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
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
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.red.withOpacity(0.7),
                                      Colors.red,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(
                                  Icons.notifications_off,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Información de la alarma
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      translateAlarm(alarma.Alarma),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      alarma.DesAlarma,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),

                              // Chip de inactiva
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isSpanish ? 'Inactiva' : 'Inactive',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> _mostrarActivarAlarma(
    BuildContext context,
    int index,
  ) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController radioPuntoProhibidoController =
            TextEditingController();
        final TextEditingController desAlarmaController =
            TextEditingController();
        final TextEditingController duracionController =
            TextEditingController();
        final TextEditingController frecuenciaController =
            TextEditingController();
        TimeOfDay? horaInicioMod;
        TimeOfDay? horaFinMod;
        String? codHabitacionSensorMod = 'HS0';
        ParametrosValorList.clear();
        selectedAlarma = AlarmasPacienteList[index].Alarma;
        desAlarmaController.text = AlarmasPacienteList[index].DesAlarma;
        ParametrosValorList = AlarmasPacienteParametroList.where(
          (parametro) =>
              parametro.CodAlarmaPaciente ==
              AlarmasPacienteList[index].CodAlarmaPaciente,
        ).toList();
        Map<int, String> valoresModParametros = {};
        LatLng? selectedLatLngMod;
        List<CircleMarker> circleMarkersMod = [];
        double radioEnMetrosMod = 0;

        bool horaFinEsMenor = false;
        bool mostrarAdvertenciaRangoNocturno = false;

        if ((selectedAlarma == "PUNTO PROHIBIDO" ||
            selectedAlarma == "RANGO DE ACCION")) {
          selectedLatLngMod = LatLng(
            double.parse(
              ParametrosValorList.firstWhere(
                (parametro) => parametro.Parametro == 'LATITUD',
                orElse: () =>
                    AlarmasParametrosValor('', '0.0', 0, 0, 'LATITUD', ''),
              ).Valor,
            ),
            double.parse(
              ParametrosValorList.firstWhere(
                (parametro) => parametro.Parametro == 'LONGITUD',
                orElse: () =>
                    AlarmasParametrosValor('', '0.0', 0, 0, 'LONGITUD', ''),
              ).Valor,
            ),
          );
          radioPuntoProhibidoController.text =
              (double.tryParse(
                        ParametrosValorList.firstWhere(
                          (parametro) => parametro.Parametro == 'RADIO',
                          orElse: () => AlarmasParametrosValor(
                            '',
                            '0',
                            0,
                            0,
                            'RADIO',
                            '',
                          ),
                        ).Valor,
                      )! /
                      1000)
                  .toString();
          radioEnMetrosMod =
              (double.tryParse(radioPuntoProhibidoController.text) ?? 0) * 1000;
          circleMarkersMod = [
            CircleMarker(
              point: selectedLatLngMod,
              radius: radioEnMetrosMod,
              color: Colors.blue.withOpacity(0.5),
              borderColor: colorPrimario,
              borderStrokeWidth: 2,
              useRadiusInMeter: true,
            ),
          ];
        } else {
          final parametroDuracion = ParametrosValorList.firstWhere(
            (parametro) => parametro.Parametro == 'DURACION',
            orElse: () => AlarmasParametrosValor('', '0', 0, 0, 'DURACION', ''),
          );
          duracionController.text = parametroDuracion.Valor;

          final parametroFrecuencia = ParametrosValorList.firstWhere(
            (parametro) => parametro.Parametro == 'FRECUENCIA',
            orElse: () =>
                AlarmasParametrosValor('', '0', 0, 0, 'FRECUENCIA', ''),
          );
          frecuenciaController.text = parametroFrecuencia.Valor;

          final parametroHoraInicio = ParametrosValorList.firstWhere(
            (parametro) => parametro.Parametro == 'HORA INICIO',
            orElse: () =>
                AlarmasParametrosValor('0', '00:00', 0, 0, 'HORA INICIO', ''),
          );

          try {
            String valorHora = parametroHoraInicio.Valor;

            if (valorHora.contains('TimeOfDay')) {
              final regex = RegExp(r'(\d{1,2}):(\d{2})');
              final match = regex.firstMatch(valorHora);

              if (match != null) {
                horaInicioMod = TimeOfDay(
                  hour: int.parse(match.group(1)!),
                  minute: int.parse(match.group(2)!),
                );
              } else {
                horaInicioMod = const TimeOfDay(hour: 0, minute: 0);
              }
            } else {
              final partes = valorHora.split(':');
              if (partes.length == 2) {
                horaInicioMod = TimeOfDay(
                  hour: int.parse(partes[0]),
                  minute: int.parse(partes[1]),
                );
              } else {
                horaInicioMod = const TimeOfDay(hour: 0, minute: 0);
              }
            }
          } catch (e) {
            print('Error parseando hora inicio: $e');
            horaInicioMod = const TimeOfDay(hour: 0, minute: 0);
          }

          final parametroHoraFin = ParametrosValorList.firstWhere(
            (parametro) => parametro.Parametro == 'HORA FIN',
            orElse: () =>
                AlarmasParametrosValor('', '00:00', 0, 0, 'HORA FIN', ''),
          );

          try {
            String valorHora = parametroHoraFin.Valor;

            if (valorHora.contains('TimeOfDay')) {
              final regex = RegExp(r'(\d{1,2}):(\d{2})');
              final match = regex.firstMatch(valorHora);

              if (match != null) {
                horaFinMod = TimeOfDay(
                  hour: int.parse(match.group(1)!),
                  minute: int.parse(match.group(2)!),
                );
              } else {
                horaFinMod = const TimeOfDay(hour: 0, minute: 0);
              }
            } else {
              final partes = valorHora.split(':');
              if (partes.length == 2) {
                horaFinMod = TimeOfDay(
                  hour: int.parse(partes[0]),
                  minute: int.parse(partes[1]),
                );
              } else {
                horaFinMod = const TimeOfDay(hour: 0, minute: 0);
              }
            }
          } catch (e) {
            print('Error parseando hora fin: $e');
            horaFinMod = const TimeOfDay(hour: 0, minute: 0);
          }

          if (horaInicioMod != null && horaFinMod != null) {
            horaFinEsMenor = _esHoraFinMenor(horaInicioMod!, horaFinMod!);
            mostrarAdvertenciaRangoNocturno = horaFinEsMenor;
          }

          final parametroCodHabitacionSensor = ParametrosValorList.firstWhere(
            (parametro) => parametro.Parametro == 'HABITACION',
            orElse: () =>
                AlarmasParametrosValor('', 'HS0', 0, 0, 'HABITACION', ''),
          );
          codHabitacionSensorMod = parametroCodHabitacionSensor.Valor;
        }

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: colorPrimario, size: 28),
                        const SizedBox(width: 10),
                        Text(
                          isSpanish ? 'Alarma Inactiva' : 'Inactive Alarm',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (mostrarAdvertenciaRangoNocturno)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber, color: Colors.amber, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isSpanish
                                  ? 'La hora de fin es posterior a la de inicio. El rango de chequeo será hasta el día siguiente.'
                                  : 'The end time is after the start time. The checking range will be until the next day.',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Contenido desplazable
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Descripción
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: TextFormField(
                                controller: desAlarmaController,
                                decoration: InputDecoration(
                                  labelText: isSpanish
                                      ? 'Descripción de la alarma'
                                      : 'Alarm description',
                                  labelStyle: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            if (selectedAlarma != "RANGO DE ACCION" &&
                                selectedAlarma != "PUNTO PROHIBIDO")
                              ...ParametrosValorList.map((parametro) {
                                if (parametro.Parametro == "HABITACION") {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.room,
                                        color: colorPrimario,
                                      ),
                                      title: Text(
                                        isSpanish ? 'Habitación' : 'Room',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${widget.HabitacionesList.firstWhere((Habitacion) => Habitacion.CodHabitacionSensor == codHabitacionSensorMod).TipoHabitacion} ${widget.HabitacionesList.firstWhere((Habitacion) => Habitacion.CodHabitacionSensor == codHabitacionSensorMod).Observaciones}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  );
                                } else if (parametro.Parametro ==
                                    "HORA INICIO") {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.access_time,
                                        color: colorPrimario,
                                      ),
                                      title: Text(
                                        isSpanish
                                            ? 'Hora de inicio'
                                            : 'Start time',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      subtitle: Text(
                                        horaInicioMod?.format(context) ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  );
                                } else if (parametro.Parametro == "HORA FIN") {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.access_time,
                                        color: colorPrimario,
                                      ),
                                      title: Text(
                                        isSpanish ? 'Hora de fin' : 'End time',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      subtitle: Text(
                                        horaFinMod?.format(context) ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  );
                                } else if (parametro.Parametro == "DURACION") {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: TextFormField(
                                      controller: duracionController,
                                      decoration: InputDecoration(
                                        labelText: isSpanish
                                            ? "Duración (HH:mm)"
                                            : "Duration (HH:mm)",
                                        labelStyle: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 16,
                                            ),
                                      ),
                                      onChanged: (value) {
                                        codAlarmaParametro =
                                            ParametrosValorList.firstWhere(
                                              (parametro) =>
                                                  parametro.Parametro ==
                                                  'DURACION',
                                            ).CodAlarmaParametro;
                                        valoresModParametros[codAlarmaParametro] =
                                            duracionController.text;
                                      },
                                    ),
                                  );
                                } else if (parametro.Parametro ==
                                    "FRECUENCIA") {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: TextFormField(
                                      controller: frecuenciaController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      decoration: InputDecoration(
                                        labelText: isSpanish
                                            ? 'Frecuencia (número de veces)'
                                            : 'Frequency (number of times)',
                                        labelStyle: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 16,
                                            ),
                                      ),
                                      onChanged: (value) {
                                        codAlarmaParametro =
                                            ParametrosValorList.firstWhere(
                                              (parametro) =>
                                                  parametro.Parametro ==
                                                  'FRECUENCIA',
                                            ).CodAlarmaParametro;
                                        valoresModParametros[codAlarmaParametro] =
                                            frecuenciaController.text;
                                      },
                                    ),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              }).toList(),

                            if ((selectedAlarma == "PUNTO PROHIBIDO" ||
                                selectedAlarma == "RANGO DE ACCION"))
                              Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.radio_button_checked,
                                        color: colorPrimario,
                                      ),
                                      title: Text(
                                        isSpanish ? 'Radio' : 'Radius',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '$radioEnMetrosMod m',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    height: 250,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: FlutterMap(
                                        mapController: _mapController,
                                        options: MapOptions(
                                          initialCenter: selectedLatLngMod!,
                                          initialZoom: 13,
                                          maxZoom: 18,
                                          minZoom: 2,
                                        ),
                                        children: [
                                          TileLayer(
                                        urlTemplate:
                                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        userAgentPackageName:
                                            'com.AgeInPlace_caregiver.app', 
                                      ),
                                          CircleLayer(
                                            circles: circleMarkersMod,
                                          ),
                                          MarkerLayer(
                                            markers: [
                                              Marker(
                                                point: selectedLatLngMod!,
                                                child: const Icon(
                                                  Icons.location_on,
                                                  color: Colors.red,
                                                  size: 30,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Botón de activar
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await DBPostgres()
                                    .DBDesactActAlarmaPacienteConfig(
                                      AlarmasPacienteList[index]
                                          .CodAlarmaPaciente,
                                      null,
                                    );
                                setState(() {
                                  getData();
                                });
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isSpanish
                                            ? 'Alarma activada correctamente'
                                            : 'Alarm activated successfully',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                              label: Text(
                                isSpanish ? 'Activar alarma' : 'Activate alarm',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}