import 'dart:core';

import 'package:ageinplace/Cuidador/screen_AlarmasInact.dart';
import 'package:ageinplace/Cuidador/screen_Consumo.dart';
import 'package:ageinplace/Cuidador/screen_ModPacienteCuidador.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:geodesy/geodesy.dart';

import '../BarraLateral/NavBar_caregiver.dart';
import '../Cuidador/screen_ADLs.dart';
import '../Cuidador/screen_Alarmas.dart';
import '../Cuidador/screen_AlarmasADL.dart';
import '../Cuidador/screen_Estadisticas.dart';
import '../Cuidador/screen_Pacientes.dart';
import '../Cuidador/screen_TiempoReal.dart';
import '../Cuidador/screen_WearablePaciente.dart';
import '../base_de_datos/postgres.dart';
import '../models/wearable.dart';

class PacienteCuidadorScreen extends StatefulWidget {
  final Wearable wearable;
  final Pacientes paciente;

  const PacienteCuidadorScreen({
    super.key,
    required this.wearable,
    required this.paciente,
  });

  @override
  State<PacienteCuidadorScreen> createState() => _PacienteCuidadorScreenSate();
}

class _PacienteCuidadorScreenSate extends State<PacienteCuidadorScreen> {
  int _selectedIndex = 0;
  List<Casa> CasaList = [];
  List<Habitaciones> HabitacionesList = [];
  List<Sensores> SmartMeter = [];
  bool _isDataLoaded = false;
  
  // Variable para idioma
  late bool isSpanish;

  // Key para forzar reconstrucción de las páginas
  late Key _refreshKey;

  Future<String> getData() async {
    var Dbdata = await DBPostgres().DBGetDatosPacienteCuidador2(
      widget.paciente.CodPaciente,
      'null',
    );
    
    CasaList.clear();
    HabitacionesList.clear();
    SmartMeter.clear();
    
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
    for (var p in Dbdata[3]) {
      SmartMeter.add(
        Sensores(
          p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9], p[10], p[11], p[12], p[13],
        ),
      );
    }
    
    if (mounted) {
      setState(() {
        _isDataLoaded = true;
      });
    }
    
    return 'Successfully Fetched data';
  }

  // Método para obtener las páginas con keys dinámicas
  List<Widget> _buildPaginas() {
    return [
      TiempoRealPage(
        key: ValueKey('tiempo_real_${isSpanish ? 'es' : 'en'}_$_selectedIndex'),
        paciente: widget.paciente,
        wearable: widget.wearable,
        habitaciones: HabitacionesList,
        casas: CasaList,
      ),
      PacientePage(
        key: ValueKey('paciente_page_${isSpanish ? 'es' : 'en'}_$_selectedIndex'),
        paciente: widget.paciente,
        wearable: widget.wearable,
        casas: CasaList,
      ),
      AlarmasPage(
        key: ValueKey('alarmas_${isSpanish ? 'es' : 'en'}_$_selectedIndex'),
        paciente: widget.paciente,
        HabitacionesList: HabitacionesList,
        CasaList: CasaList,
      ),
      AlarmasInactPage(
        key: ValueKey('alarmas_inact_${isSpanish ? 'es' : 'en'}_$_selectedIndex'),
        paciente: widget.paciente,
        HabitacionesList: HabitacionesList,
        CasaList: CasaList,
      ),
      ADLsPage(
        key: ValueKey('adls_${isSpanish ? 'es' : 'en'}_$_selectedIndex'),
        paciente: widget.paciente,
        HabitacionesList: HabitacionesList,
        CasaList: CasaList,
      ),
      EstadisticasPage(
        key: ValueKey('estadisticas_${isSpanish ? 'es' : 'en'}_$_selectedIndex'),
        paciente: widget.paciente,
        wearable: widget.wearable,
        habitaciones: HabitacionesList,
        casas: CasaList,
      ),
      ConsumoPage(
        key: ValueKey('consumo_${isSpanish ? 'es' : 'en'}_$_selectedIndex'),
        paciente: widget.paciente,
        wearable: widget.wearable,
        habitaciones: HabitacionesList,
        casas: CasaList,
      ),
      AlarmADLsPage(
        key: ValueKey('alarm_adls_${isSpanish ? 'es' : 'en'}_$_selectedIndex'),
        paciente: widget.paciente,
        wearable: widget.wearable,
        habitaciones: HabitacionesList,
        casas: CasaList,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    
    // Inicializar idioma y listener
    FlutterLocalization.instance.onTranslatedLanguage = _onLanguageChanged;
    isSpanish = FlutterLocalization.instance.currentLocale?.languageCode == 'es';
    _refreshKey = UniqueKey();
    
    getData();
  }

  void _onLanguageChanged(Locale? locale) {
    if (mounted) {
      setState(() {
        isSpanish = locale?.languageCode == 'es';
        // Cambiar la key para forzar reconstrucción
        _refreshKey = UniqueKey();
      });
    }
  }

  @override
  void dispose() {
    FlutterLocalization.instance.onTranslatedLanguage = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorPrimario = const Color.fromARGB(255, 25, 144, 234);
    
    if (!_isDataLoaded) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: colorPrimario,
          centerTitle: true,
          elevation: 0,
          title: Text(
            '${widget.paciente.Nombre} ${widget.paciente.Apellido1}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WearablePacienteCuidadorScreen(paciente: widget.paciente),
          ),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorPrimario,
          centerTitle: true,
          elevation: 4, 
          shadowColor: Colors.black.withOpacity(0.5), 
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            '${widget.paciente.Nombre} ${widget.paciente.Apellido1} ${widget.paciente.Apellido2}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        endDrawer: const NavBarCaregiver(),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: BottomNavigationBar(
            key: ValueKey('bottom_nav_${isSpanish ? 'es' : 'en'}'),
            iconSize: 24,
            backgroundColor: colorPrimario,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white60,
            currentIndex: _selectedIndex,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.assist_walker),
                label: isSpanish ? 'Tiempo Real' : 'Real Time',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings), 
                label: isSpanish ? 'Paciente' : 'Patient'
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.notifications_rounded),
                label: isSpanish ? 'Alarmas' : 'Alarms',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.notifications_off),
                label: isSpanish ? 'Inactividad' : 'Inactivity',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.backpack_outlined),
                label: 'ADLs',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.query_stats_rounded),
                label: isSpanish ? 'Estadísticas' : 'Statistics',
              ),
              if (SmartMeter.isNotEmpty)
                BottomNavigationBarItem(
                  icon: const Icon(Icons.electrical_services),
                  label: isSpanish ? 'Consumo' : 'Consumption',
                ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.task_sharp), 
                label: isSpanish ? 'Alarmas ADL' : 'ADL Alarms'
              ),
            ],
          ),
        ),
        // Usar Key en el body para forzar reconstrucción completa
        body: KeyedSubtree(
          key: _refreshKey,
          child: _buildPaginas()[_selectedIndex],
        ),
      ),
    );
  }
}

