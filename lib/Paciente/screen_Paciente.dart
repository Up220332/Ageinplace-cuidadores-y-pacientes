import 'dart:core';

import 'package:ageinplace/Paciente/screen_questions_by_day.dart';
import '../models/wearable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../BarraLateral/NavBar_patient.dart';
import '../Cuidador/screen_Paciente.dart';
import '../Cuidador/screen_Pacientes.dart';
import '../Paciente/screen_AlarmasADL.dart';
import '../Paciente/screen_Consumo.dart';
import '../Paciente/screen_Estadistica.dart';
import '../Paciente/screen_TiempoReal.dart';
import '../Paciente/screen_WearablePaciente.dart';
import '../base_de_datos/postgres.dart';
import '../log-in/screen_LogIn.dart';

class PacientePacienteScreen extends StatefulWidget {
  final Wearable wearable;

  const PacientePacienteScreen({super.key, required this.wearable});

  @override
  State<PacientePacienteScreen> createState() => _PacientePacienteScreenState();
}

class _PacientePacienteScreenState extends State<PacientePacienteScreen> {
  int _selectedIndex = 0;
  List<Casa> CasaList = [];
  List<Habitaciones> HabitacionesList = [];
  late Widget PaginaActual;
  Paciente? PacienteInfo;
  late Wearable WearableInfo;
  bool isLoading = true;
  List<Sensores> SmartMeter = [];
  bool hasQuestions = false;

  final colorPrimario = const Color.fromARGB(255, 25, 144, 234);
  bool isSpanish = true;
  Key _refreshKey = UniqueKey(); 

  Future<void> getData() async {
    var Dbdata = await DBPostgres().DBGetDatosPacientePacinete2(
      usuario[0].CodUsuario,
      'null',
    );
    String Estado;

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
      for (var p in Dbdata[2]) {
        Estado = (p[9] == null) ? 'Activo' : 'Inactivo';
        PacienteInfo = Paciente(
          p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8],
          p[9], p[10], p[11], p[12], p[13], p[14], p[15], Estado,
        );
      }
      for (var p in Dbdata[4]) {
        SmartMeter.add(
          Sensores(
            p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9],
            p[10], p[11], p[12], p[13],
          ),
        );
      }
    });
  }

  Future<void> getData2() async {
    var Dbdata = await DBPostgres().DBGetWearable(
      usuario[0].CodUsuario,
      'ACTIVO',
    );
    String Estado;

    setState(() {
      for (var p in Dbdata) {
        Estado = (p[5] == null) ? 'Activo' : 'Inactivo';
        WearableInfo = Wearable(
          p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], Estado,
        );
      }
    });
  }

  Future<void> verificarPreguntas() async {
    if (PacienteInfo != null) {
      final result = await DBPostgres().hayPreguntasDisponiblesYEsHora(
        PacienteInfo!.CodPaciente,
      );
      setState(() {
        hasQuestions = result;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    
    isSpanish = FlutterLocalization.instance.currentLocale?.languageCode == 'es';
    FlutterLocalization.instance.onTranslatedLanguage = _onLanguageChanged;
    
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    await getData();
    await getData2();
    await verificarPreguntas();
    
    if (mounted) {
      setState(() {
        isLoading = false;
        if (PacienteInfo != null) {
          PaginaActual = TiempoRealPage(
            paciente: PacienteInfo!,
            wearable: widget.wearable,
            casas: CasaList,
            habitaciones: HabitacionesList,
          );
        }
      });
    }
  }

  void _onLanguageChanged(Locale? locale) {
    if (mounted) {
      setState(() {
        isSpanish = locale?.languageCode == 'es';
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
    if (isLoading || PacienteInfo == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: colorPrimario,
          centerTitle: true,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.5),
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Cargando...',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WearablePacientePacienteScreen(),
          ),
        );
        return false;
      },
      child: Scaffold(
        key: _refreshKey,
        appBar: AppBar(
          backgroundColor: colorPrimario,
          centerTitle: true,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.5),
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            '${PacienteInfo!.Nombre} ${PacienteInfo!.Apellido1} ${PacienteInfo!.Apellido2}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        endDrawer: const NavBarPatient(),
        body: PaginaActual,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: BottomNavigationBar(
            key: ValueKey('bottom_nav_${isSpanish ? 'es' : 'en'}'),
            iconSize: 28,
            backgroundColor: colorPrimario,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
                switch (index) {
                  case 0:
                    PaginaActual = TiempoRealPage(
                      paciente: PacienteInfo!,
                      wearable: widget.wearable,
                      casas: CasaList,
                      habitaciones: HabitacionesList,
                    );
                    break;
                  case 1:
                    PaginaActual = PreguntasDelDiaScreen(
                      pacienteId: PacienteInfo!.CodPaciente,
                    );
                    break;
                  case 2:
                    PaginaActual = EstadisticasPage(
                      paciente: PacienteInfo!,
                      wearable: widget.wearable,
                      habitaciones: HabitacionesList,
                      casas: CasaList,
                    );
                    break;
                  case 3:
                    PaginaActual = SmartMeter.isNotEmpty
                        ? ConsumoPage(
                            paciente: PacienteInfo!,
                            wearable: widget.wearable,
                            habitaciones: HabitacionesList,
                            casas: CasaList,
                          )
                        : AlarmADLPage(
                            paciente: PacienteInfo!,
                            wearable: widget.wearable,
                            habitaciones: HabitacionesList,
                            casas: CasaList,
                          );
                    break;
                }
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.nordic_walking),
                label: isSpanish ? 'Tiempo real' : 'Real time',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.question_answer),
                    if (hasQuestions)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                label: isSpanish ? 'Preguntas' : 'Questions',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.query_stats_rounded),
                label: isSpanish ? 'Estadísticas' : 'Statistics',
              ),
              SmartMeter.isNotEmpty
                  ? BottomNavigationBarItem(
                      icon: const Icon(Icons.electrical_services),
                      label: isSpanish ? 'Consumo' : 'Consumption',
                    )
                  : BottomNavigationBarItem(
                      icon: const Icon(Icons.task_sharp),
                      label: isSpanish ? 'ADLs/Alarmas' : 'ADLs/Alarms',
                    ),
            ],
          ),
        ),
      ),
    );
  }
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
  final String ObservacionesAlarma;

  Alarmas(
    this.CodAlarma,
    this.Alarma,
    this.TipoAlarma,
    this.ObservacionesAlarma,
  );
}

class Paciente {
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

  Paciente(
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