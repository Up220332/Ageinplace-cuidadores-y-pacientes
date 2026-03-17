import 'dart:async';
import 'dart:core';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:geodesy/geodesy.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../Cuidador/screen_Paciente.dart';
import '../Cuidador/screen_Pacientes.dart';
import '../models/wearable.dart';
import '../base_de_datos/influx.dart';
import '../base_de_datos/postgres.dart';
import '../services/shared_date_service.dart';

class EstadisticasPage extends StatefulWidget {
  final Pacientes paciente;
  final Wearable wearable;
  final List<Habitaciones> habitaciones;
  final List<Casa> casas;

  const EstadisticasPage({
    super.key,
    required this.paciente,
    required this.wearable,
    required this.habitaciones,
    required this.casas,
  });

  @override
  _EstadisticasPageState createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage> {
  List<AlarmasPaciente> AlarmasPacienteList = [];
  List<AlarmasParametrosValor> AlarmasPacienteParametroList = [];
  List<Habitaciones> HabitacionesList = [];
  List<Sensores> SensoresPuerta = [];
  late GlobalKey<State> chartKey;
  late bool _enableAnchor;
  List<PercentageRoom> percentageRooms = [];
  TrackballBehavior? _trackballBehavior;
  late int showingTooltip = 0;
  List<BarChartGroupData>? BarPorcentajeOcupacion;
  late double touchedValue;
  int touchedIndex = -1;
  var roomList = <RoomData>[];
  var roomListStatDiar = <RoomData>[];
  var stepList = <StepData>[];
  var baterryList = <BaterryData>[];
  List<WeightedLatLng> data = [];
  var index = 0;
  List<Map<double, MaterialColor>> gradients = [
    HeatMapOptions.defaultGradient,
    {
      0.25: Colors.blue as MaterialColor,
      0.55: Colors.red as MaterialColor,
      0.85: Colors.pink as MaterialColor,
      1.0: Colors.purple as MaterialColor,
    },
  ];

  final colorPrimario = const Color.fromARGB(255, 25, 144, 234);
  
  // Variable para idioma
  late bool isSpanish;

  // Variables para fechas (usando servicio compartido)
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _startDateStatDiar;
  DateTime? _endDateStatDiar;
  bool _cargandoDatos = false;

  // Fechas permitidas
  final DateTime minAllowedDate = DateTime(2020, 1, 1);
  final DateTime maxAllowedDate = DateTime.now();

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

  Map<String, String> alarmTranslationsReverse = {
    'FORBIDDEN ROOM': 'HABITACION PROHIBIDA',
    'FORBIDDEN POINT': 'PUNTO PROHIBIDO',
    'ABSENCE': 'AUSENCIA',
    'SEDENTARY': 'SEDENTARISMO',
    'RANGE OF ACTION': 'RANGO DE ACCION',
    'FREQUENCY': 'FRECUENCIA',
    'Fall Alarm': 'Alarma Caida',
    'Panic Button': 'Boton Panico',
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
    'Zona no Sensorizada': 'Non-Sensorized Area',
  };

  Map<String, String> roomTypeTranslationsReverse = {
    'Bathroom': 'Baño',
    'Attic': 'Buhardilla',
    'Kitchen': 'Cocina',
    'Dining Room': 'Comedor',
    'Office': 'Despacho',
    'Bedroom': 'Dormitorio',
    'Entrance': 'Entrada',
    'Study': 'Estudio',
    'Garage': 'Garaje',
    'Room': 'Habitación',
    'Hall': 'Hall',
    'Laboratory': 'Laboratorio',
    'Hallway': 'Pasillo',
    'Patio': 'Patio',
    'Living Room': 'Salón',
    'Basement': 'Sótano',
    'Storage Room': 'Trastero',
    'Others': 'Otros',
    'Non-Sensorized Area': 'Zona no Sensorizada',
  };

  final StreamController<void> _rebuildStream = StreamController.broadcast();
  String? previousRoom;
  RoomData? lastRoomData;
  var filteredCombinedList = <RoomData>[];
  late List<RoomData> dataRoom = [];
  late List<Habitaciones> HabitacionesGrafica = [];
  late List<Habitaciones> HabitacionesList_aux = [];
  late List<Habitaciones> HabitacionesCompletas = [];
  late List<Habitaciones> TodasHabitaciones = [];
  late List<FlSpot> dataStep = [];
  late List<AlarmData> dataAlarm = [];
  late List<FlSpot> dataBaterry = [];
  var AlarmsList = <AlarmaData>[];
  var AlarmsListStat = <AlarmaData2>[];
  List<AlarmaData2> AlamrHistory = [];
  var AlarmsListHistory = <AlarmaData2>[];
  var DSList = <DoorSensorData2>[];
  var DSListStat = <DoorSensorData>[];
  List<DoorSensorData2> DSHistory = [];
  var DSListHistory = <DoorSensorData2>[];
  late List<LineChartBarData> lineBarsData = [];
  late double firstTimestamp = DateTime.now().millisecondsSinceEpoch.toDouble();
  late double lastTimestamp = DateTime.now().millisecondsSinceEpoch.toDouble();
  List<ShowingTooltipIndicators> tooltipIndicators = [];
  int minValue = 0;
  Map<int, double> percentageMap = {};
  DateTime now = DateTime.now();

  Map<DateTime, List<PercentageRoom>> roomTimeByDay = {};
  final List<List<LatLng>> dayPoints = [];
  final List<Color> colorsSinRojo = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.cyan,
    Colors.pink,
    Colors.teal,
    Colors.brown,
    Colors.indigo,
    Colors.lime,
    Colors.amber,
    Colors.deepPurple,
    Colors.lightBlue,
    Colors.lightGreen,
  ];
  final Random random = Random();
  final List<Polyline> polylines = [];
  late final MapController mapController;
  List<Coordenas> routeCoordinates = [];
  List<Coordenas> routeCoordinatesSinFiltrar = [];
  List<Marker> markers = [];
  var LongList = <LongData>[];
  var LatList = <LatData>[];
  late double minYValue;
  late double maxYValue;
  late int intervalY = 20;
  late int maxLabelsY;
  late int roundedMaxY;

  List<Polyline> _getPolylinesPorDia() {
    List<Polyline> polylinesPorDia = [];

    if (routeCoordinates.isEmpty) return polylinesPorDia;

    // Agrupar puntos por día
    Map<String, List<Coordenas>> puntosPorDia = {};

    for (var punto in routeCoordinates) {
      String diaKey =
          '${punto.timestamp.year}-${punto.timestamp.month}-${punto.timestamp.day}';
      if (!puntosPorDia.containsKey(diaKey)) {
        puntosPorDia[diaKey] = [];
      }
      puntosPorDia[diaKey]!.add(punto);
    }

    int index = 0;
    puntosPorDia.forEach((dia, puntos) {
      if (puntos.length > 1) {
        polylinesPorDia.add(
          Polyline(
            points: puntos.map((p) => p.coordenadas).toList(),
            strokeWidth: 4.0,
            color: colorsSinRojo[index % colorsSinRojo.length],
          ),
        );
      }
      index++;
    });

    return polylinesPorDia;
  }

  bool sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  late bool isCardView = false;

  late LatLng coordinates;
  late LatLng coor_casa;
  late double newMaxY = 0;

  // Paso 1: Obtén los valores mínimo y máximo de los timestamps
  late DateTime minTimestamp;
  late DateTime maxTimestamp;
  late // Paso 2: Calcula un valor de intervalo adecuado para los timestamps
  int
  dataCount;
  late int maxLabelsX;
  late int intervalX;

  // Paso 4: Agrega una separación configurable al valor máximo de los timestamps
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

  Future<String> getData_aux() async {
    var Dbdata = await DBPostgres().DBGetDatosPacienteCuidador(
      widget.paciente.CodPaciente,
      'null',
    );
    setState(() {
      for (var p in Dbdata[1]) {
        HabitacionesList_aux.add(
          Habitaciones(
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
          ),
        );
      }
    });
    return 'Successfully Fetched data';
  }

  //Calcula el punto medio entre dos coordenadas
  LatLng midPoint(LatLng p1, LatLng p2) {
    return LatLng(
      (p1.latitude + p2.latitude) / 2,
      (p1.longitude + p2.longitude) / 2,
    );
  }

  //Calcula la distancia entre dos coordenadas
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
    
    // Inicializar idioma y listener
    FlutterLocalization.instance.onTranslatedLanguage = _onLanguageChanged;
    isSpanish = FlutterLocalization.instance.currentLocale?.languageCode == 'es';
    
    chartKey = GlobalKey<State>();
    _enableAnchor = true;

    // Inicializar fechas desde el servicio compartido
    if (SharedDateService.fechaInicio == null ||
        SharedDateService.fechaFin == null) {
      SharedDateService.setDefaultRange();
    }