class PacientePage extends StatefulWidget {
  final Pacientes paciente;
  final Wearable wearable;
  final List<Casa> casas;

  const PacientePage({
    super.key,
    required this.paciente,
    required this.wearable,
    required this.casas,
  });

  @override
  _PacientePageState createState() => _PacientePageState();
}

class _PacientePageState extends State<PacientePage> {
  // ELIMINADO: late bool isSpanish;

  // Mapas de traducción
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

  Map<String, String> translationsVarSocial = {
    "Autónomo": "Autonomous",
    "Dependiente grave": "Severely Dependent",
    "Dependiente leve": "Mildly Dependent",
    "Riesgo aislamiento": "Isolation Risk",
    "Tensiones económicas": "Economic Tensions",
    "Con red social de apoyo": "With Social Support Network",
    "Red social apoyo reducida": "Reduced Social Support Network",
    "Sin red social de apoyo": "Without Social Support Network",
    "Otros": "Others",
  };

  Map<String, String> translationsVarSanitaria = {
    "Adicciones": "Addictions",
    "Alzheimer": "Alzheimer",
    "Anemia": "Anemia",
    "Ansiedad": "Anxiety",
    "Artrosis": "Osteoarthritis",
    "Cáncer": "Cancer",
    "Demencia": "Dementia",
    "Depresion": "Depression",
    "Diabetes": "Diabetes",
    "Esquizofrenia": "Schizophrenia",
    "Fragilidad": "Frailty",
    "Hipertensión": "Hypertension",
    "Ictus": "Stroke",
    "Incontinencia Urinaria": "Urinary Incontinence",
    "Infarto": "Heart Attack",
    "Osteoporosis": "Osteoporosis",
    "Parkinson": "Parkinson's",
    "Problemas auditivos": "Hearing Problems",
    "Problemas visuales": "Visual Problems",
    "Sano": "Healthy",
    "Trastornos de sueño": "Sleep Disorders",
    "Trastornos mentales": "Mental Disorders",
    "Otros": "Others",
  };

  @override
  void initState() {
    super.initState();
    // ELIMINADO: FlutterLocalization.instance.onTranslatedLanguage = _onLanguageChanged;
  }

  // ELIMINADO: void _onLanguageChanged(Locale? locale) {...}

  @override
  void dispose() {
    // ELIMINADO: FlutterLocalization.instance.onTranslatedLanguage = null;
    super.dispose();
  }

