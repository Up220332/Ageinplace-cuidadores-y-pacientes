import 'package:ageinplace/Cuidador/screen_preguntas_paciente.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../BarraLateral/NavBar_caregiver.dart';
import '../Cuidador/screen_WearablePaciente.dart';
import '../base_de_datos/postgres.dart';
import '../localization/locales.dart';
import '../log-in/screen_LogIn.dart';

/// *****************************************************************************
/// Funcion que muestra todos los pacientes de la base de datos
///****************************************************************************
class PacientesCuidadorScreen extends StatefulWidget {
  const PacientesCuidadorScreen({super.key});

  @override
  State<PacientesCuidadorScreen> createState() =>
      _PacientesCuidadorScreenState();
}

class _PacientesCuidadorScreenState extends State<PacientesCuidadorScreen> { 
  List<Pacientes> TodoPacientesList = [];
  List<Casa> CasaList = [];
  List<Pacientes> PacientesList = [];
  final colorPrimario = const Color.fromARGB(255, 25, 144, 234);
  
  // ELIMINADO: late bool isSpanish;

  Future<String> getData() async {
    // Verificar que usuario no sea null y tenga elementos
    if (usuario == null || usuario.isEmpty) {
      print('Error: usuario no está inicializado');
      return 'Error: usuario no inicializado';
    }

    var Dbdata = await DBPostgres().DBGetPacientesViviendasCuidador(
      usuario[0].CodUsuario,
      'null',
    );
    
    String Estado;
    setState(() {
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
    });
    
    for (Casa casa in CasaList) {
      for (Pacientes paciente in TodoPacientesList) {
        if (paciente.CodCasa == casa.CodCasa) {
          PacientesList.add(paciente);
        }
      }
    }

    return 'Successfully Fetched data :)';
  }

  @override
  void initState() {
    super.initState();
    
    // ELIMINADO: FlutterLocalization.instance.onTranslatedLanguage = _onLanguageChanged;
    
    getData();
  }

  // ELIMINADO: void _onLanguageChanged(Locale? locale) {...}

  @override
  void dispose() {
    // ELIMINADO: FlutterLocalization.instance.onTranslatedLanguage = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PacientesList.sort((a, b) => a.F_ALTA.compareTo(b.F_ALTA));
    
    // AGREGADO: isSpanish DENTRO del build
    final bool isSpanish = FlutterLocalization.instance.currentLocale?.languageCode == 'es';
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorPrimario,
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.5),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          LocaleData.titleCaregiver.getString(context),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        automaticallyImplyLeading: false,
      ),
      endDrawer: NavBarCaregiver(),
      body: Container(
        decoration: BoxDecoration(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
          child: PacientesList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.elderly_outlined, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        isSpanish ? 'No hay pacientes asignados' : 'No assigned patients',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isSpanish ? 'Los pacientes aparecerán aquí' : 'Patients will appear here',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: PacientesList.length,
                  itemBuilder: (context, index) {
                    return _buildPacienteCard(context, index, isSpanish);
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildPacienteCard(BuildContext context, int index, bool isSpanish) {
    final paciente = PacientesList[index];
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          final opcion = await showDialog<String>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Row(
                  children: [
                    Icon(Icons.help_outline, color: colorPrimario),
                    const SizedBox(width: 10),
                    Text(
                      isSpanish ? '¿Qué desea ver?' : 'What would you like to see?',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                content: Text(
                  isSpanish 
                    ? 'Selecciona una opción para el paciente.' 
                    : 'Select an option for the patient.',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop('wearables');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorPrimario.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isSpanish ? 'Wearables' : 'Wearables',
                        style: TextStyle(
                          color: colorPrimario,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop('preguntas');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorPrimario.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isSpanish ? 'Preguntas' : 'Questions',
                        style: TextStyle(
                          color: colorPrimario,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );

          if (opcion == 'wearables') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WearablePacienteCuidadorScreen(
                  paciente: paciente,
                ),
              ),
            );
          } else if (opcion == 'preguntas') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PreguntasPacienteScreen(
                  pacienteId: paciente.CodPaciente,
                ),
              ),
            );
          }
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
              // Avatar con iniciales
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
                child: Center(
                  child: Text(
                    '${paciente.Nombre[0]}${paciente.Apellido1[0]}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Información del paciente
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${paciente.Nombre} ${paciente.Apellido1} ${paciente.Apellido2}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.email_outlined, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            paciente.Email,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          paciente.Telefono,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Fecha
              Text(
                formatDate(paciente.F_ALTA, [dd, '/', mm, '/', yyyy]),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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