import 'dart:async';
import 'dart:core';
import 'dart:math';

import 'package:ageinplace/Cuidador/screen_Pacientes.dart';
import '../models/wearable.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../Cuidador/screen_Paciente.dart';
import '../Paciente/screen_Paciente.dart';
import '../base_de_datos/influx.dart';
import '../base_de_datos/postgres.dart';
import '../services/shared_date_service.dart';

class AlarmADLPage extends StatefulWidget {
  final Paciente paciente;
  final Wearable wearable;
  final List<Habitaciones> habitaciones;
  final List<Casa> casas;

  const AlarmADLPage({
    super.key,
    required this.paciente,
    required this.wearable,
    required this.habitaciones,
    required this.casas,
  });

  @override
  _AlarmADLPageState createState() => _AlarmADLPageState();
}

class _AlarmADLPageState extends State<AlarmADLPage> {
  List<Casa> CasaList = [];
  List<AlarmasPaciente> AlarmasPacienteList = [];
  List<AlarmasParametrosValor> AlarmasPacienteParametroList = [];
  List<Habitaciones> HabitacionesList = [];
  late GlobalKey<State> chartKey;
  var baterryList = <BaterryData>[];
  late bool _enableAnchor;
  TrackballBehavior? _trackballBehavior;
  late int showingTooltip = 0;
  late double touchedValue;
  int touchedIndex = -1;
  final bool _isChartTouched = false;
  List<WeightedLatLng> data = [];
  var index = 0;
  final StreamController<void> _rebuildStream = StreamController.broadcast();
  late List<FlSpot> dataLTSM = [];
  late List<FlSpot> dataConsumo = [];
  late List<AlarmData> dataAlarm = [];
  var AlarmsList = <AlarmaData>[];
  var AlarmsListStat = <AlarmaData2>[];
  var AlarmsListStat2 = <AlarmaData2>[];
  List<AlarmaData2> AlamrHistory = [];
  List<AlarmaData2> ADLsHistory = [];
  List<AlarmaData2> EvADLsHistory = [];

  var AlarmsListHistory = <AlarmaData2>[];
  var AlarmsListHistory2 = <AlarmaData2>[];
  var ADLsListHistory = <AlarmaData2>[];
  var EvADLsListHistory = <AlarmaData2>[];
  List<LTSMData> LTSMList = [];
  List<LTSMData> ConsumoList = [];
  List<Sensores> SmartMeter = [];
  late double firstTimestamp = DateTime.now().millisecondsSinceEpoch.toDouble();
  late double lastTimestamp = DateTime.now().millisecondsSinceEpoch.toDouble();
  List<ShowingTooltipIndicators> tooltipIndicators = [];
  int minValue = 0;
  DateTime now = DateTime.now();

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _startDateStatDiar;
  DateTime? _endDateStatDiar;
  
  final colorPrimario = const Color.fromARGB(255, 25, 144, 234);
  
  // Variable para idioma
  late bool isSpanish;
  
  final Random random = Random();
  final List<Polyline> polylines = [];
  late final MapController mapController;
  late double minYValue;
  late double maxYValue;
  late int intervalY = 20;
  late int maxLabelsY;
  late int roundedMaxY;

  // Controlador para cancelar operaciones asíncronas
  late final CancelToken _cancelToken;