  // Función mejorada para traducir variables sociales
  String translateSocialVarString(String socialVar, bool isSpanish) {
    if (isSpanish) {
      return socialVar;
    } else {
      // Dividir por comas y traducir cada parte
      List<String> parts = socialVar.split(', ');
      List<String> translatedParts = parts.map((part) {
        return translationsVarSocial[part] ?? part;
      }).toList();
      return translatedParts.join(', ');
    }
  }

  // Función mejorada para traducir variables sanitarias
  String translateSanitariaVarString(String sanitariaVar, bool isSpanish) {
    if (isSpanish) {
      return sanitariaVar;
    } else {
      // Dividir por comas y traducir cada parte
      List<String> parts = sanitariaVar.split(', ');
      List<String> translatedParts = parts.map((part) {
        return translationsVarSanitaria[part] ?? part;
      }).toList();
      return translatedParts.join(', ');
    }
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

  @override
  Widget build(BuildContext context) {
    // AGREGADO: isSpanish DENTRO del build
    final bool isSpanish = FlutterLocalization.instance.currentLocale?.languageCode == 'es';
    final colorPrimario = const Color.fromARGB(255, 25, 144, 234);
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 25),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                _buildModernCard(
                  title: isSpanish ? 'Información Personal' : 'Personal Information',
                  icon: Icons.person, 
                  child: Column(
                    children: [
                      _buildInfoRow(Icons.email, isSpanish ? 'Correo' : 'Email', widget.paciente.Email),
                      _buildInfoRow(Icons.phone, isSpanish ? 'Teléfono' : 'Phone', widget.paciente.Telefono),
                      _buildInfoRow(Icons.cake, isSpanish ? 'Nacimiento' : 'Birth Date', widget.paciente.FechaNacimiento.toString()),
                    ],
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      child: _buildModernCard(
                        title: isSpanish ? 'Patología' : 'Pathology',
                        icon: Icons.medical_services, 
                        iconColor: Colors.redAccent,
                        child: Text(
                          translateSanitariaVarString(widget.paciente.VarSanitaria, isSpanish),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildModernCard(
                        title: isSpanish ? 'Autonomía' : 'Autonomy',
                        icon: Icons.accessibility_new, 
                        iconColor: Colors.green,
                        child: Text(
                          translateSocialVarString(widget.paciente.VarSocial, isSpanish),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),

                _buildModernCard(
                  title: isSpanish ? 'Viviendas Registradas' : 'Registered Residences',
                  icon: Icons.home, 
                  iconColor: Colors.orange,
                  child: Column(
                    children: widget.casas.map((casa) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        translateCountryInAddress(casa.Dirrecion, isSpanish), 
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15),
                      ),
                    )).toList(),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ModPacienteScreen(
                            paciente: widget.paciente, 
                            wearable: widget.wearable,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, color: Colors.white), 
                    label: Text(
                      isSpanish ? 'Modificar paciente' : 'Edit patient',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 16, 
                        letterSpacing: 1.1, 
                        color: Colors.white
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorPrimario,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCard({
    required String title, 
    required IconData icon, 
    required Widget child, 
    Color iconColor = const Color.fromARGB(255, 25, 144, 234)
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), 
            blurRadius: 15, 
            offset: const Offset(0, 6)
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: iconColor),
              const SizedBox(width: 10),
              Text(
                title, 
                style: TextStyle(
                  fontSize: 15, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.blueGrey[800]
                ),
              ),
            ],
          ),
          const Divider(height: 25, thickness: 0.8),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 19, color: Colors.blueGrey[300]),
          const SizedBox(width: 12),
          Text("$label:", style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value, 
              style: const TextStyle(color: Colors.black87), 
              overflow: TextOverflow.ellipsis
            ),
          ),
        ],
      ),
    );
  }
}

// ========== CLASES DE MODELO ==========

class RoomData {
  String room;
  DateTime timestamp;
  int CodHabitacionSensor;

  RoomData(this.room, this.timestamp, this.CodHabitacionSensor);
}

class LTSMData {
  double energy;
  DateTime timestamp;
  String name;

  LTSMData(this.energy, this.timestamp, this.name);
}

class AlarmaData {
  var Caida;
  var Boton;
  DateTime timestampCaida;
  DateTime timestampBoton;

  AlarmaData(this.Caida, this.Boton, this.timestampCaida, this.timestampBoton);
}

class AlarmaData2 {
  var Alarma;
  var Valor;
  DateTime timestamp;

  AlarmaData2(this.Alarma, this.Valor, this.timestamp);
}

class DoorSensorData {
  var Valor;
  DateTime timestamp;
  var CodHabitacionSensor;

  DoorSensorData(
    this.timestamp,
    this.Valor,
    this.CodHabitacionSensor,
  );
}

class DoorSensorData2 {
  var Descripcion;
  var Valor;
  DateTime timestamp;

