import 'package:flutter/material.dart';
import '../log-in/screen_LogIn.dart';

/*Import Cuidadores */
/*Import Paciente */

class RouteGenerator {
  static Route<dynamic> GenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/LoginPage':
        return MaterialPageRoute(builder: (_) => const LogInScreen());
      /* case '/RecuperarContrasegnaPage':
        return MaterialPageRoute(
            builder: (_) => const RecuperarContrasegnaScreen());
      /*Casos Para Usuario Administrador y SuperAdministrador */
      case '/NewAdminPage':
        return MaterialPageRoute(builder: (_) => const NewAdminScreen());
      case '/NewCuidadorPage':
        return MaterialPageRoute(builder: (_) => const NewCuidadorScreen());
      case '/NewViviendaPage':
        return MaterialPageRoute(builder: (_) => const NewViviendaScreen());
      case '/GestionViviendasPage':
        return MaterialPageRoute(builder: (_) => const ViviendasScreen());
      case '/GestionCuidadoresPage':
        return MaterialPageRoute(builder: (_) => CuidadoresScreen());
      case '/GestionCuidadoresInactPage':
        return MaterialPageRoute(builder: (_) => CuidadoresInactScreen());
      case '/GestionAdministradoresPage':
        return MaterialPageRoute(builder: (_) => const AdminitradoresScreen());
      case '/GestionSensoresPage':
        return MaterialPageRoute(builder: (_) => TodoSensoresScreen());
      case '/GestionSensoresInactPage':
        return MaterialPageRoute(builder: (_) => TodoSensoresInactScreen());
      case '/GestionWearablesPage':
        return MaterialPageRoute(builder: (_) => TodoWearablesScreen());
      case '/GestionWearablesInactPage':
        return MaterialPageRoute(builder: (_) => TodoWearablesInactScreen());
      case '/GestionAdministradoresInactPage':
        return MaterialPageRoute(
            builder: (_) => const AdminitradoresInactScreen());
      case '/GestionPacientesPage':
        return MaterialPageRoute(builder: (_) => PacientesScreen());
      case '/TipoSensoresPage':
        return MaterialPageRoute(builder: (_) => TipoSensorScreen());
      case '/TipoWearablesPage':
        return MaterialPageRoute(builder: (_) => TipoWearableScreen());
      case '/VariablesSocialesPage':
        return MaterialPageRoute(builder: (_) => VariableSocialScreen());
      case '/VariablesSanitariasPage':
        return MaterialPageRoute(builder: (_) => VariableSanitariaScreen());
      case '/TipoHabitacionPage':
        return MaterialPageRoute(builder: (_) => TipoHabitacionScreen());
      case '/TipoCuidadorPage':
        return MaterialPageRoute(builder: (_) => TipoCuidadorScreen());
      case '/ADLsPage':
        return MaterialPageRoute(builder: (_) => ADLsScreen());
      case '/CambiarContrasenaPage':
        return MaterialPageRoute(builder: (_) => ModContrasegnaScreen());
      case '/ModificarDatosAdminPage':
        return MaterialPageRoute(builder: (_) => ModUserAdminScreen());
      /*Casos Para Usuaario Cuidador */
      case '/GestionPacientesCuidadorPage':
        return MaterialPageRoute(builder: (_) => PacientesCuidadorScreen());
      case '/ModificarTelefonoCuidadorPage':
        return MaterialPageRoute(builder: (_) => ModTlfnCuidadorScreen());
      /*Casos Para Usuaario Paciente */
      case '/GestionPacientePacientePage':
        return MaterialPageRoute(
            builder: (_) => WearablePacientePacienteScreen());
      // case '/GestionPacientePacientePage':
      //   return MaterialPageRoute(builder: (_) => PacientePacienteScreen());
      case '/ModificarTelefonoPacientePage':
        return MaterialPageRoute(
            builder: (_) => ModTlfnCuidadorPacienteScreen());*/
      // case '/IdiomaPageCuidador':
      //   return MaterialPageRoute(builder: (_) => IdiomaPageCuidadorScreen());
      // case '/IdiomaPagePaciente':
      //   return MaterialPageRoute(builder: (_) => IdiomaPagePacienteScreen());
      // case '/IdiomaPageSuperAdmin':
      //   return MaterialPageRoute(builder: (_) => IdiomaPageSuperAdminScreen());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('ERROR'),
            centerTitle: true,
            /*actions: [
            IconButton(onPressed: onPressed, icon: icon)
          ],*/
          ),
          body: const Center(
            child: Text(
              'No se ha encontrado la ruta deseada',
              style: TextStyle(
                fontSize: 35,
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
