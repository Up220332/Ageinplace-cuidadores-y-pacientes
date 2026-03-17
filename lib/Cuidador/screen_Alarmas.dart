import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:geodesy/geodesy.dart';
import 'package:proj4dart/proj4dart.dart' as proj4;

import '../Cuidador/screen_Paciente.dart';
import '../Cuidador/screen_Pacientes.dart';
import '../base_de_datos/postgres.dart';

class AlarmasPage extends StatefulWidget {
  final Pacientes paciente;
  List<Habitaciones> HabitacionesList;
  List<Casa> CasaList;

  AlarmasPage({
    super.key,
    required this.paciente,
    required this.HabitacionesList,
    required this.CasaList,
  });

  @override
  _AlarmasPageState createState() => _AlarmasPageState();
}

class _AlarmasPageState extends State<AlarmasPage> {
  late var selectedAlarma;
  late int selectedCodAlarma;
  List<AlarmaParametros> filteredParametros = [];
  List<Map<String, dynamic>> listaParametros = [];
  bool showParametrosDropdown = false;

  late double selectedLatitude;
  late double selectedLongitude;
  double _radioEnMetros = 0;
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
      'null',
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
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: FloatingActionButton.extended(
            heroTag: "btn2",
            backgroundColor: colorPrimario,
            label: Text(
              isSpanish ? 'Agregar alarma' : 'Add alarm',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              _angadirAlarma(context);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
            child: AlarmasPacienteList.isEmpty
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
                              ? 'No hay alarmas configuradas'
                              : 'No alarms configured',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isSpanish
                              ? 'Añade alarmas usando el botón +'
                              : 'Add alarms using the + button',
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
                          _mostrarDesactivarAlarma(context, index);
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
                                      colorPrimario.withOpacity(0.8),
                                      colorPrimario,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(
                                  Icons.notifications_active,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
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

  bool _esHoraFinMenor(TimeOfDay inicio, TimeOfDay fin) {
    final inicioMinutos = inicio.hour * 60 + inicio.minute;
    final finMinutos = fin.hour * 60 + fin.minute;
    return finMinutos < inicioMinutos;
  }

  TimeOfDay? _parseTimeFromString(String timeString) {
    try {
      if (timeString.isEmpty) return null;
      
      final regex = RegExp(r'TimeOfDay\((\d{1,2}):(\d{2})\)');
      final match = regex.firstMatch(timeString);
      
      if (match != null) {
        return TimeOfDay(
          hour: int.parse(match.group(1)!),
          minute: int.parse(match.group(2)!),
        );
      }
      
      if (timeString.contains(':')) {
        final partes = timeString.split(':');
        if (partes.length == 2) {
          return TimeOfDay(
            hour: int.parse(partes[0]),
            minute: int.parse(partes[1]),
          );
        }
      }
    } catch (e) {
      print('Error parseando tiempo: $e');
    }
    return null;
  }

  Future<dynamic> _mostrarDesactivarAlarma(
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
          try {
            selectedLatLngMod = LatLng(
              double.parse(
                ParametrosValorList.firstWhere(
                  (parametro) => parametro.Parametro == 'LATITUD',
                ).Valor,
              ),
              double.parse(
                ParametrosValorList.firstWhere(
                  (parametro) => parametro.Parametro == 'LONGITUD',
                ).Valor,
              ),
            );
            
            double radioValor = double.tryParse(
              ParametrosValorList.firstWhere(
                (parametro) => parametro.Parametro == 'RADIO',
              ).Valor,
            ) ?? 0;
            
            radioPuntoProhibidoController.text = (radioValor / 1000).toString();
            radioEnMetrosMod = radioValor;
            
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
          } catch (e) {
            print('Error cargando punto: $e');
          }
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
                AlarmasParametrosValor('0', 'TimeOfDay(00:00)', 0, 0, 'HORA INICIO', ''),
          );
          horaInicioMod = _parseTimeFromString(parametroHoraInicio.Valor) ?? 
                         const TimeOfDay(hour: 0, minute: 0);

          final parametroHoraFin = ParametrosValorList.firstWhere(
            (parametro) => parametro.Parametro == 'HORA FIN',
            orElse: () =>
                AlarmasParametrosValor('', 'TimeOfDay(00:00)', 0, 0, 'HORA FIN', ''),
          );
          horaFinMod = _parseTimeFromString(parametroHoraFin.Valor) ?? 
                      const TimeOfDay(hour: 0, minute: 0);

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
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.edit, color: colorPrimario, size: 28),
                        const SizedBox(width: 10),
                        Text(
                          isSpanish ? 'Editar Alarma' : 'Edit Alarm',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                    child: DropdownButtonFormField<Habitaciones>(
                                      value: widget.HabitacionesList.firstWhere(
                                        (habitacion) => 
                                          habitacion.CodHabitacionSensor == codHabitacionSensorMod,
                                        orElse: () => widget.HabitacionesList.first,
                                      ),
                                      items: widget.HabitacionesList.map(
                                        (habitacion) => DropdownMenuItem<Habitaciones>(
                                          value: habitacion,
                                          child: Text(
                                            '${habitacion.TipoHabitacion} ${habitacion.Observaciones}',
                                          ),
                                        ),
                                      ).toList(),
                                      onChanged: (Habitaciones? value) {
                                        if (value != null) {
                                          setState(() {
                                            valoresModParametros[parametro.CodAlarmaParametro] =
                                                value.CodHabitacionSensor!;
                                          });
                                        }
                                      },
                                      decoration: InputDecoration(
                                        labelText: isSpanish ? 'Habitación' : 'Room',
                                        labelStyle: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                      ),
                                    ),
                                  );
                                } else if (parametro.Parametro == "HORA INICIO") {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: GestureDetector(
                                      onTap: () async {
                                        final selectedTime = await showTimePicker(
                                          context: context,
                                          initialTime: horaInicioMod ?? TimeOfDay.now(),
                                        );
                                        if (selectedTime != null) {
                                          setState(() {
                                            horaInicioMod = selectedTime;
                                            valoresModParametros[parametro.CodAlarmaParametro] = 
                                                'TimeOfDay(${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')})';
                                            
                                            if (horaFinMod != null) {
                                              horaFinEsMenor = _esHoraFinMenor(horaInicioMod!, horaFinMod!);
                                              mostrarAdvertenciaRangoNocturno = horaFinEsMenor;
                                            }
                                          });
                                        }
                                      },
                                      child: Container(
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
                                      ),
                                    ),
                                  );
                                } else if (parametro.Parametro == "HORA FIN") {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: GestureDetector(
                                      onTap: () async {
                                        final selectedTime = await showTimePicker(
                                          context: context,
                                          initialTime: horaFinMod ?? TimeOfDay.now(),
                                        );
                                        if (selectedTime != null) {
                                          setState(() {
                                            horaFinMod = selectedTime;
                                            valoresModParametros[parametro.CodAlarmaParametro] = 
                                                'TimeOfDay(${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')})';
                                            
                                            if (horaInicioMod != null) {
                                              horaFinEsMenor = _esHoraFinMenor(horaInicioMod!, horaFinMod!);
                                              mostrarAdvertenciaRangoNocturno = horaFinEsMenor;
                                            }
                                          });
                                        }
                                      },
                                      child: Container(
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
                                        valoresModParametros[parametro.CodAlarmaParametro] = value;
                                      },
                                    ),
                                  );
                                } else if (parametro.Parametro == "FRECUENCIA") {
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
                                        valoresModParametros[parametro.CodAlarmaParametro] = value;
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
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: TextFormField(
                                      controller: radioPuntoProhibidoController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d+(?:\.\d{0,2})?$'),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          radioEnMetrosMod =
                                              (double.tryParse(value) ?? 0) * 1000;
                                          
                                          if (selectedLatLngMod != null) {
                                            circleMarkersMod = [
                                              CircleMarker(
                                                point: selectedLatLngMod!,
                                                radius: radioEnMetrosMod,
                                                color: Colors.blue.withOpacity(0.5),
                                                borderColor: colorPrimario,
                                                borderStrokeWidth: 2,
                                                useRadiusInMeter: true,
                                              ),
                                            ];
                                          }
                                          
                                          final radioParam = ParametrosValorList.firstWhere(
                                            (parametro) => parametro.Parametro == 'RADIO',
                                          );
                                          valoresModParametros[radioParam.CodAlarmaParametro] =
                                              radioEnMetrosMod.toString();
                                        });
                                      },
                                      decoration: InputDecoration(
                                        labelText: isSpanish
                                            ? 'Radio (Km)'
                                            : 'Radius (Km)',
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
                                  Container(
                                    height: 300,
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
                                          initialZoom: 16,
                                          maxZoom: 18,
                                          minZoom: 2,
                                          onTap: (tapPosition, point) {
                                            setState(() {
                                              selectedLatLngMod = point;
                                              
                                              circleMarkersMod = [
                                                CircleMarker(
                                                  point: selectedLatLngMod!,
                                                  radius: radioEnMetrosMod,
                                                  color: Colors.blue.withOpacity(0.5),
                                                  borderColor: colorPrimario,
                                                  borderStrokeWidth: 2,
                                                  useRadiusInMeter: true,
                                                ),
                                              ];
                                              
                                              final latParam = ParametrosValorList.firstWhere(
                                                (parametro) => parametro.Parametro == 'LATITUD',
                                              );
                                              final lngParam = ParametrosValorList.firstWhere(
                                                (parametro) => parametro.Parametro == 'LONGITUD',
                                              );
                                              
                                              valoresModParametros[latParam.CodAlarmaParametro] =
                                                  point.latitude.toString();
                                              valoresModParametros[lngParam.CodAlarmaParametro] =
                                                  point.longitude.toString();
                                            });
                                          },
                                        ),
                                        children: [
                                          TileLayer(
                                            urlTemplate:
                                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                            userAgentPackageName:
                                                'com.GEINTRA.ageinplace_caregiver',
                                          ),
                                          if (selectedLatLngMod != null)
                                            CircleLayer(
                                              circles: circleMarkersMod,
                                            ),
                                          if (selectedLatLngMod != null)
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
                                  const SizedBox(height: 8),
                                  Text(
                                    isSpanish
                                        ? 'Toque en el mapa para cambiar la ubicación'
                                        : 'Tap on the map to change the location',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await DBPostgres().DBModAlarmaPacienteConfig(
                                  AlarmasPacienteList[index].CodAlarmaPaciente,
                                  desAlarmaController.text,
                                );
                                
                                for (var entry in valoresModParametros.entries) {
                                  await DBPostgres().DBModAlarmaPacienteConfigParam(
                                    AlarmasPacienteList[index].CodAlarmaPaciente,
                                    entry.key,
                                    entry.value,
                                  );
                                }
                                
                                setState(() {
                                  getData();
                                });
                                
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isSpanish
                                            ? 'Alarma actualizada correctamente'
                                            : 'Alarm updated successfully',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.save, color: Colors.white),
                              label: Text(
                                isSpanish ? 'Guardar cambios' : 'Save changes',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorPrimario,
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
                                      'CURRENT_TIMESTAMP',
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
                                            ? 'Alarma desactivada'
                                            : 'Alarm deactivated',
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.block,
                                color: Colors.white,
                              ),
                              label: Text(
                                isSpanish ? 'Desactivar' : 'Deactivate',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
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

  Future<dynamic> _angadirAlarma(BuildContext context) {
    final TextEditingController radioPuntoProhibidoController =
        TextEditingController();
    final TextEditingController desAlarmaController = TextEditingController();
    final TextEditingController duracionController = TextEditingController();
    List<CircleMarker> circleMarkers = [];
    TimeOfDay? horaInicio0;
    TimeOfDay? horaFin0;
    Map<int, String> valoresParametros = {};
    late LatLng? selectedLatLng;

    bool horaFinEsMenor = false;
    bool mostrarAdvertenciaRangoNocturno = false;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        showParametrosDropdown = false;
        desAlarmaController.text = '';
        valoresParametros = {};

        if (widget.CasaList.isNotEmpty) {
          selectedLatLng = LatLng(
            widget.CasaList[0].Latitud,
            widget.CasaList[0].Longitud,
          );
        } else {
          selectedLatLng = const LatLng(40.416775, -3.703790);
        }

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.add_alert, color: colorPrimario, size: 28),
                          const SizedBox(width: 10),
                          Text(
                            isSpanish ? "Añadir Alarma" : "Add Alarm",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: DropdownButtonFormField<Alarmas>(
                          items: AlarmasList.map(
                            (alarma) => DropdownMenuItem<Alarmas>(
                              value: alarma,
                              child: Text(
                                isSpanish
                                    ? alarma.Alarma
                                    : (alarmTranslationsEN[alarma.Alarma] ??
                                          alarma.Alarma),
                              ),
                            ),
                          ).toList(),
                          onChanged: (Alarmas? newValue) {
                            if (newValue != null) {
                              selectedCodAlarma = newValue.CodAlarma;
                              selectedAlarma = newValue.Alarma;
                              ParametrosList = AlarmaParametrosList.where(
                                (parametro) =>
                                    parametro.CodAlarma == selectedCodAlarma,
                              ).toList();
                              showParametrosDropdown = true;
                            } else {
                              showParametrosDropdown = false;
                            }
                            setState(() {
                              if (selectedAlarma == 'PUNTO PROHIBIDO' ||
                                  selectedAlarma == 'RANGO DE ACCION') {
                                if (ParametrosList.isNotEmpty) {
                                  try {
                                    codAlarmaParametroLatitud =
                                        ParametrosList.firstWhere(
                                          (parametro) =>
                                              parametro.Parametro == 'LATITUD',
                                        ).CodAlarmaParametro;

                                    codAlarmaParametroLongitud =
                                        ParametrosList.firstWhere(
                                          (parametro) =>
                                              parametro.Parametro == 'LONGITUD',
                                        ).CodAlarmaParametro;
                                    valoresParametros[codAlarmaParametroLatitud] =
                                        selectedLatLng!.latitude.toString();
                                    valoresParametros[codAlarmaParametroLongitud] =
                                        selectedLatLng!.longitude.toString();
                                  } catch (e) {
                                    print(
                                      'Error al obtener parámetros de latitud/longitud: $e',
                                    );
                                  }
                                }
                              }
                            });
                          },
                          decoration: InputDecoration(
                            labelText: isSpanish
                                ? 'Seleccionar alarma'
                                : 'Select alarm',
                            labelStyle: TextStyle(color: Colors.grey.shade600),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

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
                                ? 'Descripción de alarma'
                                : 'Alarm description',
                            labelStyle: TextStyle(color: Colors.grey.shade600),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      if (mostrarAdvertenciaRangoNocturno)
                        Container(
                          margin: const EdgeInsets.only(top: 16, bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber,
                                color: Colors.amber,
                                size: 20,
                              ),
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

                      if (showParametrosDropdown == true &&
                          selectedAlarma != "PUNTO PROHIBIDO" &&
                          selectedAlarma != "RANGO DE ACCION")
                        ...ParametrosList.map((parametro) {
                          if (parametro.Parametro == "HABITACION") {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: DropdownButtonFormField<Habitaciones>(
                                items: widget.HabitacionesList.map(
                                  (
                                    habitacion,
                                  ) => DropdownMenuItem<Habitaciones>(
                                    value: habitacion,
                                    child: Text(
                                      '${habitacion.TipoHabitacion} ${habitacion.Observaciones}',
                                    ),
                                  ),
                                ).toList(),
                                onChanged: (Habitaciones? value) {
                                  if (value != null) {
                                    setState(() {
                                      valoresParametros[parametro
                                              .CodAlarmaParametro] =
                                          value.CodHabitacionSensor!;
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                  labelText: isSpanish ? 'Habitación' : 'Room',
                                  labelStyle: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            );
                          } else if (parametro.Parametro == "HORA INICIO") {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: () async {
                                  final selectedTimeInicio =
                                      await showTimePicker(
                                        context: context,
                                        initialTime:
                                            horaInicio0 ?? TimeOfDay.now(),
                                      );
                                  if (selectedTimeInicio != null) {
                                    setState(() {
                                      horaInicio0 = selectedTimeInicio;
                                      valoresParametros[parametro
                                              .CodAlarmaParametro] =
                                          'TimeOfDay(${horaInicio0!.hour.toString().padLeft(2, '0')}:${horaInicio0!.minute.toString().padLeft(2, '0')})';

                                      if (horaFin0 != null) {
                                        horaFinEsMenor = _esHoraFinMenor(
                                          horaInicio0!,
                                          horaFin0!,
                                        );
                                        mostrarAdvertenciaRangoNocturno =
                                            horaFinEsMenor;
                                      }
                                    });
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          color: colorPrimario,
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              isSpanish
                                                  ? 'Hora de inicio'
                                                  : 'Start time',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            Text(
                                              horaInicio0?.format(context) ??
                                                  (isSpanish
                                                      ? 'Seleccionar'
                                                      : 'Select'),
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else if (parametro.Parametro == "HORA FIN") {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: () async {
                                  final selectedTimeFin = await showTimePicker(
                                    context: context,
                                    initialTime: horaFin0 ?? TimeOfDay.now(),
                                  );
                                  if (selectedTimeFin != null) {
                                    setState(() {
                                      horaFin0 = selectedTimeFin;
                                      valoresParametros[parametro
                                              .CodAlarmaParametro] =
                                          'TimeOfDay(${horaFin0!.hour.toString().padLeft(2, '0')}:${horaFin0!.minute.toString().padLeft(2, '0')})';

                                      if (horaInicio0 != null) {
                                        horaFinEsMenor = _esHoraFinMenor(
                                          horaInicio0!,
                                          horaFin0!,
                                        );
                                        mostrarAdvertenciaRangoNocturno =
                                            horaFinEsMenor;
                                      }
                                    });
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          color: colorPrimario,
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              isSpanish
                                                  ? 'Hora de fin'
                                                  : 'End time',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            Text(
                                              horaFin0?.format(context) ??
                                                  (isSpanish
                                                      ? 'Seleccionar'
                                                      : 'Select'),
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
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
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: TextFormField(
                                controller: duracionController,
                                decoration: InputDecoration(
                                  labelText: isSpanish
                                      ? 'Duración (HH:mm)'
                                      : 'Duration (HH:mm)',
                                  labelStyle: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                onChanged: (value) {
                                  codAlarmaParametro =
                                      ParametrosList.firstWhere(
                                        (parametro) =>
                                            parametro.Parametro == 'DURACION',
                                      ).CodAlarmaParametro;
                                  valoresParametros[codAlarmaParametro] =
                                      duracionController.text;
                                },
                              ),
                            );
                          } else if (parametro.Parametro == "FRECUENCIA") {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (value) {
                                  valoresParametros[parametro
                                          .CodAlarmaParametro] =
                                      value;
                                },
                                decoration: InputDecoration(
                                  labelText: isSpanish
                                      ? 'Frecuencia'
                                      : 'Frequency',
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
                            );
                          } else {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: TextFormField(
                                onChanged: (value) {
                                  valoresParametros[parametro
                                          .CodAlarmaParametro] =
                                      value;
                                },
                                decoration: InputDecoration(
                                  labelText: parametro.Parametro,
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
                            );
                          }
                        }).toList(),

                      if (showParametrosDropdown == true &&
                          (selectedAlarma == "PUNTO PROHIBIDO" ||
                              selectedAlarma == "RANGO DE ACCION"))
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: TextFormField(
                                controller: radioPuntoProhibidoController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+(?:\.\d{0,2})?$'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    try {
                                      codAlarmaParametro =
                                          ParametrosList.firstWhere(
                                            (parametro) =>
                                                parametro.Parametro == 'RADIO',
                                          ).CodAlarmaParametro;

                                      _radioEnMetros =
                                          (double.tryParse(value) ?? 0) * 1000;
                                      valoresParametros[codAlarmaParametro] =
                                          _radioEnMetros.toString();
                                      circleMarkers = [
                                        CircleMarker(
                                          point: selectedLatLng!,
                                          radius: _radioEnMetros,
                                          color: Colors.blue.withOpacity(0.5),
                                          borderColor: colorPrimario,
                                          borderStrokeWidth: 2,
                                          useRadiusInMeter: true,
                                        ),
                                      ];
                                    } catch (e) {
                                      print('Error al configurar radio: $e');
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: isSpanish
                                      ? 'Radio (Km)'
                                      : 'Radius (Km)',
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

                            if (selectedAlarma == "PUNTO PROHIBIDO")
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: colorPrimario,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        isSpanish
                                            ? 'Toque en el mapa para seleccionar el punto prohibido'
                                            : 'Tap on the map to select the forbidden point',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 16),
                            Container(
                              height: 300,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: FlutterMap(
                                  mapController: _mapController,
                                  options: MapOptions(
                                    initialCenter: LatLng(
                                      widget.CasaList.isNotEmpty
                                          ? widget.CasaList[0].Latitud
                                          : 40.416775,
                                      widget.CasaList.isNotEmpty
                                          ? widget.CasaList[0].Longitud
                                          : -3.703790,
                                    ),
                                    initialZoom: 16,
                                    maxZoom: 18,
                                    minZoom: 2,
                                    onTap: (tapPosition, point) {
                                      setState(() {
                                        selectedLatLng = point;
                                        circleMarkers = [
                                          CircleMarker(
                                            point: selectedLatLng!,
                                            radius: _radioEnMetros,
                                            color: Colors.blue.withOpacity(0.5),
                                            borderColor: colorPrimario,
                                            borderStrokeWidth: 2,
                                            useRadiusInMeter: true,
                                          ),
                                        ];
                                        selectedLatitude = point.latitude;
                                        selectedLongitude = point.longitude;

                                        try {
                                          codAlarmaParametroLatitud =
                                              ParametrosList.firstWhere(
                                                (parametro) =>
                                                    parametro.Parametro ==
                                                    'LATITUD',
                                              ).CodAlarmaParametro;

                                          codAlarmaParametroLongitud =
                                              ParametrosList.firstWhere(
                                                (parametro) =>
                                                    parametro.Parametro ==
                                                    'LONGITUD',
                                              ).CodAlarmaParametro;

                                          valoresParametros[codAlarmaParametroLatitud] =
                                              selectedLatitude.toString();
                                          valoresParametros[codAlarmaParametroLongitud] =
                                              selectedLongitude.toString();
                                        } catch (e) {
                                          print(
                                            'Error al obtener parámetros: $e',
                                          );
                                        }
                                      });
                                    },
                                  ),
                                  children: [
                                   TileLayer(
                                        urlTemplate:
                                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        userAgentPackageName:
                                            'com.AgeInPlace_caregiver.app', 
                                      ),
                                    if (selectedLatLng != null)
                                      CircleLayer(circles: circleMarkers),
                                    if (selectedLatLng != null)
                                      MarkerLayer(
                                        markers: [
                                          Marker(
                                            point: selectedLatLng!,
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

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (selectedAlarma == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isSpanish
                                        ? 'Por favor seleccione una alarma'
                                        : 'Please select an alarm',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (desAlarmaController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isSpanish
                                        ? 'Por favor ingrese una descripción'
                                        : 'Please enter a description',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            var codAlarmaPaciente = await DBPostgres()
                                .DBAnagdirAlarmaPaciente(
                                  widget.paciente.CodPaciente,
                                  selectedCodAlarma,
                                  desAlarmaController.text,
                                );
                            if (codAlarmaPaciente != null) {
                              for (var entry in valoresParametros.entries) {
                                await DBPostgres()
                                    .DBAnagdirAlarmaPacienteConfigParam(
                                      codAlarmaPaciente,
                                      entry.key,
                                      entry.value,
                                    );
                              }
                              setState(() {
                                getData();
                              });
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isSpanish
                                          ? 'Alarma agregada correctamente'
                                          : 'Alarm added successfully',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: Text(
                            isSpanish ? 'Agregar' : 'Add',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorPrimario,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}