    setState(() {
      _fechaInicio = SharedDateService.fechaInicio;
      _fechaFin = SharedDateService.fechaFin;
      _startDate = _fechaInicio;
      _endDate = _fechaFin;
      _startDateStatDiar = _fechaInicio;
      _endDateStatDiar = _fechaFin;

      if (widget.casas.isNotEmpty) {
        routeCoordinates.add(
          Coordenas(
            LatLng(widget.casas[0].Latitud, widget.casas[0].Longitud),
            DateTime.now(),
          ),
        );
      }
      markers.clear();
      generarMarkers(widget.casas);
      getData();
      getData1();
      getData_aux();
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
    _rebuildStream.close();
    super.dispose();
  }

  BarChartGroupData generateGroupData(int x, int y) {
    return BarChartGroupData(
      x: x,
      showingTooltipIndicators: showingTooltip == x ? [0] : [],
      barRods: [BarChartRodData(toY: y.toDouble())],
    );
  }

  // seleccionar rango de fechas
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
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
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
            _fechaInicio = SharedDateService.fechaInicio;
            _fechaFin = SharedDateService.fechaFin;
            _startDate = _fechaInicio;
            _endDate = _fechaFin;
            _startDateStatDiar = _fechaInicio;
            _endDateStatDiar = _fechaFin;

            routeCoordinates.clear();
            markers.clear();
            data.clear();
            polylines.clear();
          });
          getData();
        },
        tooltip: isSpanish ? 'Restablecer fechas' : 'Reset dates',
      ),
    );
  }

  // Función para seleccionar rango de fechas
  Future<void> _seleccionarRangoFechas() async {
    final ahora = DateTime.now();

    // Valores iniciales
    DateTime inicio = _fechaInicio ?? ahora.subtract(const Duration(days: 7));
    DateTime fin = _fechaFin ?? ahora;

    // Mostrar selector de rango mejorado con selector de año
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
            // Botones de año más grandes y visibles
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: colorPrimario),
            ),
          ),
          child: child!,
        );
      },
    );

    if (rangoSeleccionado == null) return;

    // Validar rango máximo (30 días para estadísticas)
    final diasDiferencia = rangoSeleccionado.end
        .difference(rangoSeleccionado.start)
        .inDays;
    if (diasDiferencia > 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSpanish
                ? '❌ El rango máximo permitido es de 30 días'
                : '❌ Maximum allowed range is 30 days',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Guardar en servicio compartido
    SharedDateService.setRango(
      DateTime(
        rangoSeleccionado.start.year,
        rangoSeleccionado.start.month,
        rangoSeleccionado.start.day,
        0,
        0,
      ),
      DateTime(
        rangoSeleccionado.end.year,
        rangoSeleccionado.end.month,
        rangoSeleccionado.end.day,
        23,
        59,
      ),
    );

    setState(() {
      _fechaInicio = SharedDateService.fechaInicio;
      _fechaFin = SharedDateService.fechaFin;
      _startDate = _fechaInicio;
      _endDate = _fechaFin;
      _startDateStatDiar = _fechaInicio;
      _endDateStatDiar = _fechaFin;

      routeCoordinates.clear();
      markers.clear();
      data.clear();
      polylines.clear();
    });

    await getData();
  }

  // Función para exportar a CSV
  Future<void> _exportarACSV() async {
    bool hayDatos =
        baterryList.isNotEmpty ||
        stepList.isNotEmpty ||
        AlarmsListHistory.isNotEmpty ||
        roomList.isNotEmpty ||
        dataRoom.isNotEmpty ||
        routeCoordinates.isNotEmpty ||
        percentageMap.isNotEmpty;

    if (!hayDatos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSpanish ? 'No hay datos para exportar' : 'No data to export',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _cargandoDatos = true);

    try {
      List<List<dynamic>> filas = [];

      // ENCABEZADO
      filas.add([
        '================================================================================',
      ]);
      filas.add([isSpanish ? 'INFORME DE ESTADÍSTICAS' : 'STATISTICS REPORT']);
      filas.add([
        '================================================================================',
      ]);
      filas.add([]);

      // INFORMACIÓN GENERAL
      filas.add([isSpanish ? 'INFORMACIÓN GENERAL' : 'GENERAL INFORMATION']);
      filas.add([
        '--------------------------------------------------------------------------------',
      ]);
      filas.add([
        '${isSpanish ? 'Paciente' : 'Patient'}:',
        '${widget.paciente.Nombre} ${widget.paciente.Apellido1} ${widget.paciente.Apellido2}',
      ]);
      filas.add([
        '${isSpanish ? 'Período' : 'Period'}:',
        '${_fechaInicio != null ? DateFormat('dd/MM/yyyy HH:mm').format(_fechaInicio!) : 'TODOS'} - ${_fechaFin != null ? DateFormat('dd/MM/yyyy HH:mm').format(_fechaFin!) : 'TODOS'}',
      ]);
      filas.add([
        '${isSpanish ? 'Fecha de exportación' : 'Export date'}:',
        '${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
      ]);
      filas.add([]);

      // DATOS DE BATERÍA
      if (baterryList.isNotEmpty) {
        filas.add([
          '================================================================================',
        ]);
        filas.add([isSpanish ? 'DATOS DE BATERÍA' : 'BATTERY DATA']);
        filas.add([
          '================================================================================',
        ]);
        filas.add([
          isSpanish ? 'Fecha' : 'Date',
          isSpanish ? 'Nivel (%)' : 'Level (%)',
        ]);
        filas.add([
          '--------------------------------------------------------------------------------',
        ]);
        for (var bateria in baterryList) {
          filas.add([
            DateFormat('dd/MM/yyyy HH:mm').format(bateria.timestamp),
            bateria.Baterry.toStringAsFixed(1),
          ]);
        }
        filas.add([]);
      }

      // DATOS DE PASOS
      if (stepList.isNotEmpty) {
        filas.add([
          '================================================================================',
        ]);
        filas.add([isSpanish ? 'HISTORIAL DE PASOS' : 'STEP HISTORY']);
        filas.add([
          '================================================================================',
        ]);
        filas.add([
          isSpanish ? 'Fecha' : 'Date',
          isSpanish ? 'Pasos' : 'Steps',
        ]);
        filas.add([
          '--------------------------------------------------------------------------------',
        ]);

        Map<String, List<StepData>> pasosPorDia = {};
        for (var paso in stepList) {
          String dia = DateFormat('dd/MM/yyyy').format(paso.timestamp);
          if (!pasosPorDia.containsKey(dia)) {
            pasosPorDia[dia] = [];
          }
          pasosPorDia[dia]!.add(paso);
        }

        var diasOrdenados = pasosPorDia.keys.toList()..sort();

        for (var dia in diasOrdenados) {
          filas.add(['--- $dia ---']);
          for (var paso in pasosPorDia[dia]!) {
            filas.add([
              DateFormat('HH:mm').format(paso.timestamp),
              paso.Step.toString(),
            ]);
          }
        }
        filas.add([]);
      }

      // HISTORIAL DE ALARMAS
      if (AlarmsListHistory.isNotEmpty) {
        filas.add([
          '================================================================================',
        ]);
        filas.add([isSpanish ? 'HISTORIAL DE ALARMAS' : 'ALARM HISTORY']);
        filas.add([
          '================================================================================',
        ]);
        filas.add([
          isSpanish ? 'Fecha' : 'Date',
          isSpanish ? 'Alarma' : 'Alarm',
          isSpanish ? 'Estado' : 'Status',
        ]);
        filas.add([
          '--------------------------------------------------------------------------------',
        ]);

        Map<String, List<AlarmaData2>> alarmasPorDia = {};
        for (var alarma in AlarmsListHistory) {
          String dia = DateFormat('dd/MM/yyyy').format(alarma.timestamp);
          if (!alarmasPorDia.containsKey(dia)) {
            alarmasPorDia[dia] = [];
          }
          alarmasPorDia[dia]!.add(alarma);
        }

        var diasOrdenados = alarmasPorDia.keys.toList()..sort();

        for (var dia in diasOrdenados) {
          filas.add(['--- $dia ---']);
          for (var alarma in alarmasPorDia[dia]!) {
            String nombreAlarma = isSpanish
                ? alarma.Alarma
                : (alarmTranslations[alarma.Alarma] ?? alarma.Alarma);

            String estado = alarma.Valor == 1
                ? (isSpanish ? 'ACTIVA' : 'ACTIVE')
                : (isSpanish ? 'INACTIVA' : 'INACTIVE');

            filas.add([
              DateFormat('HH:mm').format(alarma.timestamp),
              nombreAlarma,
              estado,
            ]);
          }
        }
        filas.add([]);
      }

      // TRAYECTORIA INDOOR
      if (dataRoom.isNotEmpty) {
        filas.add([
          '================================================================================',
        ]);
        filas.add([isSpanish ? 'TRAYECTORIA INDOOR' : 'INDOOR TRAJECTORY']);
        filas.add([
          '================================================================================',
        ]);
        filas.add([
          isSpanish ? 'Fecha' : 'Date',
          isSpanish ? 'Habitación' : 'Room',
        ]);
        filas.add([
          '--------------------------------------------------------------------------------',
        ]);

        Map<String, List<RoomData>> habitacionesPorDia = {};
        for (var room in dataRoom) {
          String dia = DateFormat('dd/MM/yyyy').format(room.timestamp);
          if (!habitacionesPorDia.containsKey(dia)) {
            habitacionesPorDia[dia] = [];
          }
          habitacionesPorDia[dia]!.add(room);
        }

        var diasOrdenados = habitacionesPorDia.keys.toList()..sort();

        for (var dia in diasOrdenados) {
          filas.add(['--- $dia ---']);
          for (var room in habitacionesPorDia[dia]!) {
            filas.add([DateFormat('HH:mm').format(room.timestamp), room.room]);
          }
        }
        filas.add([]);
      }

      // TRAYECTORIA OUTDOOR
      if (routeCoordinates.isNotEmpty) {
        filas.add([
          '================================================================================',
        ]);
        filas.add([isSpanish ? 'TRAYECTORIA OUTDOOR' : 'OUTDOOR TRAJECTORY']);
        filas.add([
          '================================================================================',
        ]);
        filas.add([
          isSpanish ? 'Fecha' : 'Date',
          isSpanish ? 'Latitud' : 'Latitude',
          isSpanish ? 'Longitud' : 'Longitude',
        ]);
        filas.add([
          '--------------------------------------------------------------------------------',
        ]);

        Map<String, List<Coordenas>> gpsPorDia = {};
        for (var coord in routeCoordinates) {
          String dia = DateFormat('dd/MM/yyyy').format(coord.timestamp);
          if (!gpsPorDia.containsKey(dia)) {
            gpsPorDia[dia] = [];
          }
          gpsPorDia[dia]!.add(coord);
        }

        var diasOrdenados = gpsPorDia.keys.toList()..sort();

        for (var dia in diasOrdenados) {
          filas.add(['--- $dia ---']);
          for (var coord in gpsPorDia[dia]!) {
            filas.add([
              DateFormat('HH:mm').format(coord.timestamp),
              coord.coordenadas.latitude.toStringAsFixed(6),
              coord.coordenadas.longitude.toStringAsFixed(6),
            ]);
          }
        }
        filas.add([]);
      }

      // PORCENTAJES POR HABITACIÓN
      if (percentageMap.isNotEmpty) {
        filas.add([
          '================================================================================',
        ]);
        filas.add([
          isSpanish
              ? 'ANÁLISIS DE PERMANENCIA POR HABITACIÓN'
              : 'ROOM OCCUPANCY ANALYSIS',
        ]);
        filas.add([
          '================================================================================',
        ]);
        filas.add([
          isSpanish ? 'Habitación' : 'Room',
          isSpanish ? 'Porcentaje (%)' : 'Percentage (%)',
        ]);
        filas.add([
          '--------------------------------------------------------------------------------',
        ]);

        var sortedEntries = percentageMap.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        for (var entry in sortedEntries) {
          String nombreHabitacion = '';
          if (entry.key == 0) {
            nombreHabitacion = isSpanish
                ? 'Zona no sensorizada'
                : 'Non-sensorized zone';
          } else {
            var habitacion = widget.habitaciones.firstWhere(
              (hab) => hab.CodHabitacionSensor == 'HS${entry.key}',
              orElse: () => Habitaciones(
                0,
                '',
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
            if (habitacion.CodHabitacion != 0) {
              String tipoHabitacion = isSpanish
                  ? habitacion.TipoHabitacion
                  : (roomTypeTranslations[habitacion.TipoHabitacion] ??
                        habitacion.TipoHabitacion);
              nombreHabitacion = '$tipoHabitacion ${habitacion.Observaciones}'
                  .trim();
            } else {
              nombreHabitacion = isSpanish
                  ? 'Habitación $entry.key'
                  : 'Room $entry.key';
            }
          }
          filas.add([nombreHabitacion, entry.value.toStringAsFixed(2)]);
        }
        filas.add([]);
      }

      // PIE DE PÁGINA
      filas.add([
        '================================================================================',
      ]);
      filas.add([isSpanish ? 'FIN DEL INFORME' : 'END OF REPORT']);
      filas.add([
        '================================================================================',
      ]);

      // Convertir a CSV
      String csv = const ListToCsvConverter().convert(filas);

      // Guardar archivo
      final bytes = utf8.encode(csv);

      String? downloadsPath;

      if (Platform.isWindows) {
        downloadsPath =
            'C:\\Users\\${Platform.environment['USERNAME']}\\Downloads';
      } else if (Platform.isAndroid) {
        downloadsPath = '/storage/emulated/0/Download';
      } else {
        final directory = await getTemporaryDirectory();
        downloadsPath = directory.path;
      }

      if (downloadsPath != null) {
  final fileName =
      'estadisticas_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
  final filePath = Platform.isWindows
      ? '$downloadsPath\\$fileName'
      : '$downloadsPath/$fileName';
  final file = File(filePath);

  await file.writeAsBytes(bytes);

  // ✅ AQUÍ ESTÁ LA VENTANITA (SNACKBAR)
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSpanish
              ? '✅ Archivo guardado en Descargas: $fileName'
              : '✅ File saved in Downloads: $fileName',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 5),
      ),
    );
  }
} else {
        throw Exception('No se pudo acceder a la carpeta de Descargas');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isSpanish
                  ? '❌ Error al exportar datos: $e'
                  : '❌ Error exporting data: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _cargandoDatos = false);
      }
    }
  }

  List<int> Codigo_pintar = [];

  Future<String> getData1() async {
    var Dbdata = await DBPostgres().DBGetDatosPacienteCuidador2(
      widget.paciente.CodPaciente,
      'null',
    );
    setState(() {
      for (var p in Dbdata[1]) {
        HabitacionesList.add(
          Habitaciones(
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
          ),
        );
      }
      for (var i = 0; i < HabitacionesList.length; i++) {
        if (HabitacionesList[i].CodHabitacionSensor != null) {
          Codigo_pintar.add(i + 1);
        }
      }
    });
    return 'Successfully Fetched data';
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

  Future<void> getData() async {
    setState(() => _cargandoDatos = true);

    try {
      var DbAlarma = await DBPostgres().DBGetAlarmaPaciente(
        widget.paciente.CodPaciente,
        'null',
      );

      if (DbAlarma != null && DbAlarma.isNotEmpty && DbAlarma[0] != null) {
        for (var p in DbAlarma[0]) {
          AlarmasPacienteList.add(
            AlarmasPaciente(p[0], p[1], p[2], p[3], p[4], p[5]),
          );
        }
      }

      var DbdataX = await DBPostgres().DBGetDatosPacienteCuidador2(
        widget.paciente.CodPaciente,
        'null',
      );

      if (DbdataX != null && DbdataX.length > 2 && DbdataX[2] != null) {
        setState(() {
          for (var p in DbdataX[2]) {
            SensoresPuerta.add(
              Sensores(
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
              ),
            );
          }
        });
      }

      int extractNumber(String input) {
        final RegExp regExp = RegExp(r'\d+');
        final Match? match = regExp.firstMatch(input);
        return match != null ? int.parse(match.group(0)!) : 0;
      }

      if (_startDate == null || _endDate == null) {
        setState(() => _cargandoDatos = false);
        return;
      }

      var startFormatted = DateFormat(
        "yyyy-MM-dd'T'HH:mm:ss'Z'",
      ).format(_startDate!.toUtc());
      var endFormatted = DateFormat(
        "yyyy-MM-dd'T'HH:mm:ss'Z'",
      ).format(_endDate!.toUtc());

      var startFormattedStatDiar = DateFormat(
        "yyyy-MM-dd'T'HH:mm:ss'Z'",
      ).format(_startDateStatDiar!.toUtc());
      var endFormattedStatDiar = DateFormat(
        "yyyy-MM-dd'T'HH:mm:ss'Z'",
      ).format(_endDateStatDiar!.toUtc());

      var diferenciaDias = _endDate!.difference(_startDate!).inDays;
      if (diferenciaDias > 7) {
        _endDate = _startDate!.add(const Duration(days: 7));
        _endDateStatDiar = _endDate;

        endFormatted = DateFormat(
          "yyyy-MM-dd'T'HH:mm:ss'Z'",
        ).format(_endDate!.toUtc());
        endFormattedStatDiar = DateFormat(
          "yyyy-MM-dd'T'HH:mm:ss'Z'",
        ).format(_endDateStatDiar!.toUtc());

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isSpanish
                      ? '⚠️ Rango limitado a 7 días máximo'
                      : '⚠️ Range limited to 7 days maximum',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        });
      }

      var difference = _endDate!.difference(_startDate!).inDays;
      var differenceInHours = _endDate!.difference(_startDate!).inHours;
      String every;

      if (difference > 31) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isSpanish
                      ? '⚠️ Rango muy grande (>31 días). Se mostrarán datos resumidos.'
                      : '⚠️ Very large range (>31 days). Summarized data will be shown.',
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        });
      }

      if (differenceInHours <= 1) {
        every = "10s";
      } else if (differenceInHours <= 6) {
        every = "30s";
      } else if (differenceInHours <= 24) {
        every = "1m";
      } else if (difference <= 3) {
        every = "5m";
      } else if (difference <= 7) {
        every = "15m";
      } else if (difference <= 15) {
        every = "30m";
      } else if (difference <= 31) {
        every = "1h";
      } else {
        every = "3h";
      }

      int maxBaterryPoints = 1000;
      int maxRoomPoints = 2000;
      int maxStepPoints = 2000;
      int maxGpsPoints = 1000;

      if (difference > 31) {
        maxBaterryPoints = 500;
        maxRoomPoints = 1000;
        maxStepPoints = 1000;
        maxGpsPoints = 500;
      }

      // GetHumTempBat
      try {
        var nivel = await InfluxDBService().GetHumTempBat(
          widget.wearable.CodPacienteWearable,
          widget.wearable.IdWearable,
          startFormatted,
          endFormatted,
          every,
        );

        if (nivel != null && nivel.length > 3 && nivel[3] != null) {
          setState(() {
            baterryList = nivel[3] ?? [];

            if (baterryList.length > maxBaterryPoints) {
              baterryList = _diezmarLista(baterryList, maxBaterryPoints);
            }

            if (baterryList.isNotEmpty) {
              double maxBaterry = baterryList
                  .map((data) => data.Baterry)
                  .reduce((a, b) => a > b ? a : b);
              maxBaterry = 100 - maxBaterry;
              baterryList = baterryList.map((data) {
                return BaterryData(data.Baterry + maxBaterry, data.timestamp);
              }).toList();
            }
          });
        }
      } catch (e) {}

      // GetAlarm
      try {
        var alarms = await InfluxDBService().GetAlarm(
          widget.wearable.CodPacienteWearable,
          widget.wearable.IdWearable,
          startFormatted,
          endFormatted,
          every,
        );

        if (alarms != null) {
          setState(() {
            AlarmsList = alarms;
            dataAlarm = AlarmsList.map((alarma) {
              int yValue = 0;
              if (alarma.Caida == 1) {
                yValue = 1;
              } else if (alarma.Boton == 1) {
                yValue = 2;
              } else if (alarma.Caida == 1 && alarma.Boton == 1) {
                yValue = 3;
              }
              return AlarmData(yValue.toDouble(), alarma.timestampCaida);
            }).toList();
          });
        }
      } catch (e) {}

      // GetAlarmStats
      try {
        var alarms = await InfluxDBService().GetAlarmStats(
          widget.wearable.CodPacienteWearable,
          widget.wearable.IdWearable,
          AlarmasPacienteList,
          startFormatted,
          endFormatted,
          '30s',
        );

        if (alarms != null) {
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
        }
      } catch (e) {}

      // GetRoom 
      try {
        var room = await InfluxDBService().GetRoom(
          widget.wearable.CodPacienteWearable,
          widget.wearable.IdWearable,
          startFormatted,
          endFormatted,
          every,
        );

        if (room != null) {
          setState(() {
            roomList = room;

            if (roomList.length > maxRoomPoints) {
              roomList = _diezmarLista(roomList, maxRoomPoints);
            }

            if (roomList.isNotEmpty) {
              firstTimestamp = roomList.first.timestamp.millisecondsSinceEpoch
                  .toDouble();
              lastTimestamp = roomList.last.timestamp.millisecondsSinceEpoch
                  .toDouble();

              Map<int, int> countMap = {};
              for (var roomData in roomList) {
                countMap[roomData.CodHabitacionSensor] =
                    (countMap[roomData.CodHabitacionSensor] ?? 0) + 1;
              }

              int totalCount = roomList.length;
              percentageMap.clear();
              if (totalCount > 0) {
                countMap.forEach((key, value) {
                  double percentage = value / totalCount * 100;
                  String formattedPercentage = percentage.toStringAsFixed(2);
                  percentageMap[key] = double.parse(formattedPercentage);
                });
              }

              int counter = 0;
              try {
                var habitacionesConSensor = widget.habitaciones
                    .where(
                      (h) =>
                          h.CodHabitacionSensor != null &&
                          h.CodHabitacionSensor!.startsWith("HS"),
                    )
                    .toList();

                if (habitacionesConSensor.isNotEmpty) {
                  minValue = habitacionesConSensor
                      .map(
                        (h) => int.parse(h.CodHabitacionSensor!.substring(2)),
                      )
                      .reduce((a, b) => a < b ? a : b);
                } else {
                  minValue = 1;
                }

                HabitacionesGrafica = widget.habitaciones.map((habitacion) {
                  if (habitacion.CodHabitacionSensor == null ||
                      !habitacion.CodHabitacionSensor!.startsWith("HS")) {
                    return habitacion;
                  } else {
                    counter++;
                    String newCodHabitacionSensor = "HS$counter";
                    return Habitaciones(
                      habitacion.CodHabitacion,
                      habitacion.Observaciones,
                      habitacion.NumPlanta,
                      habitacion.CodTipoHabitacion,
                      habitacion.TipoHabitacion,
                      habitacion.FechaAltaHabitacion,
                      habitacion.FechaBajaHabitacion,
                      newCodHabitacionSensor,
                      habitacion.FechaAltaHabitacionSensor,
                      habitacion.FechaBajaHabitacionSensor,
                      habitacion.CodSensor,
                    );
                  }
                }).toList();
              } catch (e) {
                HabitacionesGrafica = widget.habitaciones;
              }

              try {
                roomList = roomList.map((roomData) {
                  final habitacion = widget.habitaciones.firstWhere(
                    (habitacion) =>
                        habitacion.CodHabitacionSensor ==
                        'HS${roomData.CodHabitacionSensor}',
                    orElse: () => Habitaciones(
                      0,
                      'Non-Sensorised Zone',
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

                  for (var i = 0; i < HabitacionesList.length; i++) {
                    if (HabitacionesList[i].CodHabitacionSensor ==
                        habitacion.CodHabitacionSensor) {
                      roomData.CodHabitacionSensor = extractNumber(
                        HabitacionesGrafica[i].CodHabitacionSensor ?? '0',
                      );
                    }
                  }

                  String tipoHabitacion = isSpanish
                      ? habitacion.TipoHabitacion
                      : (roomTypeTranslations[habitacion.TipoHabitacion] ??
                            habitacion.TipoHabitacion);

                  return RoomData(
                    '$tipoHabitacion ${habitacion.Observaciones}',
                    roomData.timestamp,
                    roomData.CodHabitacionSensor,
                  );
                }).toList();

                dataRoom = roomList.map((dataRoom) {
                  if (dataRoom.CodHabitacionSensor == 0) {
                    return RoomData(
                      dataRoom.room,
                      dataRoom.timestamp,
                      dataRoom.CodHabitacionSensor,
                    );
                  } else {
                    var roomsWithSensor = roomList
                        .where((r) => r.CodHabitacionSensor != 0)
                        .toList();
                    if (roomsWithSensor.isNotEmpty) {
                      minValue = roomsWithSensor
                          .map((r) => r.CodHabitacionSensor)
                          .reduce((a, b) => a < b ? a : b);
                    }
                    return RoomData(
                      dataRoom.room,
                      dataRoom.timestamp,
                      dataRoom.CodHabitacionSensor,
                    );
                  }
                }).toList();
              } catch (e) {}
            }
          });
        }
      } catch (e) {}

      // GetDS
      try {
        var doorSensorData = await InfluxDBService().GetDS(
          SensoresPuerta,
          startFormatted,
          endFormatted,
          '1s',
        );

        if (doorSensorData != null) {
          setState(() {
            DSListStat.clear();
            DSListHistory.clear();
            DSHistory.clear();
            DSListStat = doorSensorData;

            for (var sensor in SensoresPuerta) {
              var sensorDataList = doorSensorData.where(
                (sensorData) =>
                    sensorData.CodHabitacionSensor ==
                    sensor.CodHabitacionSensor,
              );

              for (var sensorData in sensorDataList) {
                DSListHistory.add(
                  DoorSensorData2(
                    sensorData.timestamp,
                    sensorData.Valor,
                    sensor.Descripcion,
                  ),
                );
              }
            }
          });
        }
      } catch (e) {}

      // GetRoom 
      try {
        var room = await InfluxDBService().GetRoom(
          widget.wearable.CodPacienteWearable,
          widget.wearable.IdWearable,
          startFormattedStatDiar,
          endFormattedStatDiar,
          "30s",
        );

        if (room != null) {
          setState(() {
            roomListStatDiar = room;

            if (roomListStatDiar.length > maxRoomPoints) {
              roomListStatDiar = _diezmarLista(roomListStatDiar, maxRoomPoints);
            }

            if (roomListStatDiar.isNotEmpty) {
              firstTimestamp = roomListStatDiar
                  .first
                  .timestamp
                  .millisecondsSinceEpoch
                  .toDouble();
              lastTimestamp = roomListStatDiar
                  .last
                  .timestamp
                  .millisecondsSinceEpoch
                  .toDouble();

              roomTimeByDay.clear();
              percentageRooms.clear();

              roomListStatDiar.sort(
                (a, b) => a.timestamp.compareTo(b.timestamp),
              );

              Map<String, List<RoomData>> dailyRoomData = {};

              for (var roomData in roomListStatDiar) {
                String formattedDate = DateFormat(
                  'yyyy-MM-dd',
                ).format(roomData.timestamp);
                if (dailyRoomData.containsKey(formattedDate)) {
                  dailyRoomData[formattedDate]!.add(roomData);
                } else {
                  dailyRoomData[formattedDate] = [roomData];
                }
              }

              dailyRoomData.forEach((date, dataList) {
                Map<String, int> roomDuration = {};
                int totalDuration = 0;

                for (var roomData in dataList) {
                  roomDuration[roomData.room] =
                      (roomDuration[roomData.room] ?? 0) + 1;
                  totalDuration += 1;
                }

                for (var habitacion in widget.habitaciones) {
                  String? room = habitacion.CodHabitacionSensor;
                  if (!roomDuration.containsKey(room)) {
                    String tipoHabitacion = isSpanish
                        ? habitacion.TipoHabitacion
                        : (roomTypeTranslations[habitacion.TipoHabitacion] ??
                              habitacion.TipoHabitacion);
                    percentageRooms.add(
                      PercentageRoom(
                        DateTime.parse(date),
                        '$tipoHabitacion ${habitacion.Observaciones}',
                        0.0,
                      ),
                    );
                  }
                }

                if (totalDuration > 0) {
                  roomDuration.forEach((room, duration) {
                    double percentage = (duration / totalDuration) * 100;
                    String formattedPercentage = percentage.toStringAsFixed(2);
                    var matchingHabitacion = widget.habitaciones.firstWhere(
                      (hab) => hab.CodHabitacionSensor == room,
                      orElse: () => Habitaciones(
                        0,
                        'Non-Sensorised Zone',
                        null,
                        0,
                        '',
                        DateTime.now(),
                        null,
                        "HS0",
                        null,
                        null,
                        null,
                      ),
                    );

                    String tipoHabitacion = isSpanish
                        ? matchingHabitacion.TipoHabitacion
                        : (roomTypeTranslations[matchingHabitacion.TipoHabitacion] ??
                              matchingHabitacion.TipoHabitacion);

                    percentageRooms.add(
                      PercentageRoom(
                        DateTime.parse(date),
                        '$tipoHabitacion ${matchingHabitacion.Observaciones}',
                        double.parse(formattedPercentage),
                      ),
                    );
                  });
                }
              });
            }
          });
        }
      } catch (e) {}

      // GetSteps
      try {
        var Step = await InfluxDBService().GetSteps(
          widget.wearable.CodPacienteWearable,
          widget.wearable.IdWearable,
          startFormatted,
          endFormatted,
          every,
        );

        if (Step != null) {
          setState(() {
            stepList = Step;

            if (stepList.length > maxStepPoints) {
              stepList = _diezmarLista(stepList, maxStepPoints);
            }

            if (stepList.isNotEmpty) {
              dataStep = stepList.map((dataStep) {
                return FlSpot(
                  (dataStep.timestamp.millisecondsSinceEpoch).toDouble(),
                  (dataStep.Step.floor().toDouble()),
                );
              }).toList();

              if (dataStep.isNotEmpty) {
                minYValue = dataStep
                    .reduce((min, spot) => min.y < spot.y ? min : spot)
                    .y;
                maxYValue = dataStep
                    .reduce((max, spot) => max.y > spot.y ? max : spot)
                    .y;

                roundedMaxY = maxYValue.round();
                double separationPercentage = 1.1;
                newMaxY = roundedMaxY * separationPercentage + 0.5;
              }
            }
          });
        }
      } catch (e) {}

      // GetGPS
      try {
        var GPS = await InfluxDBService().GetGPS(
          widget.wearable.CodPacienteWearable,
          widget.wearable.IdWearable,
          startFormatted,
          endFormatted,
          every,
        );

        if (GPS != null && GPS.length > 1) {
          setState(() {
            LatList = GPS[0] ?? [];
            LongList = GPS[1] ?? [];

            if (LatList.length > maxGpsPoints) {
              LatList = _diezmarLista(LatList, maxGpsPoints);
              LongList = _diezmarLista(LongList, maxGpsPoints);
            }

            if (LongList.isNotEmpty &&
                LatList.isNotEmpty &&
                LatList.length > 3 &&
                LongList.length > 3 &&
                LongList.length == LatList.length) {
              if (widget.casas.isNotEmpty) {
                coordinates = LatLng(
                  widget.casas[0].Latitud,
                  widget.casas[0].Longitud,
                );
              }

              routeCoordinates.clear();
              routeCoordinatesSinFiltrar.clear();
              polylines.clear();
              markers.clear();

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
                if (ok &&
                    coordinates.latitude != 0.0000 &&
                    coordinates.longitude != 0.0000) {
                  routeCoordinatesSinFiltrar.add(Coordenas(coordinates, time));
                }
              }

              for (int i = 0; i < routeCoordinates.length - 1; i++) {
                final point1 = routeCoordinates[i].coordenadas;
                final point2 = routeCoordinates[i + 1].coordenadas;

                final lat1 = point1.latitude * math.pi / 180;
                final lon1 = point1.longitude * math.pi / 180;
                final lat2 = point2.latitude * math.pi / 180;
                final lon2 = point2.longitude * math.pi / 180;

                final dLon = lon2 - lon1;

                final y = math.sin(dLon) * math.cos(lat2);
                final x =
                    math.cos(lat1) * math.sin(lat2) -
                    math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
                var angle = math.atan2(y, x) - 80;

                angle = (angle + 2 * math.pi) % (2 * math.pi);
                final mid = midPoint(point1, point2);

                markers.add(
                  Marker(
                    point: routeCoordinates[i].coordenadas,
                    width: 30,
                    height: 30,
                    child: GestureDetector(
                      onTap: () {
                        final punto = routeCoordinates[i];

                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 40,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  isSpanish
                                      ? 'Información de ubicación'
                                      : 'Location information',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            isSpanish
                                                ? 'Latitud:'
                                                : 'Latitude:',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            punto.coordenadas.latitude
                                                .toStringAsFixed(6),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            isSpanish
                                                ? 'Longitud:'
                                                : 'Longitude:',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            punto.coordenadas.longitude
                                                .toStringAsFixed(6),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            isSpanish
                                                ? 'Fecha y hora:'
                                                : 'Date and time:',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            DateFormat(
                                              'dd/MM/yyyy HH:mm:ss',
                                            ).format(punto.timestamp),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorPrimario,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(
                                      double.infinity,
                                      45,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(isSpanish ? 'Cerrar' : 'Close'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                );
              }

              List<List<LatLng>> dayPoints = [];

              for (int i = 0; i < routeCoordinates.length; i++) {
                final currentPoint = routeCoordinates[i];

                if (i == 0 ||
                    !sameDay(
                      currentPoint.timestamp,
                      routeCoordinates[i - 1].timestamp,
                    )) {
                  dayPoints.add([]);
                }

                dayPoints.last.add(currentPoint.coordenadas);
              }

              for (int i = 0; i < dayPoints.length; i++) {
                final dayPointsList = dayPoints[i];

                final polyline = Polyline(
                  points: dayPointsList,
                  strokeWidth: 4.0,
                  color: colorsSinRojo[i % colorsSinRojo.length],
                );

                polylines.add(polyline);
              }

              data = routeCoordinatesSinFiltrar.map((coord) {
                return WeightedLatLng(coord.coordenadas, 3.0);
              }).toList();
            }
          });
        }
      } catch (e) {}
    } catch (e) {
      print('Error en getData: $e');
    } finally {
      setState(() => _cargandoDatos = false);
    }
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

  String getTipoHabitacionObservaciones(
    int flSpotY,
    int minValue,
  ) {
    String codHabitacionSensor = 'HS${flSpotY + minValue - 1}';
    for (Habitaciones habitacion in widget.habitaciones) {
      if (habitacion.CodHabitacionSensor == codHabitacionSensor) {
        String tipoHabitacion = isSpanish
            ? habitacion.TipoHabitacion
            : (roomTypeTranslations[habitacion.TipoHabitacion] ??
                  habitacion.TipoHabitacion);
        return '$tipoHabitacion ${habitacion.Observaciones}';
      }
    }
    return isSpanish ? 'Zona no sensorizada' : 'Non-sensorized zone';
  }

  String getTipoAlarma(int flSpotY) {
    if (flSpotY == 0) {
      return isSpanish ? 'Alarma desactivada' : 'Alarm deactivated';
    } else if (flSpotY == 1) {
      return isSpanish ? 'Alarma caída' : 'Fall alarm';
    } else if (flSpotY == 2) {
      return isSpanish ? 'Botón pánico' : 'Panic button';
    } else if (flSpotY == 3) {
      return isSpanish
          ? 'Alarma caída y Botón pánico'
          : 'Fall alarm and Panic button';
    } else {
      return '';
    }
  }

  String _getLatRange(List<WeightedLatLng> dataList) {
    if (dataList.isEmpty) return isSpanish ? 'N/A' : 'N/A';
    final lats = dataList.map((d) => d.latLng.latitude).toList();
    final minLat = lats.reduce((a, b) => a < b ? a : b);
    final maxLat = lats.reduce((a, b) => a > b ? a : b);
    return isSpanish
        ? '${minLat.toStringAsFixed(4)} a ${maxLat.toStringAsFixed(4)}'
        : '${minLat.toStringAsFixed(4)} to ${maxLat.toStringAsFixed(4)}';
  }

  String _getLngRange(List<WeightedLatLng> dataList) {
    if (dataList.isEmpty) return isSpanish ? 'N/A' : 'N/A';
    final lngs = dataList.map((d) => d.latLng.longitude).toList();
    final minLng = lngs.reduce((a, b) => a < b ? a : b);
    final maxLng = lngs.reduce((a, b) => a > b ? a : b);
    return isSpanish
        ? '${minLng.toStringAsFixed(4)} a ${maxLng.toStringAsFixed(4)}'
        : '${minLng.toStringAsFixed(4)} to ${maxLng.toStringAsFixed(4)}';
  }

  String translateAlarm(String alarm) {
    if (isSpanish) {
      return alarm;
    } else {
      return alarmTranslations[alarm] ?? alarm;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _cargandoDatos
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: Color.fromARGB(255, 25, 144, 234),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isSpanish ? 'Cargando datos...' : 'Loading data...',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.grey.shade50],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
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
                            Row(
                              children: [
                              ],
                            ),
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

                      // Mensaje cuando no hay datos
                      if (baterryList.isEmpty &&
                          dataRoom.isEmpty &&
                          stepList.isEmpty &&
                          AlarmsListHistory.isEmpty &&
                          roomList.isEmpty &&
                          routeCoordinates.isEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(40),
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
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 60,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isSpanish
                                    ? 'No hay datos disponibles'
                                    : 'No data available',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isSpanish
                                    ? 'Para el período seleccionado'
                                    : 'For the selected period',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 5),
                              if (_fechaInicio != null && _fechaFin != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorPrimario.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${DateFormat('dd/MM/yyyy HH:mm').format(_fechaInicio!)} - ${DateFormat('dd/MM/yyyy HH:mm').format(_fechaFin!)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorPrimario,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    getData();
                                  });
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
                      ],

                      // TRAYECTORIA INDOOR
                      if (dataRoom.isNotEmpty &&
                          HabitacionesGrafica.isNotEmpty) ...[
                        const SizedBox(height: 20),
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
                                  Icon(
                                    Icons.meeting_room,
                                    color: colorPrimario,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    isSpanish
                                        ? 'Trayectoria Indoor'
                                        : 'Indoor Trajectory',
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
                                height:
                                    60 *
                                    (HabitacionesGrafica.isNotEmpty
                                        ? HabitacionesGrafica.length.toDouble()
                                        : 1),
                                child: SfCartesianChart(
                                  plotAreaBorderWidth: 0,
                                  zoomPanBehavior: ZoomPanBehavior(
                                    enablePinching: true,
                                    zoomMode: ZoomMode.xy,
                                    enablePanning: true,
                                    enableMouseWheelZooming: true,
                                  ),
                                  primaryXAxis: DateTimeAxis(
                                    dateFormat: DateFormat('HH:mm d/M/y'),
                                    majorGridLines: const MajorGridLines(
                                      width: 0,
                                    ),
                                    enableAutoIntervalOnZooming: false,
                                  ),
                                  primaryYAxis: NumericAxis(
                                    axisLine: const AxisLine(width: 0),
                                    enableAutoIntervalOnZooming: false,
                                    labelFormat: '{value}',
                                    interval: 1,
                                    maximum: widget.habitaciones.length
                                        .toDouble(),
                                    maximumLabels:
                                        widget.habitaciones.length + 1,
                                    axisLabelFormatter: (axisLabelRenderArgs) {
                                      int valorRoom = axisLabelRenderArgs.value
                                          .toInt();
                                      final String labelValue = 'HS$valorRoom';
                                      if (labelValue == 'HS0') {
                                        return ChartAxisLabel(
                                          isSpanish
                                              ? 'Zona no sensorizada'
                                              : 'Non-Sensorised Zone',
                                          axisLabelRenderArgs.textStyle,
                                        );
                                      } else {
                                        final habitacion =
                                            HabitacionesGrafica.firstWhere(
                                              (habitacion) =>
                                                  habitacion
                                                      .CodHabitacionSensor ==
                                                  labelValue,
                                              orElse: () => Habitaciones(
                                                0,
                                                '',
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

                                        String tipoHabitacion = isSpanish
                                            ? habitacion.TipoHabitacion
                                            : (roomTypeTranslations[habitacion
                                                      .TipoHabitacion] ??
                                                  habitacion.TipoHabitacion);

                                        return ChartAxisLabel(
                                          '$tipoHabitacion: ${habitacion.Observaciones}',
                                          axisLabelRenderArgs.textStyle,
                                        );
                                      }
                                    },
                                  ),
                                  series: _getRoomLineSeries(),
                                  tooltipBehavior: TooltipBehavior(
                                    enable: true,
                                    builder:
                                        (
                                          data,
                                          point,
                                          series,
                                          pointIndex,
                                          seriesIndex,
                                        ) {
                                          if (pointIndex < 0 ||
                                              pointIndex >= dataRoom.length) {
                                            return Container();
                                          }
                                          final RoomData roomData =
                                              dataRoom[pointIndex];
                                          final formattedDate = DateFormat(
                                            'HH:mm dd/MM/yyyy',
                                          ).format(roomData.timestamp);

                                          List<String> roomWords = roomData.room
                                              .split(' ');

                                          if (roomWords.isNotEmpty &&
                                              !isSpanish) {
                                            roomWords[0] =
                                                roomTypeTranslations[roomWords[0]] ??
                                                roomWords[0];
                                          }

                                          final translatedRoom = roomWords.join(
                                            ' ',
                                          );

                                          return Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: colorPrimario,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Text(
                                                  formattedDate,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  translatedRoom,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                  ),
                                  trackballBehavior: _trackballBehavior,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // TRAYECTORIA OUTDOOR
                      if (routeCoordinates.isNotEmpty) ...[
                        const SizedBox(height: 20),
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
                                  Icon(
                                    Icons.map,
                                    color: colorPrimario,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    isSpanish
                                        ? 'Trayectoria Outdoor'
                                        : 'Outdoor Trajectory',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blueGrey[800],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                height: 400,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: FlutterMap(
                                    mapController: mapController,
                                    options: MapOptions(
                                      initialCenter: routeCoordinates.isNotEmpty
                                          ? routeCoordinates[0].coordenadas
                                          : (widget.casas.isNotEmpty
                                                ? LatLng(
                                                    widget.casas[0].Latitud,
                                                    widget.casas[0].Longitud,
                                                  )
                                                : const LatLng(
                                                    40.416775,
                                                    -3.703790,
                                                  )),
                                      initialZoom: 15,
                                      maxZoom: 18,
                                      minZoom: 2,
                                      interactionOptions:
                                          const InteractionOptions(
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
                                      if (_getPolylinesPorDia().isNotEmpty)
                                        PolylineLayer(
                                          polylines: _getPolylinesPorDia(),
                                        ),
                                      if (markers.isNotEmpty)
                                        MarkerLayer(markers: markers),
                                      MarkerLayer(
                                        markers: generarMarkers(widget.casas),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // MAPA DE CALOR
                      if (data.isNotEmpty) ...[
                        const SizedBox(height: 20),
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
                                  Icon(
                                    Icons.heat_pump,
                                    color: colorPrimario,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    isSpanish ? 'Mapa de Calor' : 'Heat Map',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blueGrey[800],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                height: 400,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: FlutterMap(
                                    key: ValueKey('heatmap_${data.length}'),
                                    options: MapOptions(
                                      initialCenter: data.isNotEmpty
                                          ? data.first.latLng
                                          : (widget.casas.isNotEmpty
                                                ? LatLng(
                                                    widget.casas[0].Latitud,
                                                    widget.casas[0].Longitud,
                                                  )
                                                : const LatLng(
                                                    40.416775,
                                                    -3.703790,
                                                  )),
                                      initialZoom: 15,
                                      maxZoom: 18,
                                      minZoom: 2,
                                      interactionOptions:
                                          const InteractionOptions(
                                            flags: InteractiveFlag.all,
                                            enableMultiFingerGestureRace: true,
                                          ),
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        userAgentPackageName:
                                            'com.example.ageinplace_caregiver',
                                        maxZoom: 19,
                                      ),
                                      HeatMapLayer(
                                        heatMapDataSource:
                                            InMemoryHeatMapDataSource(
                                              data: data,
                                            ),
                                        heatMapOptions: HeatMapOptions(
                                          radius: 30,
                                          minOpacity: 0.3,
                                          gradient:
                                              HeatMapOptions.defaultGradient,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // HISTORIAL DE PASOS
                      if (stepList.isNotEmpty) ...[
                        const SizedBox(height: 20),
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
                                  Icon(
                                    Icons.directions_walk,
                                    color: colorPrimario,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    isSpanish
                                        ? 'Historial de pasos'
                                        : 'Step History',
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
                                height: 400,
                                child: SfCartesianChart(
                                  zoomPanBehavior: ZoomPanBehavior(
                                    enablePinching: true,
                                    zoomMode: ZoomMode.xy,
                                    enablePanning: true,
                                    enableMouseWheelZooming: true,
                                  ),
                                  plotAreaBorderWidth: 0,
                                  tooltipBehavior: TooltipBehavior(
                                    enable: true,
                                  ),
                                  primaryXAxis: DateTimeAxis(
                                    dateFormat: DateFormat('HH:mm d/M/y'),
                                    majorGridLines: const MajorGridLines(
                                      width: 0,
                                    ),
                                  ),
                                  primaryYAxis: NumericAxis(
                                    minimum: 0,
                                    maximum: newMaxY > 0 ? newMaxY : 100,
                                    interval: 100,
                                    axisLine: const AxisLine(width: 0),
                                    labelFormat: isSpanish
                                        ? '{value} Pasos'
                                        : '{value} Steps',
                                    majorTickLines: const MajorTickLines(
                                      size: 0,
                                    ),
                                  ),
                                  series: _getStepsPanningSeriesWithColors(),
                                  trackballBehavior: _trackballBehavior,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // BATERÍA
                      if (baterryList.isNotEmpty) ...[
                        const SizedBox(height: 20),
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
                                  Icon(
                                    Icons.battery_full,
                                    color: colorPrimario,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    isSpanish ? 'Batería' : 'Battery',
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
                                height: 400,
                                child: SfCartesianChart(
                                  tooltipBehavior: TooltipBehavior(
                                    enable: true,
                                  ),
                                  key: chartKey,
                                  plotAreaBorderWidth: 0,
                                  primaryXAxis: DateTimeAxis(
                                    dateFormat: DateFormat('HH:mm d/M/y'),
                                    majorGridLines: const MajorGridLines(
                                      width: 0,
                                    ),
                                  ),
                                  primaryYAxis: NumericAxis(
                                    minimum: 0,
                                    maximum: 110,
                                    labelFormat: '{value}%',
                                    axisLine: const AxisLine(width: 0),
                                    anchorRangeToVisiblePoints: _enableAnchor,
                                    majorTickLines: const MajorTickLines(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  series: getBaterryPanningSeries(),
                                  zoomPanBehavior: ZoomPanBehavior(
                                    enablePinching: true,
                                    zoomMode: ZoomMode.xy,
                                    enablePanning: true,
                                    enableMouseWheelZooming: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // SENSORES DE PUERTA
                      if (SensoresPuerta.isNotEmpty &&
                          DSListHistory.isNotEmpty) ...[
                        const SizedBox(height: 20),
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
                                  Icon(
                                    Icons.door_front_door,
                                    color: colorPrimario,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    isSpanish
                                        ? 'Sensores de Puerta'
                                        : 'Door Sensors',
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
                                height: 300,
                                child: SfCartesianChart(
                                  plotAreaBorderWidth: 0,
                                  legend: Legend(
                                    isVisible: isCardView ? false : true,
                                    overflowMode: LegendItemOverflowMode.wrap,
                                  ),
                                  primaryXAxis: DateTimeAxis(
                                    edgeLabelPlacement:
                                        EdgeLabelPlacement.shift,
                                    dateFormat: DateFormat('HH:mm d/M/y'),
                                    interval: 2,
                                    majorGridLines: const MajorGridLines(
                                      width: 0,
                                    ),
                                  ),
                                  primaryYAxis: NumericAxis(
                                    labelFormat: '{value}',
                                    minimum: 0,
                                    maximum: 1,
                                    interval: 1,
                                    axisLine: const AxisLine(width: 0),
                                    axisLabelFormatter: (axisLabelRenderArgs) {
                                      final labelValue =
                                          axisLabelRenderArgs.value;
                                      if (labelValue == 1) {
                                        return ChartAxisLabel(
                                          isSpanish ? 'Abierta' : 'Open',
                                          axisLabelRenderArgs.textStyle,
                                        );
                                      } else {
                                        return ChartAxisLabel(
                                          isSpanish ? 'Cerrada' : 'Closed',
                                          axisLabelRenderArgs.textStyle,
                                        );
                                      }
                                    },
                                    majorTickLines: const MajorTickLines(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  series: _getDSHistoryLineSeries(),
                                  tooltipBehavior: TooltipBehavior(
                                    enable: true,
                                    builder:
                                        (
                                          data,
                                          point,
                                          series,
                                          pointIndex,
                                          seriesIndex,
                                        ) {
                                          if (pointIndex < 0 ||
                                              pointIndex >= DSHistory.length) {
                                            return Container();
                                          }
                                          final DoorSensorData2 DSData =
                                              DSHistory[pointIndex];
                                          return Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: colorPrimario,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              DateFormat('HH:mm dd/MM/yyyy')
                                                  .format(DSData.timestamp)
                                                  .toString(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          );
                                        },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
      // Botón flotante de descarga
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _cargandoDatos ? null : _exportarACSV,
        backgroundColor: colorPrimario,
        icon: const Icon(Icons.download, color: Colors.white),
        label: Text(
          isSpanish ? 'Exportar CSV' : 'Export CSV',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  List<LineSeries<PercentageRoom, DateTime>> _getRoomPercentageLineSeries() {
    List<LineSeries<PercentageRoom, DateTime>> seriesList = [];

    List<String> uniqueRooms = percentageRooms
        .map((room) => room.room)
        .toSet()
        .toList();

    for (String room in uniqueRooms) {
      List<PercentageRoom> roomData = percentageRooms
          .where((data) => data.room == room)
          .toList();

      String translatedRoom = translateFirstWord(room);

      seriesList.add(
        LineSeries<PercentageRoom, DateTime>(
          animationDuration: 2500,
          dataSource: roomData,
          xValueMapper: (PercentageRoom data, _) => data.TimeStamp,
          yValueMapper: (PercentageRoom data, _) => data.percentage,
          width: 2,
          name: translatedRoom,
          markerSettings: const MarkerSettings(isVisible: true),
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        ),
      );
    }

    return seriesList;
  }

  List<StepLineSeries<AlarmaData2, DateTime>> _getAlarmHistoryLineSeries() {
    List<StepLineSeries<AlarmaData2, DateTime>> seriesList = [];

    List uniqueAlarms = AlarmsListHistory.map(
      (alarma) => alarma.Alarma,
    ).toSet().toList();

    for (String alarm in uniqueAlarms) {
      List<AlarmaData2> alarmHistory = AlarmsListHistory.where(
        (data) => data.Alarma == alarm,
      ).toList();

      List<String> alarmParts = alarm.split(':');

      String translatedAlarmName = isSpanish
          ? alarmParts.first
          : (alarmTranslations[alarmParts.first] ?? alarmParts.first);

      String translatedAlarm =
          '$translatedAlarmName: ${alarmParts.skip(1).join(':')}';

      seriesList.add(
        StepLineSeries<AlarmaData2, DateTime>(
          animationDuration: 2500,
          dataSource: alarmHistory,
          xValueMapper: (AlarmaData2 data, _) => data.timestamp,
          yValueMapper: (AlarmaData2 data, _) => data.Valor,
          width: 2,
          name: translatedAlarm,
          markerSettings: const MarkerSettings(isVisible: false),
          dataLabelSettings: const DataLabelSettings(isVisible: false),
        ),
      );
    }

    return seriesList;
  }

  List<StepLineSeries<DoorSensorData, DateTime>> _getDSHistoryLineSeries() {
    List<StepLineSeries<DoorSensorData, DateTime>> seriesList = [];

    List<String> uniqueSensors = DSListHistory.map(
      (sensor) => sensor.Descripcion,
    ).toSet().toList().cast<String>();

    for (String sensor in uniqueSensors) {
      List<DoorSensorData> sensorDataList = [];

      for (var sensorData in DSListHistory) {
        if (sensorData.Descripcion == sensor) {
          sensorDataList.add(
            DoorSensorData(sensorData.timestamp, sensorData.Valor, ''),
          );
        }
      }

      seriesList.add(
        StepLineSeries<DoorSensorData, DateTime>(
          animationDuration: 2500,
          dataSource: sensorDataList,
          xValueMapper: (DoorSensorData data, _) => data.timestamp,
          yValueMapper: (DoorSensorData data, _) => data.Valor,
          width: 2,
          name: sensor,
          markerSettings: const MarkerSettings(isVisible: false),
          dataLabelSettings: const DataLabelSettings(isVisible: false),
        ),
      );
    }

    return seriesList;
  }

  List<BarSeries<PercentageData, String>> _getSpacingBarSeries() {
    var columnWidth = 0.8;
    var columnSpacing = 0.2;
    List<PercentageData> data = [];

    percentageMap.forEach((key, value) {
      if (key == 0) {
        data.add(
          PercentageData(
            isSpanish ? 'Zona no sensorizada' : 'Non-Sensorized Zone',
            value,
          ),
        );
      } else {
        final habitacion = widget.habitaciones.firstWhere(
          (hab) => hab.CodHabitacionSensor == 'HS$key',
        );

        String translatedTipoHabitacion = isSpanish
            ? habitacion.TipoHabitacion
            : (roomTypeTranslations[habitacion.TipoHabitacion] ??
                  habitacion.TipoHabitacion);

        data.add(
          PercentageData(
            '$translatedTipoHabitacion ${habitacion.Observaciones}',
            value,
          ),
        );
      }
    });

    for (var habitacion in widget.habitaciones) {
      final key = int.tryParse(
        habitacion.CodHabitacionSensor?.substring(2) ?? '',
      );

      if (key != null && !percentageMap.containsKey(key)) {
        String translatedTipoHabitacion = isSpanish
            ? habitacion.TipoHabitacion
            : (roomTypeTranslations[habitacion.TipoHabitacion] ??
                  habitacion.TipoHabitacion);

        data.add(
          PercentageData(
            '$translatedTipoHabitacion ${habitacion.Observaciones}',
            0.0,
          ),
        );
      }
    }

    return <BarSeries<PercentageData, String>>[
      BarSeries<PercentageData, String>(
        width: isCardView ? 0.8 : columnWidth,
        spacing: isCardView ? 0.2 : columnSpacing,
        dataSource: data,
        xValueMapper: (PercentageData sales, _) => sales.label,
        yValueMapper: (PercentageData sales, _) => sales.percentage,
        name: isSpanish ? 'Habitación' : 'Room',
      ),
    ];
  }

  List<PieSeries<PercentageData, String>> _getDefaultPieSeries() {
    List<PercentageData> data = [];

    percentageMap.forEach((key, value) {
      if (key == 0) {
        data.add(
          PercentageData(
            isSpanish ? 'Zona no sensorizada' : 'Non-Sensorized Zone',
            value,
          ),
        );
      } else {
        final habitacion = widget.habitaciones.firstWhere(
          (hab) => hab.CodHabitacionSensor == 'HS$key',
        );

        String translatedTipoHabitacion = isSpanish
            ? habitacion.TipoHabitacion
            : (roomTypeTranslations[habitacion.TipoHabitacion] ??
                  habitacion.TipoHabitacion);

        data.add(
          PercentageData(
            '$translatedTipoHabitacion ${habitacion.Observaciones}',
            value,
          ),
        );
      }
    });

    for (var habitacion in widget.habitaciones) {
      final key = int.tryParse(
        habitacion.CodHabitacionSensor?.substring(2) ?? '',
      );

      if (key != null && !percentageMap.containsKey(key)) {
        String translatedTipoHabitacion = isSpanish
            ? habitacion.TipoHabitacion
            : (roomTypeTranslations[habitacion.TipoHabitacion] ??
                  habitacion.TipoHabitacion);

        data.add(
          PercentageData(
            '$translatedTipoHabitacion ${habitacion.Observaciones}',
            0.0,
          ),
        );
      }
    }

    return <PieSeries<PercentageData, String>>[
      PieSeries<PercentageData, String>(
        explode: true,
        explodeIndex: 0,
        explodeOffset: '10%',
        dataSource: data,
        xValueMapper: (PercentageData data, _) => data.label,
        yValueMapper: (PercentageData data, _) => data.percentage,
        dataLabelMapper: (PercentageData data, _) =>
            '${data.percentage}% \n ${data.label}',
        startAngle: 90,
        endAngle: 90,
        dataLabelSettings: const DataLabelSettings(isVisible: true),
      ),
    ];
  }

  String translateFirstWord(String room) {
    List<String> words = room.split(' ');
    if (words.isNotEmpty && !isSpanish) {
      String firstWord = words[0];
      String translatedFirstWord = roomTypeTranslations[firstWord] ?? firstWord;
      words[0] = translatedFirstWord;
    }
    return words.join(' ');
  }

  List<CartesianSeries<BaterryData, DateTime>> getBaterryPanningSeries() {
    return <CartesianSeries<BaterryData, DateTime>>[
      LineSeries<BaterryData, DateTime>(
        dataSource: baterryList,
        name: 'Batería',
        onCreateShader: (ShaderDetails details) {
          return ui.Gradient.linear(
            details.rect.topCenter,
            details.rect.bottomCenter,
            const <Color>[
              Color.fromRGBO(26, 112, 23, 1),
              Color.fromRGBO(26, 112, 23, 1),
              Color.fromARGB(255, 221, 224, 5),
              Color.fromARGB(255, 221, 224, 5),
              Color.fromRGBO(229, 11, 10, 1),
              Color.fromRGBO(229, 11, 10, 1),
            ],
            const <double>[
              0,
              0.355555,
              0.350000,
              0.800000,
              0.8000000,
              0.999999,
            ],
          );
        },
        xValueMapper: (BaterryData bateria, _) => bateria.timestamp,
        yValueMapper: (BaterryData bateria, _) => bateria.Baterry,
      ),
    ];
  }

  List<CartesianSeries<StepData, DateTime>> _getStepsPanningSeriesWithColors() {
    return <CartesianSeries<StepData, DateTime>>[
      StepLineSeries<StepData, DateTime>(
        dataSource: stepList,
        name: 'Pasos',
        xValueMapper: (StepData pasos, _) => pasos.timestamp,
        yValueMapper: (StepData pasos, _) => pasos.Step,
        pointColorMapper: (StepData pasos, _) =>
            _getStepColorCorregido(pasos.timestamp, stepList),
      ),
    ];
  }

  Color _getStepColorCorregido(DateTime timestamp, List<StepData> stepList) {
    if (stepList.isEmpty) {
      return Colors.blue;
    }

    Set<String> uniqueDays = {};
    for (var step in stepList) {
      String dayKey =
          '${step.timestamp.year}-${step.timestamp.month}-${step.timestamp.day}';
      uniqueDays.add(dayKey);
    }

    List<String> sortedDays = uniqueDays.toList()..sort();

    String currentDayKey =
        '${timestamp.year}-${timestamp.month}-${timestamp.day}';
    int dayIndex = sortedDays.indexOf(currentDayKey);

    final List<Color> colorList = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.yellow,
      Colors.pink,
      Colors.teal,
      Colors.brown,
      Colors.cyan,
      Colors.indigo,
      Colors.lime,
      Colors.amber,
      Colors.deepOrange,
      Colors.deepPurple,
      Colors.lightGreen,
      Colors.lightBlue,
    ];

    if (dayIndex == -1) {
      dayIndex = 0;
    }

    int colorIndex = dayIndex % colorList.length;
    return colorList[colorIndex];
  }

  List<StepLineSeries<RoomData, DateTime>> _getRoomLineSeries() {
    return <StepLineSeries<RoomData, DateTime>>[
      StepLineSeries<RoomData, DateTime>(
        animationDuration: 2500,
        dataSource: dataRoom,
        xValueMapper: (RoomData sales, _) => sales.timestamp,
        yValueMapper: (RoomData sales, _) => sales.CodHabitacionSensor,
        dataLabelMapper: (RoomData sales, _) => sales.room,
        width: 2,
        markerSettings: const MarkerSettings(isVisible: false),
      ),
    ];
  }

  List<StepLineSeries<AlarmData, DateTime>> _getAlarmLineSeries() {
    return <StepLineSeries<AlarmData, DateTime>>[
      StepLineSeries<AlarmData, DateTime>(
        animationDuration: 2500,
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
      text = Text(
        isSpanish ? 'Alarma desactivada' : 'Alarm off',
        style: style,
        textAlign: TextAlign.right,
      );
    } else if (value == 1) {
      text = Text(
        isSpanish ? 'Alarma caída' : 'Fall alarm',
        style: style,
        textAlign: TextAlign.right,
      );
    } else if (value == 2) {
      text = Text(
        isSpanish ? 'Botón Pánico' : 'Panic Button',
        style: style,
        textAlign: TextAlign.right,
      );
    } else if (value == 3) {
      text = Text(
        isSpanish
            ? 'Alarma caída y Botón Pánico'
            : 'Fall alarm and Panic Button',
        style: style,
        textAlign: TextAlign.right,
      );
    } else {
      text = const Text('', style: style, textAlign: TextAlign.right);
    }

    return SideTitleWidget(meta: meta, space: 20, child: text);
  }
}

// Función para generar marcadores de casas
List<Marker> generarMarkers(List<Casa> casas) {
  List<Marker> markers = [];

  for (var i = 0; i < casas.length; i++) {
    if (i == 0) {
      markers.add(
        Marker(
          point: LatLng(casas[i].Latitud, casas[i].Longitud),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () {
            },
            child: const Icon(Icons.home, color: Colors.red, size: 40.0),
          ),
        ),
      );
    } else {
      markers.add(
        Marker(
          point: LatLng(casas[i].Latitud, casas[i].Longitud),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () {
            },
            child: const Icon(Icons.home, color: Colors.blue, size: 40.0),
          ),
        ),
      );
    }
  }

  return markers;
}

class HeatmapPainter extends CustomPainter {
  final List<dynamic> data;

  HeatmapPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    double maxValue = data
        .map((e) => e['value'])
        .reduce((value, element) => value > element ? value : element);
    for (dynamic point in data) {
      double value = point['value'];
      double opacity = value / maxValue;
      Paint paint = Paint()..color = Colors.red.withOpacity(opacity);
      canvas.drawCircle(
        LatLngToPoint(point['lat'], point['lng'], size) as Offset,
        20.0,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  Point<double> LatLngToPoint(double lat, double lng, Size size) {
    double x = (lng + 180.0) * (size.width / 360.0);
    double latRad = lat * math.pi / 180.0;
    double y =
        (1.0 - log(tan(latRad) + 1.0 / cos(latRad)) / math.pi) /
        2.0 *
        size.height;
    return Point(x, y);
  }
}

class ChartData {
  final String label;
  final double value;

  ChartData(this.label, this.value);
}

class PercentageData {
  final String label;
  final double percentage;

  PercentageData(this.label, this.percentage);
}

class PercentageRoom {
  final DateTime TimeStamp;
  late final String room;
  late final double percentage;

  PercentageRoom(this.TimeStamp, this.room, this.percentage);
}