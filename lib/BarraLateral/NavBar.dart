// /*******************************************************************************
// Funcion que crea el menu lateral de la aplicacion para el super administrador
// *******************************************************************************/

/*class NavBar extends StatefulWidget {
  final int userId;

  const NavBar({Key? key, required this.userId}) : super(key: key);

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<NavBar> {
  List<User> user = [];
  late Future<List<User>> futureUser;

  Future<List<User>> getData() async {
    List<User> fetchedUsers = [];
    var result = await DBPostgres().DBInfoUsuario(widget.userId);
    for (var p in result) {
      fetchedUsers.add(
        User(
          p[0],
          // userId
          p[1],
          // firstName
          p[2],
          // lastName1
          p[3],
          // lastName2
          p[4].isEmpty ? null : p[4],
          // birthDate (si está vacío asignamos null)
          p[5].isEmpty ? null : p[5],
          // phone (si está vacío asignamos null)
          p[6],
          // email
          p[7],
          // password
          p[8],
          // organization
          p[9], // userType (asumimos que siempre tiene valor)
        ),
      );
    }
    return fetchedUsers;
  }

  @override
  void initState() {
    super.initState();
    futureUser = getData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<User>>(
      future: futureUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No se encontró el usuario.'));
        } else {
          User user = snapshot.data![0];

          switch (user.userType) {
            case 'Admin':
              return AdminNavBar(context);
            case 'SuperAdmin':
              return SuperAdminNavBar(context);
            case 'Cuidador':
              return CuidadorNavBar(context);
            case 'Paciente':
              return PacienteNavBar(context);
            default:
              return ErrorNavBar(context);
          }
        }
      },
    );
  }

  @override
  Widget SuperAdminNavBar(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF0716BB)),
            child: Column(
              children: [
                Text(
                  '${user[0].firstName} ${user[0].lastName1} ${user[0].lastName2}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  user[0].organization,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Gestión de Viviendas'),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ViviendasScreen(userId: widget.userId),
                  ),
                ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Gestión de Administradores'),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminitradoresScreen(),
                  ),
                ),
          ),
          ListTile(
            leading: Icon(Icons.watch),
            title: Text('Gestión de Wearables'),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TodoWearablesScreen(),
                  ),
                ),
          ),
          ListTile(
            leading: Icon(Icons.sensors),
            title: Text('Gestión de Sensores'),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TodoSensoresScreen()),
                ),
          ),
          ExpansionTile(
            leading: Icon(Icons.article),
            title: Text('Gestión de Variables'),
            children: <Widget>[
              ListTile(
                title: Text('Gestión de preguntas'),
                contentPadding: EdgeInsets.only(left: 50),
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScreenQuestions(),
                      ),
                    ),
              ),
              ListTile(
                title: Text('Variables Sanitarias'),
                contentPadding: EdgeInsets.only(left: 50),
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VariableSanitariaScreen(),
                      ),
                    ),
              ),
              ListTile(
                title: Text('Variables Sociales'),
                contentPadding: EdgeInsets.only(left: 50),
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VariableSocialScreen(),
                      ),
                    ),
              ),
              ListTile(
                title: Text('Tipo de Cuidador'),
                contentPadding: EdgeInsets.only(left: 50),
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TipoCuidadorScreen(),
                      ),
                    ),
              ),
              ListTile(
                title: Text('Tipo de Wearable'),
                contentPadding: EdgeInsets.only(left: 50),
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TipoWearableScreen(),
                      ),
                    ),
              ),
              ListTile(
                title: Text('Tipo de Sensor'),
                contentPadding: EdgeInsets.only(left: 50),
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TipoSensorScreen(),
                      ),
                    ),
              ),
              ListTile(
                title: Text('Tipo de Habitación'),
                contentPadding: EdgeInsets.only(left: 50),
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TipoHabitacionScreen(),
                      ),
                    ),
              ),
              ListTile(
                title: Text('Configurar Duracion de ADLs'),
                contentPadding: EdgeInsets.only(left: 50),
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ADLsScreen()),
                    ),
              ),
            ],
          ),
          ListTile(
            leading: Icon(Icons.groups),
            title: Text('Lista de Cuidadores'),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CuidadoresScreen()),
                ),
          ),
          ListTile(
            leading: Icon(Icons.elderly),
            title: Text('Lista de Pacientes'),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PacientesScreen()),
                ),
          ),
          ExpansionTile(
            leading: Icon(Icons.settings),
            title: Text('Configuraciones'),
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.language),
                title: Text('Idioma'),
                /*onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Selecciona idioma'),
                            content: SizedBox(
                              width: double.minPositive,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  _buildLanguageOption(
                                    context,
                                    'Español',
                                    'es',
                                  ),
                                  _buildLanguageOption(
                                    context,
                                    'Inglés',
                                    'en',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );*/
                //},
              ),
              ListTile(
                title: Text('Modificar Datos'),
                contentPadding: EdgeInsets.only(left: 50),
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ModUserAdminScreen(),
                      ),
                    ),
              ),
            ],
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Cerrar sesión'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Cerrar sesión'),
                    content: Text('¿Estás seguro de que deseas cerrar sesión?'),
                    actions: [
                      TextButton(
                        child: Text(
                          'Cancelar',
                          style: TextStyle(color: Color(0xFF0716BB)),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TextButton(
                        child: Text(
                          'Sí',
                          style: TextStyle(color: Color(0xFF0716BB)),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LogInScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget AdminNavBar(BuildContext context) {
    return FutureBuilder<void>(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF0716BB)),
                child:
                    user.isNotEmpty
                        ? Column(
                          children: [
                            Text(
                              '${user[0].firstName} ${user[0].lastName1} ${user[0].lastName2}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              user[0].organization,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                        : Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text("Gestión de Viviendas"),
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ViviendasScreen(userId: widget.userId),
                      ),
                    ),
              ),
              ListTile(
                leading: Icon(Icons.groups),
                title: Text("Lista de Cuidadores"),
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CuidadoresScreen(),
                      ),
                    ),
              ),
              ListTile(
                leading: Icon(Icons.elderly),
                title: Text("Lista de Pacientes"),
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PacientesScreen(),
                      ),
                    ),
              ),
              ExpansionTile(
                leading: Icon(Icons.settings),
                title: Text("Configuraciones"),
                children: <Widget>[
                  ListTile(
                    title: Text("Cambiar contraseña"),
                    contentPadding: EdgeInsets.only(left: 50),
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ModContrasegnaScreen(),
                          ),
                        ),
                  ),
                  ListTile(
                    leading: Icon(Icons.language),
                    title: Text("Idioma"),
                    /* onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Selecciona idioma"),
                            content: SizedBox(
                              width: double.minPositive,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  _buildLanguageOption(
                                    context,
                                    "Español",
                                    'es',
                                  ),
                                  _buildLanguageOption(context, "Inglés", 'en'),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },*/
                  ),
                  ListTile(
                    title: Text("Modificar Datos"),
                    contentPadding: EdgeInsets.only(left: 50),
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ModUserAdminScreen(),
                          ),
                        ),
                  ),
                ],
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text("Cerrar sesión"),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Cerrar sesión"),
                        content: Text(
                          "¿Estás seguro de que deseas cerrar sesión?",
                        ),
                        actions: [
                          TextButton(
                            child: Text(
                              "Cancelar",
                              style: TextStyle(color: Color(0xFF0716BB)),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          TextButton(
                            child: Text(
                              "Sí",
                              style: TextStyle(color: Color(0xFF0716BB)),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LogInScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget CuidadorNavBar(BuildContext context) {
    return FutureBuilder<void>(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF0716BB)),
                child: Column(
                  children: [
                    Text(
                      '${user[0].firstName} ${user[0].lastName1} ${user[0].lastName2}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      user[0].organization,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.elderly),
                title: Text('Patients'),
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PacientesCuidadorScreen(),
                      ),
                    ),
              ),
              ExpansionTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                children: <Widget>[
                  ListTile(
                    title: Text('Change Password'),
                    contentPadding: EdgeInsets.only(left: 50),
                    onTap:
                        () => Navigator.pushNamed(
                          context,
                          '/CambiarContrasenaPage',
                        ),
                  ),
                  ListTile(
                    title: Text('Edit Phone'),
                    contentPadding: EdgeInsets.only(left: 50),
                    onTap:
                        () => Navigator.pushNamed(
                          context,
                          '/ModificarTelefonoCuidadorPage',
                        ),
                  ),
                  ListTile(
                    leading: Icon(Icons.language),
                    title: Text('Language'),
                    /*onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('select_language',
                            ),
                            content: SizedBox(
                              width: double.minPositive,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  _buildLanguageOption(
                                    context,
                                    'Spanish',
                                    'es',
                                  ),
                                  _buildLanguageOption(
                                    context,
                                    'English',
                                    'en',
                                  ),
                                  // Agrega más opciones de idioma según necesites
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },*/
                  ),
                  // Agregar más opciones aquí
                ],
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Logout'),
                onTap: () => Navigator.pushNamed(context, '/LoginPage'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget PacienteNavBar(BuildContext context) {
    return FutureBuilder<void>(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF0716BB)),
                child: Column(
                  children: [
                    Text(
                      '${user[0].firstName} ${user[0].lastName1} ${user[0].lastName2}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      user[0].organization,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              ExpansionTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                children: <Widget>[
                  ListTile(
                    title: Text('Change Password'),
                    contentPadding: EdgeInsets.only(left: 50),
                    onTap:
                        () => Navigator.pushNamed(
                          context,
                          '/CambiarContrasenaPage',
                        ),
                  ),
                  ListTile(
                    title: Text('Edit Phone'),
                    contentPadding: EdgeInsets.only(left: 50),
                    onTap:
                        () => Navigator.pushNamed(
                          context,
                          '/ModificarTelefonoPacientePage',
                        ),
                  ),
                  ListTile(
                    leading: Icon(Icons.language),
                    title: Text('Language'),
                    /* onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // REVISA
                          return AlertDialog(
                            title: Text('select_language',
                            ),
                            content: SizedBox(
                              width: double.minPositive,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  _buildLanguageOption(
                                    context,
                                    'Spanish',
                                    'es',
                                  ),
                                  _buildLanguageOption(
                                    context,
                                    'English',
                                    'en',
                                  ),
                                  // Agrega más opciones de idioma según necesites
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },*/
                  ),
                  // Agregar más opciones aquí
                ],
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Logout'),
                onTap: () => Navigator.pushNamed(context, '/LoginPage'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget ErrorNavBar(BuildContext context) {
    getData();
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF0716BB)),
            child: Column(
              children: [
                Text(
                  '${user[0].firstName} ${user[0].lastName1} ${user[0].lastName2}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  user[0].organization,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Housing Management'),
            onTap: () => Navigator.pushNamed(context, '/GestionViviendasPage'),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Admins Management'),
            onTap:
                () =>
                    Navigator.pushNamed(context, '/GestionAdministradoresPage'),
          ),
          ListTile(
            leading: Icon(MedicalIcons.i_care_staff_area),
            title: Text('Caregivers List'),
            onTap: () => Navigator.pushNamed(context, '/GestionCuidadoresPage'),
          ),
          ListTile(
            leading: Icon(Icons.elderly),
            title: Text('Patient List'),
            onTap: () => Navigator.pushNamed(context, '/GestionPacientesPage'),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () => {},
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () => Navigator.pushNamed(context, '/LoginPage'),
          ),
        ],
      ),
    );
  }
}
*/