  DoorSensorData2(this.timestamp, this.Valor, this.Descripcion);
}

class DoorSensorData3 {
  var Valor;
  DateTime timestamp;

  DoorSensorData3(this.timestamp, this.Valor);
}

class AlarmData {
  var Alarma;
  DateTime timestamp;

  AlarmData(this.Alarma, this.timestamp);
}

class StepData {
  var Step;
  DateTime timestamp;

  StepData(this.Step, this.timestamp);
}

class BaterryData {
  var Baterry;
  DateTime timestamp;

  BaterryData(this.Baterry, this.timestamp);
}

class LatData {
  var Lat;
  DateTime timestamp;

  LatData(this.Lat, this.timestamp);
}

class LongData {
  var Long;
  DateTime timestamp;

  LongData(this.Long, this.timestamp);
}

class Coordenas {
  LatLng coordenadas;
  DateTime timestamp;

  Coordenas(this.coordenadas, this.timestamp);
}

class Habitaciones {
  final int CodHabitacion;
  final String Observaciones;
  final int? NumPlanta;
  final int CodTipoHabitacion;
  final String TipoHabitacion;
  final DateTime FechaAltaHabitacion;
  final DateTime? FechaBajaHabitacion;
  final String? CodHabitacionSensor;
  final DateTime? FechaAltaHabitacionSensor;
  final DateTime? FechaBajaHabitacionSensor;
  final int? CodSensor;

  Habitaciones(
    this.CodHabitacion,
    this.Observaciones,
    this.NumPlanta,
    this.CodTipoHabitacion,
    this.TipoHabitacion,
    this.FechaAltaHabitacion,
    this.FechaBajaHabitacion,
    this.CodHabitacionSensor,
    this.FechaAltaHabitacionSensor,
    this.FechaBajaHabitacionSensor,
    this.CodSensor,
  );
}

class Sensores {
  final int CodHabitacion;
  final String Observaciones;
  final int? NumPlanta;
  final int CodTipoHabitacion;
  final String TipoHabitacion;
  final DateTime FechaAltaHabitacion;
  final DateTime? FechaBajaHabitacion;
  final String? CodHabitacionSensor;
  final DateTime? FechaAltaHabitacionSensor;
  final DateTime? FechaBajaHabitacionSensor;
  final int? CodSensor;
  final String? TipoSensor;
  final String? Descripcion;
  final String? IDSensor;

  Sensores(
    this.CodHabitacion,
    this.Observaciones,
    this.NumPlanta,
    this.CodTipoHabitacion,
    this.TipoHabitacion,
    this.FechaAltaHabitacion,
    this.FechaBajaHabitacion,
    this.CodHabitacionSensor,
    this.FechaAltaHabitacionSensor,
    this.FechaBajaHabitacionSensor,
    this.CodSensor,
    this.TipoSensor,
    this.Descripcion,
    this.IDSensor,
  );
}

class AlarmaParametros {
  final int CodAlarmaParametro;
  final int CodAlarma;
  final String Alarma;
  final String TipoAlarma;
  final String ObservacionesAlarma;
  final int CodParametro;
  final String Parametro;
  final String Mascara;
  final String ObservacionesParametro;

  AlarmaParametros(
    this.CodAlarmaParametro,
    this.CodAlarma,
    this.Alarma,
    this.TipoAlarma,
    this.ObservacionesAlarma,
    this.CodParametro,
    this.Parametro,
    this.Mascara,
    this.ObservacionesParametro,
  );
}

class Alarmas {
  final int CodAlarma;
  final String Alarma;
  final String TipoAlarma;
  String ObservacionesAlarma;

  Alarmas(
    this.CodAlarma,
    this.Alarma,
    this.TipoAlarma,
    this.ObservacionesAlarma,
  );
}

class AlarmasPaciente {
  final int CodAlarma;
  final String Alarma;
  final String DesAlarma;
  final String CodAlarmaPaciente;
  final DateTime? FechaAltaAlarmaPaciente;
  final DateTime? FechaBajaAlarmaPaciente;

  AlarmasPaciente(
    this.CodAlarma,
    this.Alarma,
    this.DesAlarma,
    this.CodAlarmaPaciente,
    this.FechaAltaAlarmaPaciente,
    this.FechaBajaAlarmaPaciente,
  );
}

class AlarmasParametrosValor {
  final String CodAlarmaPaciente;
  final String Valor;
  final int CodAlarmaParametro;
  final int CodParametro;
  final String Parametro;
  final String Mascara;

  AlarmasParametrosValor(
    this.CodAlarmaPaciente,
    this.Valor,
    this.CodAlarmaParametro,
    this.CodParametro,
    this.Parametro,
    this.Mascara,
  );
}