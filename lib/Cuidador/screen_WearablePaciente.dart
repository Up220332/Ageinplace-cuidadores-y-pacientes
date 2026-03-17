import '../models/wearable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../BarraLateral/NavBar_caregiver.dart';
import '../Cuidador/screen_Paciente.dart';
import '../Cuidador/screen_Pacientes.dart';
import '../base_de_datos/postgres.dart';

/*******************************************************************************
 * Funcion que muestra todos los wearables del paciente
 ******************************************************************************/

class WearablePacienteCuidadorScreen extends StatefulWidget {
  final Pacientes paciente;

  const WearablePacienteCuidadorScreen({super.key, required this.paciente});

  @override
  State<WearablePacienteCuidadorScreen> createState() =>
      _WearablePacienteCuidadorScreenState();
}

class _WearablePacienteCuidadorScreenState
    extends State<WearablePacienteCuidadorScreen> {
  List<Wearable> WearableList = [];
  List<Wearable> WearableDispList = [];
  List<TipoWearable> TipoWearableList = [];
  List<Pacientes> PacientesList = [];

  late int CodTipoWearable = 1;
  late int CodWearable = 1;
  late int CodPacienteWearableExist = 1;

  final colorPrimario = const Color.fromARGB(255, 25, 144, 234);
  
  // ELIMINADO: late bool isSpanish;

  Map<String, String> wearableTypeTranslations = {
    'Banda': 'Band',
    'Colgante': 'Pendant',
    'Llavero': 'Keychain',
    'Reloj': 'Watch',
    'Textil': 'Textile',
    'Otros': 'Others',
  };

  Wearable noneWearable = Wearable(
    0,
    "Ninguno",
    0,
    "",
    "",
    DateTime.now(),
    null,
    "none",
    0,
    "none",
  );

  Future<String> getData() async {
    String Estado;
    var Dbdata = await DBPostgres().DBGetWearable(
      widget.paciente.CodPaciente,
      'ACTIVO',
    );
    setState(() {
      for (var p in Dbdata) {
        if (p[5] == null) {
          Estado = 'Activo';
        } else {
          Estado = 'Inactivo';
        }
        WearableList.add(
          Wearable(
            p[0],
            p[1],
            p[2],
            p[3],
            p[4],
            p[5],
            p[6],
            p[7],
            p[8],
            Estado,
          ),
        );
      }
    });
    return 'Successfully Fetched data';
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

  List<String> generarEtiquetas(List<Wearable> wearables) {
    Map<String, int> contadorPorTipo = {};
    Map<String, int> contadorNumericoPorTipo = {};

    for (var wearable in wearables) {
      contadorPorTipo[wearable.TipoWeareable] =
          (contadorPorTipo[wearable.TipoWeareable] ?? 0) + 1;
    }

    return wearables.map((wearable) {
      if (contadorPorTipo[wearable.TipoWeareable]! > 1) {
        contadorNumericoPorTipo[wearable.TipoWeareable] =
            (contadorNumericoPorTipo[wearable.TipoWeareable] ?? 0) + 1;
        int numero = contadorNumericoPorTipo[wearable.TipoWeareable]!;
        return '${wearable.TipoWeareable} $numero';
      } else {
        return wearable.TipoWeareable;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    PacientesList.sort((a, b) => a.F_ALTA.compareTo(b.F_ALTA));
    List<String> etiquetas = generarEtiquetas(WearableList);
    
    // AGREGADO: isSpanish DENTRO del build
    final bool isSpanish = FlutterLocalization.instance.currentLocale?.languageCode == 'es';

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
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
            isSpanish ? 'Wearables del Paciente' : 'Patient Wearables',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
        endDrawer: NavBarCaregiver(),
        body: Container(
          decoration: BoxDecoration(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
            child: WearableList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.watch_off_outlined,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isSpanish ? 'No hay wearables asignados' : 'No wearables assigned',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isSpanish ? 'Este paciente no tiene wearables' : 'This patient has no wearables',
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
                    itemCount: WearableList.length,
                    itemBuilder: (context, index) {
                      return _buildWearableCard(context, index, etiquetas, isSpanish);
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildWearableCard(
    BuildContext context,
    int index,
    List<String> etiquetas,
    bool isSpanish,
  ) {
    final wearable = WearableList[index];

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PacienteCuidadorScreen(
                paciente: widget.paciente,
                wearable: wearable,
              ),
            ),
          );
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
                    colors: [colorPrimario.withOpacity(0.8), colorPrimario],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.watch, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),

              // Información del wearable
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      etiquetas[index],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.qr_code,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ID: ${wearable.IdWearable}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorPrimario.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isSpanish
                            ? wearable.TipoWeareable
                            : (wearableTypeTranslations[wearable.TipoWeareable] ??
                                wearable.TipoWeareable),
                        style: TextStyle(
                          fontSize: 11,
                          color: colorPrimario,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Flecha indicadora
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}