  final List<Color> customColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.cyan,
    Colors.teal,
    Colors.pinkAccent,
    Colors.amber,
    Colors.black,
    Colors.brown,
    Colors.deepPurple,
  ];

  // Mapas de traducción
  Map<String, String> alarmTranslations = {
    'HABITACION PROHIBIDA': 'FORBIDDEN ROOM',
    'PUNTO PROHIBIDO': 'FORBIDDEN POINT',
    'AUSENCIA': 'ABSENCE',
    'SEDENTARISMO': 'SEDENTARY',
    'RANGO DE ACCION': 'RANGE OF ACTION',
    'FRECUENCIA': 'FREQUENCY',
    'Alarma Caida': 'Fall Alarm',
    'Boton Panico': 'Panic Button',
  };
  
  Map<String, String> adlTranslations = {
    'DORMIR': 'SLEEP',
    'DESAYUNAR': 'BREAKFAST',
    'COMER': 'LUNCH',
    'CENAR': 'DINNER',
    'OCIO': 'LEISURE',
    'ASEO': 'HYGIENE',
  };

  bool sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  late bool isCardView = false;
  late double newMaxY = 0;
  late double newMaxY2 = 0;

  late DateTime minTimestamp;
  late DateTime maxTimestamp;
  late int dataCount;
  late int maxLabelsX;
  late int intervalX;
  late double separationPercentageX;
  late Duration separationX;
  late DateTime newMaxTimestamp;
  late var habitacion = Habitaciones(
    1,
    'Observaciones',
    1,
    1,
    'TipoHabitacion',
    DateTime.now(),
    null,
    null,
    null,
    null,
    null,
  );

  @override
  void initState() {
    super.initState();
    
    // Inicializar idioma y listener
    FlutterLocalization.instance.onTranslatedLanguage = _onLanguageChanged;
    isSpanish = FlutterLocalization.instance.currentLocale?.languageCode == 'es';
    
    chartKey = GlobalKey<State>();
    _enableAnchor = true;
    _cancelToken = CancelToken();

    // Inicializar fechas desde el servicio compartido
    if (SharedDateService.fechaInicio == null || SharedDateService.fechaFin == null) {
      SharedDateService.setDefaultRange();
    }
    
    setState(() {
      _startDate = SharedDateService.fechaInicio;
      _endDate = SharedDateService.fechaFin;
      _startDateStatDiar = SharedDateService.fechaInicio;
      _endDateStatDiar = SharedDateService.fechaFin;
      
      // Ejecutar getData y getData1 sin await para no bloquear
      _safeGetData();
      _safeGetData1();
    });
    mapController = MapController();
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
    _cancelToken.cancel();
    _rebuildStream.close();
    super.dispose();
  }

  Future<void> _safeGetData() async {
    if (!mounted) return;
    await getData();
  }

  Future<void> _safeGetData1() async {
    if (!mounted) return;
    await getData1();
  }

  BarChartGroupData generateGroupData(int x, int y) {
    return BarChartGroupData(
      x: x,
      showingTooltipIndicators: showingTooltip == x ? [0] : [],
      barRods: [BarChartRodData(toY: y.toDouble())],
    );
  }

  // Widget para seleccionar rango de fechas
  Widget _buildDateRangePicker() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _seleccionarRangoFechas,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorPrimario,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                SharedDateService.getRangoFormateado(isSpanish: isSpanish),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }

  // Botón para restablecer fechas
  Widget _buildClearDatesButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      child: IconButton(
        icon: const Icon(Icons.refresh, color: Colors.grey),
        onPressed: () {
          SharedDateService.setDefaultRange();
          setState(() {
            _startDate = SharedDateService.fechaInicio;
            _endDate = SharedDateService.fechaFin;
            _startDateStatDiar = SharedDateService.fechaInicio;
            _endDateStatDiar = SharedDateService.fechaFin;
          });
          _cargarDatosConDialogo();
        },
        tooltip: isSpanish ? 'Restablecer fechas' : 'Reset dates',
      ),
    );
  }

  // Función para seleccionar rango de fechas
  Future<void> _seleccionarRangoFechas() async {
    if (_cancelToken.isCancelled) return;
    
    final ahora = DateTime.now();
    
    // Valores iniciales
    DateTime inicio = _startDate ?? ahora.subtract(const Duration(days: 7));
    DateTime fin = _endDate ?? ahora;
    
    // Mostrar selector de rango
    final DateTimeRange? rangoSeleccionado = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: inicio, end: fin),
      firstDate: DateTime(2020),
      lastDate: ahora,
      helpText: isSpanish ? 'Seleccionar rango de fechas' : 'Select date range',
      confirmText: isSpanish ? 'Aceptar' : 'OK',
      cancelText: isSpanish ? 'Cancelar' : 'Cancel',
      saveText: isSpanish ? 'Guardar' : 'Save',
      
      initialEntryMode: DatePickerEntryMode.calendar,
      
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: colorPrimario,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: colorPrimario,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (rangoSeleccionado == null || _cancelToken.isCancelled) return;

    // Validar rango máximo
    final diasDiferencia = rangoSeleccionado.end.difference(rangoSeleccionado.start).inDays;
    if (diasDiferencia > 7) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isSpanish 
                ? '❌ El rango máximo permitido es de 7 días'
                : '❌ Maximum allowed range is 7 days'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Guardar en servicio compartido
    SharedDateService.setRango(
      DateTime(
        rangoSeleccionado.start.year,
        rangoSeleccionado.start.month,
        rangoSeleccionado.start.day,
        0, 0,
      ),
      DateTime(
        rangoSeleccionado.end.year,
        rangoSeleccionado.end.month,
        rangoSeleccionado.end.day,
        23, 59,
      ),
    );

    if (!mounted || _cancelToken.isCancelled) return;

    setState(() {
      _startDate = SharedDateService.fechaInicio;
      _endDate = SharedDateService.fechaFin;
      _startDateStatDiar = SharedDateService.fechaInicio;
      _endDateStatDiar = SharedDateService.fechaFin;
    });
    
    _cargarDatosConDialogo();
  }

  void _cargarDatosConDialogo() {
    if (!mounted || _cancelToken.isCancelled) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Color.fromARGB(255, 25, 144, 234)),
                const SizedBox(height: 20),
                Text(
                  isSpanish ? 'Cargando datos...' : 'Loading data...',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorPrimario.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${isSpanish ? 'Rango' : 'Range'}: ${DateFormat('dd/MM/yyyy HH:mm').format(_startDate!)} - ${DateFormat('dd/MM/yyyy HH:mm').format(_endDate!)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${isSpanish ? 'Días' : 'Days'}: ${_endDate!.difference(_startDate!).inDays}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorPrimario),
                ),
              ],
            ),
          ),
        );
      },
    );
    
    getData().then((_) {
      if (mounted && !_cancelToken.isCancelled) {
        Navigator.pop(context);
      }
    }).catchError((error) {
      if (mounted && !_cancelToken.isCancelled) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isSpanish 
              ? 'Error al cargar datos: $error'
              : 'Error loading data: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  List<int> Codigo_pintar = [];

  Future<String> getData1() async {
    if (_cancelToken.isCancelled) return 'Cancelled';
    
    try {
      var Dbdata = await DBPostgres().DBGetDatosPacienteCuidador2(
        widget.paciente.CodPaciente,
        'null',
      );
      
      if (_cancelToken.isCancelled) return 'Cancelled';
      
      if (mounted) {
        setState(() {
          for (var p in Dbdata[1]) {
            HabitacionesList.add(
              Habitaciones(
                p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9], p[10],
              ),
            );
          }
          for (var i = 0; i < HabitacionesList.length; i++) {
            if (HabitacionesList[i].CodHabitacionSensor != null) {
              Codigo_pintar.add(i + 1);
            }
          }
        });
      }
    } catch (e) {
      if (!_cancelToken.isCancelled) {
        // Log error
      }
    }
    return 'Successfully Fetched data';
  }

  List<T> _diezmarLista<T>(List<T> lista, int maxElementos) {
    if (lista.length <= maxElementos) return lista;
    
    List<T> resultado = [];
    int paso = (lista.length / maxElementos).ceil();
    
    for (int i = 0; i < lista.length; i += paso) {
      resultado.add(lista[i]);
    }
    
    if (resultado.isNotEmpty && resultado.last != lista.last) {
      resultado.add(lista.last);
    }
    
    return resultado;
  }

  Future<void> getData() async {
    if (_cancelToken.isCancelled) return;
    
    try {
      var Dbdata = await DBPostgres().DBGetDatosPacienteCuidador2(
        widget.paciente.CodPaciente,
        'null',
      );
      
      if (_cancelToken.isCancelled) return;
      
      if (mounted) {
        setState(() {
          for (var p in Dbdata[0]) {
            CasaList.add(Casa(p[0], p[1], p[2], p[3], p[4]));
          }
          for (var p in Dbdata[1]) {
            HabitacionesList.add(
              Habitaciones(
                p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9], p[10],
              ),
            );
          }
          for (var i = 0; i < HabitacionesList.length; i++) {
            if (HabitacionesList[i].CodHabitacionSensor != null) {
              Codigo_pintar.add(i + 1);
            }
          }
          for (var p in Dbdata[3]) {
            SmartMeter.add(
              Sensores(
                p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9], p[10], p[11], p[12], p[13],
              ),
            );
          }
        });
      }

      if (_cancelToken.isCancelled) return;

      var DbAlarma = await DBPostgres().DBGetAlarmaPaciente(
        widget.paciente.CodPaciente,
        'null',
      );
      
      if (_cancelToken.isCancelled) return;
      
      for (var p in DbAlarma[0]) {
        AlarmasPacienteList.add(
          AlarmasPaciente(p[0], p[1], p[2], p[3], p[4], p[5]),
        );
      }

      if (_startDate == null || _endDate == null || _cancelToken.isCancelled) return;

      var startFormatted = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(_startDate!.toUtc());
      var endFormatted = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(_endDate!.toUtc());
      var startFormattedStatDiar = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(_startDateStatDiar!.toUtc());
      var endFormattedStatDiar = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(_endDateStatDiar!.toUtc());
      
      var diferenciaDias = _endDate!.difference(_startDate!).inDays;
      if (diferenciaDias > 7) {
        _endDate = _startDate!.add(const Duration(days: 7));
        _endDateStatDiar = _endDate;
        endFormatted = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(_endDate!.toUtc());
        endFormattedStatDiar = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(_endDateStatDiar!.toUtc());
      }
      
      var every = "30s";
      var difference = _endDate!.difference(_startDate!).inDays;
      
      if (difference <= 1) {
        every = "30s";
      } else if (difference <= 3) {
        every = "1m";
      } else if (difference <= 7) {
        every = "5m";
      } else {
        every = "15m";
      }

      int maxPoints = 2000;
      if (difference > 7) maxPoints = 1000;

      // GetAlarmStats
      if (!_cancelToken.isCancelled) {
        try {
          var alarms2 = await InfluxDBService().GetAlarmStats(
            widget.wearable.CodPacienteWearable,
            widget.wearable.IdWearable,
            AlarmasPacienteList,
            startFormatted,
            endFormatted,
            '30s',
          );
          
          if (!_cancelToken.isCancelled && alarms2.isNotEmpty && mounted) {
            setState(() {
              AlarmsListStat2.clear();
              AlarmsListHistory2.clear();
              AlarmsListStat2 = alarms2;

              for (AlarmasPaciente paciente in AlarmasPacienteList) {
                for (AlarmaData2 alarma2 in AlarmsListStat2) {
                  if (alarma2.Alarma == "panic_button") {
                    AlarmsListHistory2.add(
                      AlarmaData2("Boton Panico", alarma2.Valor, alarma2.timestamp),
                    );
                  } else if (alarma2.Alarma == "fall") {
                    AlarmsListHistory2.add(
                      AlarmaData2("Alarma Caida", alarma2.Valor, alarma2.timestamp),
                    );
                  } else if (paciente.CodAlarmaPaciente == alarma2.Alarma) {
                    AlarmsListHistory2.add(
                      AlarmaData2(
                        "${paciente.Alarma}: ${paciente.DesAlarma}",
                        alarma2.Valor,
                        alarma2.timestamp,
                      ),
                    );
                  }
                }
              }
            });
          }
        } catch (e) {
          if (!_cancelToken.isCancelled) {
            // Log error
          }
        }
      }

      if (_cancelToken.isCancelled) return;

      // GetHumTempBat
      if (!_cancelToken.isCancelled) {
        try {
          var nivel = await InfluxDBService().GetHumTempBat(
            widget.wearable.CodPacienteWearable,
            widget.wearable.IdWearable,
            startFormatted,
            endFormatted,
            every,
          );
          
          if (!_cancelToken.isCancelled && nivel != null && nivel.length > 3 && mounted) {
            setState(() {
              baterryList = nivel[3] ?? [];
            });
          }
        } catch (e) {
          if (!_cancelToken.isCancelled) {
            // Log error
          }
        }
      }

      if (_cancelToken.isCancelled) return;

      // GetLTSMAlarms
      if (!_cancelToken.isCancelled) {
        try {
          var alarms = await InfluxDBService().GetLTSMAlarms(
            widget.wearable.IdWearable,
            startFormatted,
            endFormatted,
            '30s',
          );
          if (!_cancelToken.isCancelled && alarms.isNotEmpty && mounted) {
            setState(() {
              AlarmsListHistory.clear();
              AlarmsListHistory = alarms;
            });
          }
        } catch (e) {
          if (!_cancelToken.isCancelled) {
            // Log error
          }
        }
      }

      if (_cancelToken.isCancelled) return;

      // GetADLs
      if (!_cancelToken.isCancelled) {
        try {
          var adl = await InfluxDBService().GetADLs(
            widget.wearable.IdWearable,
            startFormatted,
            endFormatted,
            '30s',
          );
          if (!_cancelToken.isCancelled && adl.isNotEmpty && mounted) {
            setState(() {
              ADLsListHistory.clear();
              ADLsListHistory = adl;
            });
          }
        } catch (e) {
          if (!_cancelToken.isCancelled) {
            // Log error
          }
        }
      }

      if (_cancelToken.isCancelled) return;

      // GetEvADLs
      if (!_cancelToken.isCancelled) {
        try {
          var evadl = await InfluxDBService().GetEvADLs(
            widget.wearable.IdWearable,
            startFormatted,
            endFormatted,
            '30s',
          );
          if (!_cancelToken.isCancelled && evadl.isNotEmpty && mounted) {
            setState(() {
              EvADLsListHistory.clear();
              EvADLsListHistory = evadl;
            });
          }
        } catch (e) {
          if (!_cancelToken.isCancelled) {
            // Log error
          }
        }
      }

    } catch (e) {
      if (!_cancelToken.isCancelled && mounted) {
        // Mostrar error al usuario si es necesario
      }
    }
  }

  String translateAlarm(String alarm) {
    if (isSpanish) {
      return alarm;
    } else {
      return alarmTranslations[alarm] ?? alarm;
    }
  }
  
  String translateADL(String adl) {
    if (isSpanish) {
      return adl;
    } else {
      return adlTranslations[adl] ?? adl;
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      if (!mounted) return Container();
      
      bool hasData = baterryList.isNotEmpty || SmartMeter.isNotEmpty || AlarmsListHistory2.isNotEmpty ||
                     AlarmsListHistory.isNotEmpty || ADLsListHistory.isNotEmpty || EvADLsListHistory.isNotEmpty;

      if (!hasData) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _buildDateRangePicker(),
                      ),
                      const SizedBox(width: 10),
                      _buildClearDatesButton(),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: colorPrimario.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.analytics_outlined,
                              size: 60,
                              color: colorPrimario,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            isSpanish ? 'No hay datos disponibles' : 'No data available', 
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isSpanish ? 'Para el período seleccionado:' : 'For the selected period:', 
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: colorPrimario.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              SharedDateService.getRangoFormateado(isSpanish: isSpanish),
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colorPrimario),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () { 
                              if (mounted) {
                                setState(() { 
                                  _safeGetData(); 
                                }); 
                              }
                            },
                            icon: const Icon(Icons.refresh, size: 18),
                            label: Text(isSpanish ? 'Reintentar' : 'Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorPrimario,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con selector de fechas
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDateRangePicker(),
                            ),
                            const SizedBox(width: 10),
                            _buildClearDatesButton(),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  
                  // GRÁFICO 1: Historial de alarmas (sobre energía)
                  if (AlarmsListHistory.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.notifications_active, color: colorPrimario, size: 24),
                              const SizedBox(width: 10),
                              Text(
                                isSpanish 
                                  ? 'Historial de alarmas (sobre energía)'
                                  : 'Alarm history (on energy)',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueGrey[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 250,
                            child: SfCartesianChart(
                              zoomPanBehavior: ZoomPanBehavior(
                                enablePinching: true,
                                zoomMode: ZoomMode.xy,
                                enablePanning: true,
                                enableMouseWheelZooming: true,
                              ),
                              plotAreaBorderWidth: 0,
                              legend: Legend(
                                isVisible: true,
                                overflowMode: LegendItemOverflowMode.wrap,
                              ),
                              primaryXAxis: DateTimeAxis(
                                edgeLabelPlacement: EdgeLabelPlacement.shift,
                                dateFormat: DateFormat('HH:mm d/M/y'),
                                interval: 2,
                                majorGridLines: const MajorGridLines(width: 0),
                              ),
                              primaryYAxis: NumericAxis(
                                labelFormat: '{value}',
                                minimum: 0,
                                maximum: 1,
                                interval: 1,
                                axisLine: const AxisLine(width: 0),
                                axisLabelFormatter: (axisLabelRenderArgs) {
                                  final labelValue = axisLabelRenderArgs.value;
                                  if (labelValue == 1) {
                                    return ChartAxisLabel(
                                      isSpanish ? 'Activa' : 'On',
                                      axisLabelRenderArgs.textStyle,
                                    );
                                  } else {
                                    return ChartAxisLabel(
                                      isSpanish ? 'Inactiva' : 'Off',
                                      axisLabelRenderArgs.textStyle,
                                    );
                                  }
                                },
                                majorTickLines: const MajorTickLines(color: Colors.transparent),
                              ),
                              series: _getAlarmHistoryLTSMLineSeries(),
                              tooltipBehavior: TooltipBehavior(enable: true),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                  
                  // GRÁFICO 2: Actividades de la vida diaria
                  if (ADLsListHistory.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.event_note, color: colorPrimario, size: 24),
                              const SizedBox(width: 10),
                              Text(
                                isSpanish 
                                  ? 'Actividades de la vida diaria'
                                  : 'Activities of Daily Living',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueGrey[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 250,
                            child: SfCartesianChart(
                              zoomPanBehavior: ZoomPanBehavior(
                                enablePinching: true,
                                zoomMode: ZoomMode.xy,
                                enablePanning: true,
                                enableMouseWheelZooming: true,
                              ),
                              plotAreaBorderWidth: 0,
                              legend: Legend(
                                isVisible: true,
                                overflowMode: LegendItemOverflowMode.wrap,
                              ),
                              primaryXAxis: DateTimeAxis(
                                edgeLabelPlacement: EdgeLabelPlacement.shift,
                                dateFormat: DateFormat('HH:mm d/M/y'),
                                interval: 2,
                                majorGridLines: const MajorGridLines(width: 0),
                              ),
                              primaryYAxis: NumericAxis(
                                labelFormat: '{value}',
                                minimum: 0,
                                maximum: 1,
                                interval: 1,
                                axisLine: const AxisLine(width: 0),
                                axisLabelFormatter: (axisLabelRenderArgs) {
                                  final labelValue = axisLabelRenderArgs.value;
                                  if (labelValue == 1) {
                                    return ChartAxisLabel(
                                      isSpanish ? 'Activa' : 'On',
                                      axisLabelRenderArgs.textStyle,
                                    );
                                  } else {
                                    return ChartAxisLabel(
                                      isSpanish ? 'Inactiva' : 'Off',
                                      axisLabelRenderArgs.textStyle,
                                    );
                                  }
                                },
                                majorTickLines: const MajorTickLines(color: Colors.transparent),
                              ),
                              series: _getADLsStepSeries(),
                              tooltipBehavior: TooltipBehavior(enable: true),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                  
                  // GRÁFICO 3: Evaluación de las actividades de la vida diaria
                  if (EvADLsListHistory.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.assessment, color: colorPrimario, size: 24),
                              const SizedBox(width: 10),
                              Text(
                                isSpanish 
                                  ? 'Evaluación de las actividades de la vida diaria'
                                  : 'Evaluation of Activities of Daily Living',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueGrey[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 250,
                            child: SfCartesianChart(
                              zoomPanBehavior: ZoomPanBehavior(
                                enablePinching: true,
                                zoomMode: ZoomMode.xy,
                                enablePanning: true,
                                enableMouseWheelZooming: true,
                              ),
                              plotAreaBorderWidth: 0,
                              legend: Legend(
                                isVisible: true,
                                position: LegendPosition.bottom,
                              ),
                              primaryXAxis: DateTimeAxis(
                                dateFormat: DateFormat('HH:mm d/M/y'),
                                majorGridLines: const MajorGridLines(width: 0),
                              ),
                              primaryYAxis: NumericAxis(
                                minimum: 0,
                                maximum: 10,
                                interval: 1,
                                axisLine: const AxisLine(width: 0),
                                majorTickLines: const MajorTickLines(size: 0),
                              ),
                              series: getADLsEvSeries(),
                              tooltipBehavior: TooltipBehavior(enable: true),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      );
      
    } catch (e, stack) {
      if (!mounted) return Container();
      
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.error_outline, size: 50, color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${isSpanish ? 'Error' : 'Error'}: $e', 
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isSpanish ? 'Detalles:' : 'Details:', 
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SingleChildScrollView(
                        child: Text('$stack', style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  Color _getStepColor(DateTime timestamp, stepList) {
    final DateTime referenceDate = DateTime(
      stepList.first.timestamp.year,
      stepList.first.timestamp.month,
      stepList.first.timestamp.day,
    );

    final List<Color> colorList = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.yellow,
      Colors.deepPurple,
      Colors.cyan,
      Colors.brown,
    ];
    int days = timestamp.difference(referenceDate).inDays;
    int colorIndex = days % colorList.length;
    return colorList[colorIndex];
  }

  List<StepLineSeries<AlarmaData2, DateTime>> _getAlarmHistoryLineSeries() {
    List<StepLineSeries<AlarmaData2, DateTime>> seriesList2 = [];

    List uniqueAlarms2 = AlarmsListHistory2.map(
      (alarma2) => alarma2.Alarma,
    ).toSet().toList();

    for (String alarm2 in uniqueAlarms2) {
      List<AlarmaData2> alarmHistory2 = AlarmsListHistory2.where(
        (data2) => data2.Alarma == alarm2,
      ).toList();

      List<String> alarmParts2 = alarm2.split(':');

      String translatedAlarmName2 = translateAlarm(alarmParts2.first);

      String translatedAlarm2 =
          '$translatedAlarmName2: ${alarmParts2.skip(1).join(':')}';

      seriesList2.add(
        StepLineSeries<AlarmaData2, DateTime>(
          animationDuration: 2500,
          dataSource: alarmHistory2,
          xValueMapper: (AlarmaData2 data2, _) => data2.timestamp,
          yValueMapper: (AlarmaData2 data2, _) => data2.Valor,
          width: 2,
          name: translatedAlarm2,
          markerSettings: const MarkerSettings(isVisible: false),
          dataLabelSettings: const DataLabelSettings(isVisible: false),
        ),
      );
    }

    return seriesList2;
  }

  List<LineSeries<LTSMData, DateTime>> getLTSMPanningSeries() {
    List<LineSeries<LTSMData, DateTime>> seriesList = [];

    List<String> uniqueNames = LTSMList.map(
      (data) => data.name,
    ).toSet().toList();

    for (String name in uniqueNames) {
      List<LTSMData> nameData = LTSMList.where(
        (data) => data.name == name,
      ).toList();

      seriesList.add(
        LineSeries<LTSMData, DateTime>(
          animationDuration: 2500,
          dataSource: nameData,
          xValueMapper: (LTSMData data, _) => data.timestamp,
          yValueMapper: (LTSMData data, _) => data.energy,
          width: 2,
          name: name,
        ),
      );
    }

    return seriesList;
  }

  List<LineSeries<LTSMData, DateTime>> getConsumoPanningSeries() {
    List<LineSeries<LTSMData, DateTime>> seriesList = [];

    List<String> uniqueNames = ConsumoList.map(
      (data) => data.name,
    ).toSet().toList();
    for (int i = 0; i < uniqueNames.length; i++) {
      String name = uniqueNames[i];
      List<LTSMData> nameData = ConsumoList.where(
        (data) => data.name == name,
      ).toList();

      seriesList.add(
        LineSeries<LTSMData, DateTime>(
          dataSource: nameData,
          xValueMapper: (LTSMData data, _) => data.timestamp,
          yValueMapper: (LTSMData data, _) => data.energy,
          color: customColors[i % customColors.length],
          name: name,
          markerSettings: const MarkerSettings(isVisible: false),
        ),
      );
    }

    return seriesList;
  }

  List<ScatterSeries<AlarmaData2, DateTime>> getADLsEvSeries() {
    List<ScatterSeries<AlarmaData2, DateTime>> seriesList = [];

    List uniqueRooms = EvADLsListHistory.map(
      (alarma) => alarma.Alarma,
    ).toSet().toList();
    
    for (String Alarma in uniqueRooms) {
      List<AlarmaData2> alarmasFiltradas = EvADLsListHistory.where(
        (data) => data.Alarma == Alarma,
      ).toList();

      seriesList.add(
        ScatterSeries<AlarmaData2, DateTime>(
          animationDuration: 2500,
          dataSource: alarmasFiltradas,
          xValueMapper: (AlarmaData2 data, _) => data.timestamp,
          yValueMapper: (AlarmaData2 data, _) => data.Valor,
          name: translateADL(Alarma),
          markerSettings: const MarkerSettings(isVisible: true),
        ),
      );
    }

    return seriesList;
  }

  List<StepLineSeries<AlarmaData2, DateTime>> _getADLsStepSeries() {
    List<StepLineSeries<AlarmaData2, DateTime>> seriesList = [];

    List uniqueRooms = ADLsListHistory.map(
      (alarma) => alarma.Alarma,
    ).toSet().toList();
    
    for (String Alarma in uniqueRooms) {
      List<AlarmaData2> alarmasFiltradas = ADLsListHistory.where(
        (data) => data.Alarma == Alarma,
      ).toList();

      seriesList.add(
        StepLineSeries<AlarmaData2, DateTime>(
          animationDuration: 2500,
          dataSource: alarmasFiltradas,
          xValueMapper: (AlarmaData2 data, _) => data.timestamp,
          yValueMapper: (AlarmaData2 data, _) => data.Valor,
          width: 2,
          name: translateADL(Alarma),
          markerSettings: const MarkerSettings(isVisible: false),
          dataLabelSettings: const DataLabelSettings(isVisible: false),
        ),
      );
    }

    return seriesList;
  }

  List<StepLineSeries<AlarmaData2, DateTime>> _getAlarmHistoryLTSMLineSeries() {
    List<StepLineSeries<AlarmaData2, DateTime>> seriesList = [];

    List uniqueRooms = AlarmsListHistory.map(
      (alarma) => alarma.Alarma,
    ).toSet().toList();
    
    for (String Alarma in uniqueRooms) {
      List<AlarmaData2> alarmasFiltradas = AlarmsListHistory.where(
        (data) => data.Alarma == Alarma,
      ).toList();

      seriesList.add(
        StepLineSeries<AlarmaData2, DateTime>(
          animationDuration: 2500,
          dataSource: alarmasFiltradas,
          xValueMapper: (AlarmaData2 data, _) => data.timestamp,
          yValueMapper: (AlarmaData2 data, _) => data.Valor,
          width: 2,
          name: translateAlarm(Alarma),
          markerSettings: const MarkerSettings(isVisible: true),
          dataLabelSettings: const DataLabelSettings(isVisible: false),
        ),
      );
    }

    return seriesList;
  }

  List<StepLineSeries<AlarmData, DateTime>> _getAlarmLineSeries() {
    return <StepLineSeries<AlarmData, DateTime>>[
      StepLineSeries<AlarmData, DateTime>(
        animationDuration: 0,
        dataSource: dataAlarm,
        xValueMapper: (AlarmData sales, _) => sales.timestamp,
        yValueMapper: (AlarmData sales, _) => sales.Alarma,
        dataLabelMapper: (AlarmData sales, _) => sales.Alarma.toString(),
        width: 2,
        markerSettings: const MarkerSettings(isVisible: false),
      ),
    ];
  }

  Widget getTitlesAlarm(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    Widget text = const Text('', style: style);
    if (value == 0) {
      text = Text(isSpanish ? 'Alarma desactivada' : 'Alarm deactivated', style: style, textAlign: TextAlign.right);
    } else if (value == 1) {
      text = Text(isSpanish ? 'Alarma caída' : 'Fall alarm', style: style, textAlign: TextAlign.right);
    } else if (value == 2) {
      text = Text(isSpanish ? 'Botón Pánico' : 'Panic button', style: style, textAlign: TextAlign.right);
    } else if (value == 3) {
      text = Text(isSpanish ? 'Alarma caída y Botón Pánico' : 'Fall alarm and Panic button', style: style, textAlign: TextAlign.right);
    } else {
      text = const Text('', style: style, textAlign: TextAlign.right);
    }

    return SideTitleWidget(meta: meta, space: 20, child: text);
  }
}

// Clase auxiliar para cancelar operaciones
class CancelToken {
  bool _isCancelled = false;
  
  bool get isCancelled => _isCancelled;
  
  void cancel() {
    _isCancelled = true;
  }
}