// ignore_for_file: non_constant_identifier_names
//connection = await _getConnection();

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:postgres/postgres.dart';

class DBPostgres {
  PostgreSQLConnection? connection;
  PostgreSQLResult? NewAdmin;
  PostgreSQLResult? NewCuidador;
  PostgreSQLResult? NewCuidadorVivienda;
  PostgreSQLResult? NewPaciente;
  PostgreSQLResult? NewPassword;
  PostgreSQLResult? Admin;
  PostgreSQLResult? Cuidador;
  PostgreSQLResult? TodosCuidadores;
  PostgreSQLResult? CuidadorCasa;
  PostgreSQLResult? TodosWearables;
  PostgreSQLResult? Casa;
  PostgreSQLResult? Habitaciones;
  PostgreSQLResult? AlarmaParametros;
  PostgreSQLResult? Alarma;
  PostgreSQLResult? AlarmaParametrosValor;
  PostgreSQLResult? PacientesCuidador;
  PostgreSQLResult? PacienteWearable;
  PostgreSQLResult? Pacientes;
  PostgreSQLResult? Paciente;
  PostgreSQLResult? CuidadorVivienda;

  // PostgreSQLResult? CuidadorViviendaDelete;
  PostgreSQLResult? CuidadoresExistentes;
  PostgreSQLResult? PacienteVivienda;
  PostgreSQLResult? Vivienda;
  PostgreSQLResult? ViviendaInfo;
  PostgreSQLResult? NumHabitaciones;
  PostgreSQLResult? NumCuidadores;
  PostgreSQLResult? NumPacientes;
  PostgreSQLResult? Habitacion;
  PostgreSQLResult? Sensor;
  PostgreSQLResult? TodoSensor;
  PostgreSQLResult? CasaHabitacionesSensor;
  PostgreSQLResult? TodoWearable;
  PostgreSQLResult? SensorDisp;
  PostgreSQLResult? Wearable;
  PostgreSQLResult? WearableDisp;
  PostgreSQLResult? TipoSensor;
  PostgreSQLResult? TipoWearable;
  PostgreSQLResult? TipoHabitacion;
  PostgreSQLResult? TipoCuidador;

  //PostgreSQLResult? NewSensor;
  PostgreSQLResult? NewWearable;
  PostgreSQLResult? NewCasa;
  PostgreSQLResult? NewHabitacion;
  PostgreSQLResult? LogIn_Admin;
  PostgreSQLResult? InfoUsuario;
  PostgreSQLResult? LogIn_AdminInac;

  //PostgreSQLResult? ActDesActAdmin;
  PostgreSQLResult? LogIn_SuperAdmin;
  PostgreSQLResult? LogIn_Cuidador;
  PostgreSQLResult? LogIn_CuidadorInact;
  PostgreSQLResult? LogIn_Paciente;
  PostgreSQLResult? LogIn_PacienteInact;

  //var connection;
  // Conexion con PostgreSQl
  /// ***************************************************************************
  /// Funcion que crea la conexion con la base de datos
  ///**************************************************************************

  /*PC Server IMP_Tracker_prueba*/
  // DBPostgres() {
  //   connection = (connection == null || connection!.isClosed == true
  //       ? PostgreSQLConnection(
  //           // for external device like mobile phone use domain.com or
  //           // your computer machine IP address (i.e,192.168.0.1,etc)
  //           // when using AVD add this IP 10.0.2.2
  //           '212.128.71.211',
  //           5432,
  //           'IMP_Tracker_prueba',
  //           username: 'postgres',
  //           password: 'geintra_pom_2018',
  //           timeoutInSeconds: 30,
  //           queryTimeoutInSeconds: 30,
  //           timeZone: 'UTC',
  //           useSSL: false,
  //           isUnixSocket: false,
  //         )
  //       : connection);
  // }
  /*PC Server IMP_Tracker*/
  // Future<PostgreSQLConnection> _getConnection() async {
  //   if (_connection == null || _connection!.isClosed) {
  //     // Crear una lista con las posibles direcciones IP
  //     final List<String> IPs = [
  //       '192.168.72.11',
  //       '212.128.71.211',
  //     ];
  //     // final List<String> IPs = [
  //     //   '212.128.71.211',
  //     //   '192.168.72.11',
  //     // ];

  //     // Iterar por cada dirección IP hasta que se logre conectar
  //     for (var ip in IPs) {
  //       _connection = PostgreSQLConnection(
  //         ip,
  //         5432,
  //         'IMP_Tracker',
  //         username: 'postgres',
  //         password: 'geintra_pom_2018',
  //         timeoutInSeconds: 8,
  //         queryTimeoutInSeconds: 30,
  //         timeZone: 'UTC',
  //         useSSL: false,
  //         isUnixSocket: false,
  //       );
  //       try {
  //         await _connection!.open();
  //         break; // Si se logra conectar, salir del ciclo
  //       } catch (e) {
  //         print(e);
  //         _connection = null; // Si no se logra conectar, cerrar la conexión
  //       }
  //     }
  //     if (_connection == null) {
  //       throw 'No se pudo conectar a ninguna dirección IP';
  //     }
  //   }

  //   return _connection!;
  // }
  // DBPostgres() {
  //   connection = (connection == null || connection!.isClosed == true
  //       ? PostgreSQLConnection(
  //           // for external device like mobile phone use domain.com or
  //           // your computer machine IP address (i.e,192.168.0.1,etc)
  //           // when using AVD add this IP 10.0.2.2
  //           // '212.128.71.211',
  //           '192.168.72.11',
  //           5432,
  //           'IMP_Tracker',
  //           username: 'postgres',
  //           password: 'geintra_pom_2018',
  //           timeoutInSeconds: 30,
  //           queryTimeoutInSeconds: 30,
  //           timeZone: 'UTC',
  //           useSSL: false,
  //           isUnixSocket: false,
  //         )
  //       : connection);
  // }
  /* PC Albert*/
  // DBPostgres() {
  //   connection = (connection == null || connection!.isClosed == true
  //       ? PostgreSQLConnection(
  //           // for external device like mobile phone use domain.com or
  //           // your computer machine IP address (i.e,192.168.0.1,etc)
  //           // when using AVD add this IP 10.0.2.2
  //           '192.168.73.27',
  //           5432,
  //           'POM',
  //           username: 'postgres',
  //           password: 'GEINTRA',
  //           timeoutInSeconds: 30,
  //           queryTimeoutInSeconds: 30,
  //           timeZone: 'UTC',
  //           useSSL: false,
  //           isUnixSocket: false,
  //         )
  //       : connection);
  // }

  DBPostgres() {
    connection = null;
  }

  Future<void> connect() async {
    final ips = ['192.168.75.94'];
    bool connected = false;

    for (final ip in ips) {
      try {
        connection = PostgreSQLConnection(
          ip,
          5432,
          'imp_tracker',
          username: 'GEINTRA_USRF',
          password: 'admingeintra2025',
          timeoutInSeconds: 5,
          queryTimeoutInSeconds: 30,
          timeZone: 'UTC',
          useSSL: false,
          isUnixSocket: false,
        );

        await connection!.open();
        connected = true;
        break;
      } catch (e) {
        print('Error al intentar conectarse a la IP $ip: $e');
      }
    }

    if (!connected) {
      throw Exception('No se pudo establecer conexión con ninguna de las IPs');
    }
  }

  /// ***************************************************************************
  /// Funcion que crea un nuevo usuario en la base de datos.
  ///  1º abre la conexion con la base de datos
  ///  2º convierte la contraseña a un hash
  ///  3º inserta los datos en la tabla USUARIO_PRIVADO
  ///  4º devuelve true si se ha insertado correctamente y ''e si no se ha podido
  ///    insertar el usuario con exito, en la funcion de la aplicacion donde se
  ///    llama a esta funcion se evalua si el error es por un duplicado
  ///***************************************************************************
  Future DBNewAdmin(
    Name,
    Surname1,
    Surname2,
    PhoneNumber,
    Email,
    Organitation,
    Password,
  ) async {
    try {
      await connect();
      var PasswordHash = sha256.convert(utf8.encode(Password)).toString();
      // Insert en USUARIO_PRIVADO
      NewAdmin = await connection!.query(
        'with first_insert as (INSERT INTO "USUARIO_PRIVADO"'
        '("NOMBRE", "APELLIDO1", "APELLIDO2",  "TELEFONO", "MAIL", "PASSWORD", "ORGANIZACION")'
        'VALUES (@Name, @Surname1, @Surname2, @PhoneNumber, @Email, @Password, @Organitation)'
        'returning "COD_USUARIO")'
        'insert into "USUARIO_ADMINISTRADOR" ("COD_USUARIO")'
        'select first_insert."COD_USUARIO" from first_insert',
        substitutionValues: {
          'Name': Name,
          'Surname1': Surname1,
          'Surname2': Surname2,
          'PhoneNumber': PhoneNumber,
          'Email': Email,
          'Password': PasswordHash,
          'Organitation': Organitation,
        },
      );
      await connection!.close();
      return true;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que modifica usuario en la base de datos.
  ///  1º abre la conexion con la base de datos
  ///  2º convierte la contraseña a un hash
  ///  3º inserta los datos en la tabla USUARIO_PRIVADO
  ///  4º devuelve true si se ha insertado correctamente y ''e si no se ha podido
  ///    insertar el usuario con exito, en la funcion de la aplicacion donde se
  ///    llama a esta funcion se evalua si el error es por un duplicado
  ///***************************************************************************
  Future DBModAdmin(
    CodUsuario,
    Name,
    Surname1,
    Surname2,
    PhoneNumber,
    Email,
    Organitation,
  ) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      NewAdmin = await connection!.query(
        '''
      UPDATE "USUARIO_PRIVADO" 
        SET "NOMBRE"=@Name, 
        "APELLIDO1"=@Surname1, 
        "APELLIDO2"=@Surname2,
        "TELEFONO"=@PhoneNumber,
        "MAIL"=@Email,
        "ORGANIZACION"=@Organitation
        WHERE "COD_USUARIO"=@CodUsuario
  
        ''',
        substitutionValues: {
          'CodUsuario': CodUsuario,
          'Name': Name,
          'Surname1': Surname1,
          'Surname2': Surname2,
          'PhoneNumber': PhoneNumber,
          'Email': Email,
          'Organitation': Organitation,
        },
      );
      await connection!.close();
      return true;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que modifica el numero de telefono de en la base de datos.
  ///**************************************************************************
  Future DBModTlfnCuidador(CodUsuario, PhoneNumber) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      NewAdmin = await connection!.query(
        '''
      UPDATE "USUARIO_PRIVADO" 
        SET "TELEFONO"=@PhoneNumber
        WHERE "COD_USUARIO"=@CodUsuario
  
        ''',
        substitutionValues: {
          'CodUsuario': CodUsuario,
          'PhoneNumber': PhoneNumber,
        },
      );
      await connection!.close();
      return true;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// *****************************************************************************
  /// Funcion que gestiona el log in de un usuario en la base de datos.
  /// 1º abre la conexion con la base de datos
  /// 2º convierte la contraseña a un hash
  /// 3º realiza la consulta a la base de datos
  ///  3.1 Hace un JOIN entre USUARIO_PRIVADO y diferentes tipos de usuario
  ///  3.2 Comprueba que el mail y la contraseña coindecen con algun usuario
  ///  3.3 Commprueba que el usuario administrador esta ACTIVO.
  /// 4º Devuelve true si el usuario existe y false si no existe
  ///****************************************************************************
  Future<dynamic> DBLogIn(Email, Password) async {
    try {
      await connect();
      var PasswordHash = sha256.convert(utf8.encode(Password)).toString();
      LogIn_Admin = await connection!.query(
        'select'
        '"USUARIO_PRIVADO"."COD_USUARIO",'
        '"USUARIO_PRIVADO"."NOMBRE",'
        '"USUARIO_PRIVADO"."APELLIDO1",'
        '"USUARIO_PRIVADO"."APELLIDO2",'
        '"USUARIO_PRIVADO"."F_NACIMIENTO",'
        '"USUARIO_PRIVADO"."TELEFONO",'
        '"USUARIO_PRIVADO"."MAIL",'
        '"USUARIO_PRIVADO"."PASSWORD",'
        '"USUARIO_PRIVADO"."ORGANIZACION",'
        '"USUARIO_PRIVADO"."F_ALTA",'
        '"USUARIO_PRIVADO"."F_BAJA"'
        'from'
        '"USUARIO_PRIVADO"'
        'inner join "USUARIO_ADMINISTRADOR" on'
        '"USUARIO_PRIVADO"."COD_USUARIO" = "USUARIO_ADMINISTRADOR"."COD_USUARIO"'
        'where "MAIL" = @Email AND "PASSWORD" = @Password and "USUARIO_PRIVADO"."F_BAJA" is null',
        substitutionValues: {'Email': Email, 'Password': PasswordHash},
      );
      LogIn_AdminInac = await connection!.query(
        'select'
        '"USUARIO_PRIVADO"."COD_USUARIO",'
        '"USUARIO_PRIVADO"."NOMBRE",'
        '"USUARIO_PRIVADO"."APELLIDO1",'
        '"USUARIO_PRIVADO"."APELLIDO2",'
        '"USUARIO_PRIVADO"."F_NACIMIENTO",'
        '"USUARIO_PRIVADO"."TELEFONO",'
        '"USUARIO_PRIVADO"."MAIL",'
        '"USUARIO_PRIVADO"."PASSWORD",'
        '"USUARIO_PRIVADO"."ORGANIZACION",'
        '"USUARIO_PRIVADO"."F_ALTA",'
        '"USUARIO_PRIVADO"."F_BAJA"'
        'from'
        '"USUARIO_PRIVADO"'
        'inner join "USUARIO_ADMINISTRADOR" on'
        '"USUARIO_PRIVADO"."COD_USUARIO" = "USUARIO_ADMINISTRADOR"."COD_USUARIO"'
        'where "MAIL" = @Email AND "PASSWORD" = @Password and "USUARIO_PRIVADO"."F_BAJA" is not null',
        substitutionValues: {'Email': Email, 'Password': PasswordHash},
      );
      LogIn_SuperAdmin = await connection!.query(
        'select'
        '    "USUARIO_PRIVADO"."COD_USUARIO",'
        '    "USUARIO_PRIVADO"."NOMBRE",'
        '    "USUARIO_PRIVADO"."APELLIDO1",'
        '    "USUARIO_PRIVADO"."APELLIDO2",'
        '    "USUARIO_PRIVADO"."F_NACIMIENTO",'
        '    "USUARIO_PRIVADO"."TELEFONO",'
        '    "USUARIO_PRIVADO"."MAIL",'
        '    "USUARIO_PRIVADO"."PASSWORD",'
        '    "USUARIO_PRIVADO"."ORGANIZACION",'
        '    "USUARIO_PRIVADO"."F_ALTA",'
        '    "USUARIO_PRIVADO"."F_BAJA"'
        'from'
        '    "USUARIO_SUPERADMINISTRADOR"'
        'inner join "USUARIO_PRIVADO" on'
        '    "USUARIO_SUPERADMINISTRADOR"."COD_USUARIO" = "USUARIO_PRIVADO"."COD_USUARIO"'
        '	where "MAIL" = @Email AND "PASSWORD" = @Password and "USUARIO_PRIVADO"."F_BAJA" is null',
        substitutionValues: {'Email': Email, 'Password': PasswordHash},
      );
      LogIn_Cuidador = await connection!.query(
        '''select
            "USUARIO_PRIVADO"."COD_USUARIO",
            "USUARIO_PRIVADO"."NOMBRE",
            "USUARIO_PRIVADO"."APELLIDO1",
            "USUARIO_PRIVADO"."APELLIDO2",
            "USUARIO_PRIVADO"."F_NACIMIENTO",
            "USUARIO_PRIVADO"."TELEFONO",
            "USUARIO_PRIVADO"."MAIL",
            "USUARIO_PRIVADO"."PASSWORD",
            "USUARIO_PRIVADO"."ORGANIZACION",
            "USUARIO_PRIVADO"."F_ALTA",
            "USUARIO_PRIVADO"."F_BAJA"
            
        from
            "USUARIO_CUIDADOR"
        inner join "USUARIO_PRIVADO" on
            "USUARIO_CUIDADOR"."COD_USUARIO" = "USUARIO_PRIVADO"."COD_USUARIO"
        	where "MAIL" = @Email AND "PASSWORD" = @Password and "USUARIO_PRIVADO"."F_BAJA" is null''',
        substitutionValues: {
          'Email': Email,
          'Password': PasswordHash,
          'STATUS': 'ACTIVO',
        },
      );
      LogIn_CuidadorInact = await connection!.query(
        '''
        select
            "USUARIO_PRIVADO"."COD_USUARIO",
            "USUARIO_PRIVADO"."NOMBRE",
            "USUARIO_PRIVADO"."APELLIDO1",
            "USUARIO_PRIVADO"."APELLIDO2",
            "USUARIO_PRIVADO"."F_NACIMIENTO",
            "USUARIO_PRIVADO"."TELEFONO",
            "USUARIO_PRIVADO"."MAIL",
            "USUARIO_PRIVADO"."PASSWORD",
            "USUARIO_PRIVADO"."ORGANIZACION",
            "USUARIO_PRIVADO"."F_ALTA",
            "USUARIO_PRIVADO"."F_BAJA"
        from
            "USUARIO_CUIDADOR"
        inner join "USUARIO_PRIVADO" on
            "USUARIO_CUIDADOR"."COD_USUARIO" = "USUARIO_PRIVADO"."COD_USUARIO"
        	where "MAIL" = @Email AND "PASSWORD" = @Password and "USUARIO_PRIVADO"."F_BAJA" is not null''',
        substitutionValues: {
          'Email': Email,
          'Password': PasswordHash,
          'STATUS': 'INACTIVO',
        },
      );
      LogIn_PacienteInact = await connection!.query(
        '''
        select
            "USUARIO_PRIVADO"."COD_USUARIO",
            "USUARIO_PRIVADO"."NOMBRE",
            "USUARIO_PRIVADO"."APELLIDO1",
            "USUARIO_PRIVADO"."APELLIDO2",
            "USUARIO_PRIVADO"."F_NACIMIENTO",
            "USUARIO_PRIVADO"."TELEFONO",
            "USUARIO_PRIVADO"."MAIL",
            "USUARIO_PRIVADO"."PASSWORD",
            "USUARIO_PRIVADO"."ORGANIZACION",
            "USUARIO_PRIVADO"."F_ALTA",
            "USUARIO_PRIVADO"."F_BAJA"
        from
            "USUARIO_PRIVADO"
        inner join public."USUARIO_PACIENTE" on
            "USUARIO_PRIVADO"."COD_USUARIO" = public."USUARIO_PACIENTE"."COD_USUARIO"
        	where "MAIL" = @Email AND "PASSWORD" = @Password and "USUARIO_PRIVADO"."F_BAJA" is not null''',
        substitutionValues: {
          'Email': Email,
          'Password': PasswordHash,
          'STATUS': 'INACTIVO',
        },
      );
      LogIn_Paciente = await connection!.query(
        '''
        select
            "USUARIO_PRIVADO"."COD_USUARIO",
            "USUARIO_PRIVADO"."NOMBRE",
            "USUARIO_PRIVADO"."APELLIDO1",
            "USUARIO_PRIVADO"."APELLIDO2",
            "USUARIO_PRIVADO"."F_NACIMIENTO",
            "USUARIO_PRIVADO"."TELEFONO",
            "USUARIO_PRIVADO"."MAIL",
            "USUARIO_PRIVADO"."PASSWORD",
            "USUARIO_PRIVADO"."ORGANIZACION",
            "USUARIO_PRIVADO"."F_ALTA",
            "USUARIO_PRIVADO"."F_BAJA"
        from
            "USUARIO_PRIVADO"
        inner join public."USUARIO_PACIENTE" on
            "USUARIO_PRIVADO"."COD_USUARIO" = public."USUARIO_PACIENTE"."COD_USUARIO"
        	where "MAIL" = @Email AND "PASSWORD" = @Password and "USUARIO_PRIVADO"."F_BAJA" is null''',
        substitutionValues: {
          'Email': Email,
          'Password': PasswordHash,
          'STATUS': 'INACTIVO',
        },
      );
      print('object');

      await connection!.close();
      if (LogIn_Admin!.isEmpty == false) {
        String UserType = 'Admin';
        return [UserType, LogIn_Admin];
      } else if (LogIn_AdminInac!.isEmpty == false) {
        String UserType = 'AdminInac';
        return [UserType, LogIn_AdminInac];
      } else if (LogIn_SuperAdmin!.isEmpty == false) {
        String UserType = 'SuperAdmin';
        return [UserType, LogIn_SuperAdmin];
      } else if (LogIn_Cuidador!.isEmpty == false) {
        String UserType = 'Cuidador';
        return [UserType, LogIn_Cuidador];
      } else if (LogIn_CuidadorInact!.isEmpty == false) {
        String UserType = 'CuidadorInact';
        return [UserType, LogIn_CuidadorInact];
      } else if (LogIn_Paciente!.isEmpty == false) {
        String UserType = 'Paciente';
        return [UserType, LogIn_Paciente];
      } else {
        return ['No se ha encontrado el usuario', []];
      }
      /*Insert en USUARIO_PRIVADO*/
    } catch (e) {
      await connection!.close();
      return ['error', []];
    }
  }

  /// ***************************************************************************
  /// Funcion que cambia la contraseña de un usuario
  ///***************************************************************************
  Future<String> DBNewPassword(Email, Password) async {
    try {
      await connect();
      var PasswordHash = sha256.convert(utf8.encode(Password)).toString();
      // Insert en USUARIO_PRIVADO
      NewPassword = await connection!.query(
        'UPDATE public."USUARIO_PRIVADO"'
        '	SET "PASSWORD"= @Password'
        '	WHERE "MAIL" = @Email',
        substitutionValues: {'Email': Email, 'Password': PasswordHash},
      );
      await connection!.close();
      if (NewPassword!.affectedRowCount != 0) {
        return 'correcto';
      } else {
        return 'incorrecto';
      }
    } catch (e) {
      await connection!.close();
      return 'error';
    }
  }

  /// ***************************************************************************
  /// Funcion que cambia la contraseña de un usuario al deseado
  ///***************************************************************************
  Future<String> DBModPassword(Email, Password) async {
    try {
      await connect();
      var PasswordHash = sha256.convert(utf8.encode(Password)).toString();
      // Insert en USUARIO_PRIVADO
      NewPassword = await connection!.query(
        'UPDATE public."USUARIO_PRIVADO"'
        '	SET "PASSWORD"= @Password'
        '	WHERE "MAIL" = @Email',
        substitutionValues: {'Email': Email, 'Password': PasswordHash},
      );
      await connection!.close();
      if (NewPassword!.affectedRowCount != 0) {
        return 'correcto';
      } else {
        return 'incorrecto';
      }
    } catch (e) {
      await connection!.close();
      return 'error';
    }
  }

  /// ***************************************************************************
  /// Funcion que devuelve los usuarios Administradores
  ///***************************************************************************
  Future<List> DBGetAdmin() async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      Admin = await connection!.query(
        'select'
        '    "USUARIO_PRIVADO"."COD_USUARIO",'
        '    "USUARIO_PRIVADO"."NOMBRE",'
        '    "USUARIO_PRIVADO"."APELLIDO1",'
        '    "USUARIO_PRIVADO"."APELLIDO2",'
        '    "USUARIO_PRIVADO"."F_NACIMIENTO",'
        '    "USUARIO_PRIVADO"."TELEFONO",'
        '    "USUARIO_PRIVADO"."MAIL",'
        '    "USUARIO_PRIVADO"."ORGANIZACION",'
        '    "USUARIO_PRIVADO"."F_ALTA",'
        '    "USUARIO_PRIVADO"."F_BAJA"'
        'from'
        '	"USUARIO_ADMINISTRADOR"'
        'inner join "USUARIO_PRIVADO" on'
        '	"USUARIO_ADMINISTRADOR"."COD_USUARIO" = "USUARIO_PRIVADO"."COD_USUARIO"',
      );
      print(Admin);
      await connection!.close();
      return Admin!;
    } catch (e) {
      await connection!.close();
      return [];
    }
  }

  /// ***************************************************************************
  /// Funcion que devuelve los usuarios Administradores
  ///***************************************************************************
  Future<List> DBInfoUsuario(COD_USUARIO) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      InfoUsuario = await connection!.query(
        'select'
        '    "USUARIO_PRIVADO"."COD_USUARIO",'
        '    "USUARIO_PRIVADO"."NOMBRE",'
        '    "USUARIO_PRIVADO"."APELLIDO1",'
        '    "USUARIO_PRIVADO"."APELLIDO2",'
        '    "USUARIO_PRIVADO"."F_NACIMIENTO",'
        '    "USUARIO_PRIVADO"."TELEFONO",'
        '    "USUARIO_PRIVADO"."MAIL",'
        '    "USUARIO_PRIVADO"."PASSWORD",'
        '    "USUARIO_PRIVADO"."ORGANIZACION"'
        'from'
        '	"USUARIO_PRIVADO"'
        'where'
        '	"USUARIO_PRIVADO"."COD_USUARIO" = @COD_USUARIO',
        substitutionValues: {'COD_USUARIO': COD_USUARIO},
      );
      print(InfoUsuario);
      await connection!.close();
      return InfoUsuario!;
    } catch (e) {
      print('Error al acceder a la base de datos: $e');
      print('no se pudo acceder');
      await connection!.close();
      return [];
    }
  }

  /// ***************************************************************************
  /// Funcion que Activar o Desactivar un usuario Administrador
  ///***************************************************************************
  Future<String> DBActDesActAdmin(COD_USUARIO, F_BAJA) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      var Update = '''
          UPDATE "USUARIO_PRIVADO" SET "F_BAJA" = 
              CASE 
                WHEN @F_BAJA IS NULL THEN NULL 
                WHEN @F_BAJA = 'CURRENT_TIMESTAMP' THEN CURRENT_TIMESTAMP 
                
              END 
          WHERE "COD_USUARIO" = @COD_USUARIO
          ''';
      var ActDesActAdmin = await connection!.execute(
        Update,
        substitutionValues: {"COD_USUARIO": COD_USUARIO, "F_BAJA": F_BAJA},
      );
      await connection!.close();
      if (ActDesActAdmin != 0) {
        return 'Correcto';
      } else {
        return 'incorrecto';
      }
    } catch (e) {
      await connection!.close();
      return 'error';
    }
  }

  /*****************************************************************************
   * Funcion que inserta vivienda en la tabla CASA
      1º abre la conexion
      2º inserta los datos en la tabla CASA
      3º devuelve el COD_CASA que se utilizara en el resto de la aplicacion
   *****************************************************************************/
  Future DBNewCasa(
    DIRECCION,
    NUMERO,
    PISO,
    PUERTA,
    COD_POSTAL,
    LOCALIDAD,
    PROVINCIA,
    PAIS,
    NUM_PLANTAS,
    LATITUD,
    LONGITUD,
  ) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      NewCasa = await connection!.query(
        'INSERT INTO "CASA"('
        '	"DIRECCION", "COD_POSTAL", "LOCALIDAD", "PROVINCIA", "NUM_PLANTAS", "PAIS", "NUMERO", "PISO", "PUERTA", "LATITUD", "LONGITUD")'
        '	VALUES (@DIRECCION, @COD_POSTAL, @LOCALIDAD, @PROVINCIA, @NUM_PLANTAS, @PAIS, @NUMERO, @PISO, @PUERTA, @LATITUD, @LONGITUD)'
        '	returning "COD_CASA"',
        substitutionValues: {
          'DIRECCION': DIRECCION,
          'COD_POSTAL': COD_POSTAL,
          'LOCALIDAD': LOCALIDAD,
          'PROVINCIA': PROVINCIA,
          'NUM_PLANTAS': NUM_PLANTAS,
          'PAIS': PAIS,
          'NUMERO': NUMERO,
          'PISO': PISO,
          'PUERTA': PUERTA,
          'LATITUD': LATITUD,
          'LONGITUD': LONGITUD,
        },
      );
      await connection!.close();
      return 'Se ha insertado correctamente'; // Devuelve el COD_CASA insertado
    } catch (e) {
      await connection!.close();
      if (e.toString().contains('Ya existe la llave')) {
        return 'duplicate';
      } else {
        return 'error';
      }
    }
  }

  /// *************************************************************************
  /// Funcion que Modifica la Casa
  ///*************************************************************************
  Future DBModCasa(
    COD_CASA,
    DIRECCION,
    NUMERO,
    PISO,
    PUERTA,
    COD_POSTAL,
    LOCALIDAD,
    PROVINCIA,
    PAIS,
    NUM_PLANTAS,
    LATITUD,
    LONGITUD,
  ) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      NewCasa = await connection!.query(
        '''
        UPDATE "CASA"
        SET "DIRECCION"=@DIRECCION, 
        "COD_POSTAL"=@COD_POSTAL, 
        "LOCALIDAD"=@LOCALIDAD, 
        "PROVINCIA"=@PROVINCIA, 
        "NUM_PLANTAS"=@NUM_PLANTAS, 
        "PAIS"=@PAIS, 
        "NUMERO"=@NUMERO, 
        "PISO"=@PISO, 
        "PUERTA"=@PUERTA,
        "LATITUD"=@LATITUD,
        "LONGITUD"=@LONGITUD
        WHERE "COD_CASA"=@COD_CASA;''',
        substitutionValues: {
          'COD_CASA': COD_CASA,
          'DIRECCION': DIRECCION,
          'COD_POSTAL': COD_POSTAL,
          'LOCALIDAD': LOCALIDAD,
          'PROVINCIA': PROVINCIA,
          'NUM_PLANTAS': NUM_PLANTAS,
          'PAIS': PAIS,
          'NUMERO': NUMERO,
          'PISO': PISO,
          'PUERTA': PUERTA,
          'LATITUD': LATITUD,
          'LONGITUD': LONGITUD,
        },
      );
      await connection!.close();
      return 'Se ha modificado correctamente'; // Devuelve el COD_CASA insertado
    } catch (e) {
      await connection!.close();
      if (e.toString().contains('Ya existe la llave')) {
        return 'duplicate';
      } else {
        return 'error';
      }
    }
  }

  /// ***************************************************************************
  /// Funcion que devuelve las Vivendas
  ///***************************************************************************
  Future<List> DBGetVivienda(F_BAJA) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      Vivienda = await connection!.query(
        '''
            SELECT
              "COD_CASA", 
              "DIRECCION", 
              "NUMERO",
              "PISO", 
              "PUERTA",
              "COD_POSTAL", 
              "LOCALIDAD", 
              "PROVINCIA",
              "PAIS", 
              "NUM_PLANTAS", 
              "F_ALTA", 
              "F_BAJA", 
              "LONGITUD", 
              "LATITUD"
              FROM "CASA" 
            where "CASA"."F_BAJA" IS ''' +
            F_BAJA +
            ''';
            ''',
      );
      await connection!.close();
      print(Vivienda);
      return Vivienda!;
    } catch (e) {
      await connection!.close();
      return [];
    }
  }

  /// ***************************************************************************
  /// Funcion que devuelve numero de Habitaciones de una vivienda
  ///***************************************************************************
  Future DBGetNumHabitaciones(COD_CASA) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      NumHabitaciones = await connection!.query(
        '''
          SELECT COUNT(*) FROM "HABITACION" WHERE "COD_CASA" = @COD_CASA and "F_BAJA" is null''',
        substitutionValues: {'COD_CASA': COD_CASA},
      );
      await connection!.close();
      print(NumHabitaciones);
      return NumHabitaciones!.first.first;
    } catch (e) {
      await connection!.close();
      return [];
    }
  }

  /// ***************************************************************************
  /// Funcion que devuelve numero de Cuidadores de una vivienda
  ///***************************************************************************
  Future DBGetNumCuidadores(COD_CASA) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      NumCuidadores = await connection!.query(
        '''
          SELECT COUNT(*) FROM "CUIDADOR_CASA" WHERE "COD_CASA" = @COD_CASA and "F_BAJA" is null''',
        substitutionValues: {'COD_CASA': COD_CASA},
      );
      print(NumCuidadores);
      await connection!.close();
      return NumCuidadores!.first.first;
    } catch (e) {
      await connection!.close();
      return [];
    }
  }

  /// ***************************************************************************
  /// Funcion que devuelve numero de Pacientes de una vivienda
  ///***************************************************************************
  Future DBGetNumPacientes(COD_CASA) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      NumPacientes = await connection!.query(
        '''
          SELECT COUNT(*) FROM "PACIENTE_CASA" WHERE "COD_CASA" = @COD_CASA and "F_BAJA" is null''',
        substitutionValues: {'COD_CASA': COD_CASA},
      );
      print(NumPacientes);
      await connection!.close();
      return NumPacientes!.first.first;
    } catch (e) {
      await connection!.close();
      return [];
    }
  }

  /// ***************************************************************************
  /// Funcion que devuelve numero de Pacientes de una vivienda
  ///***************************************************************************
  Future DBGetNumSensoresVivienda(COD_CASA) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      NumPacientes = await connection!.query(
        '''
          select COUNT(*)
            from
                "CASA"
            inner join "HABITACION" on
                "CASA"."COD_CASA" = "HABITACION"."COD_CASA"
            inner join "HABITACION_SENSOR" on
                "HABITACION"."COD_HABITACION" = "HABITACION_SENSOR"."COD_HABITACION"
            where "CASA"."COD_CASA" = @COD_CASA and "HABITACION_SENSOR"."F_BAJA" is null''',
        substitutionValues: {'COD_CASA': COD_CASA},
      );
      print(NumPacientes);
      await connection!.close();
      return NumPacientes!.first.first;
    } catch (e) {
      await connection!.close();
      return [];
    }
  }

  /// ***************************************************************************
  /// Funcion que devuelve las Habitaciones de una vivienda
  ///***************************************************************************
  Future<List> DBGetHabitacion(COD_CASA, F_BAJA) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      Habitacion = await connection!.query(
        'SELECT'
                '    "HABITACION"."COD_HABITACION", '
                '    "HABITACION"."COD_CASA", '
                '    "HABITACION"."N_PLANTA", '
                '    "HABITACION"."F_ALTA",'
                '    "HABITACION"."F_BAJA",'
                '    "HABITACION"."OBSERVACIONES",'
                '    "TIPO_HABITACION"."TIPO_HABITACION",'
                '    "TIPO_HABITACION"."COD_TIPO_HABITACION"'
                '	FROM "HABITACION"'
                ' inner join "TIPO_HABITACION" on'
                '    "HABITACION"."COD_TIPO_HABITACION" = "TIPO_HABITACION"."COD_TIPO_HABITACION"'
                ' WHERE "HABITACION"."COD_CASA" = @COD_CASA and "HABITACION"."F_BAJA" is' +
            F_BAJA,
        substitutionValues: {'COD_CASA': COD_CASA},
      );
      print(Habitacion);
      await connection!.close();
      return Habitacion!;
    } catch (e) {
      await connection!.close();
      return [];
    }
  }

  /*****************************************************************************
      Funcion que inserta habitaciones en la tabla HABITACION de la casa
      correspondiente.
      1º abre la conexion
      2º inserta en la tabla HABITACION
      3º devuelve el COD_HABITACION insertado
   *****************************************************************************/
  Future DBNewHabitacion(
    COD_CASA,
    COD_TIPO_HABITACION,
    N_PLANTA,
    OBSERVACIONES,
  ) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      Habitacion = await connection!.query(
        'INSERT INTO "HABITACION"'
        '("COD_CASA", "COD_TIPO_HABITACION", "N_PLANTA", "OBSERVACIONES")'
        'VALUES(@COD_CASA, @COD_TIPO_HABITACION, @N_PLANTA, @OBSERVACIONES)'
        'returning "COD_HABITACION"',
        substitutionValues: {
          'COD_CASA': COD_CASA,
          'COD_TIPO_HABITACION': COD_TIPO_HABITACION,
          'N_PLANTA': N_PLANTA,
          'OBSERVACIONES': OBSERVACIONES,
        },
      );
      await connection!.close();
      return Habitacion!.first.first; // Devuelve el COD_CASA insertado
    } catch (e) {
      await connection!.close();
      return [];
    }
  }

  /// ***************************************************************************
  /// Funcion que devuelve los Sensores de una Habitacion
  ///***************************************************************************
  Future<List> DBGetSensor(COD_HABITACION) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      Sensor = await connection!.query(
        '''select
            "SENSOR"."COD_SENSOR",      
             "SENSOR"."ID_SENSOR",
             "HABITACION_SENSOR"."COD_HABITACION",
             "SENSOR"."EMISOR_RECEPTOR",
             "HABITACION_SENSOR"."F_ALTA",
             "HABITACION_SENSOR"."F_BAJA",
             "TIPO_SENSOR"."TIPO_SENSOR",
             "TIPO_SENSOR"."COD_TIPO_SENSOR",
             "SENSOR"."DES_OTROS"
            from
                "HABITACION_SENSOR"
            inner join "SENSOR" on
                "HABITACION_SENSOR"."COD_SENSOR" = "SENSOR"."COD_SENSOR"
            inner join "TIPO_SENSOR" on
                "SENSOR"."COD_TIPO_SENSOR" = "TIPO_SENSOR"."COD_TIPO_SENSOR"
            where "HABITACION_SENSOR"."COD_HABITACION" = @COD_HABITACION and "HABITACION_SENSOR"."F_BAJA" is null and "SENSOR"."F_BAJA" is null''',
        substitutionValues: {'COD_HABITACION': COD_HABITACION},
      );
      await connection!.close();
      print(Sensor);
      return Sensor!;
    } catch (e) {
      return [];
    }
  }

  /// ***************************************************************************
  /// Funcion que devuelve todas las preguntas, sin repertirse y con la ultima
  /// fecha de alta
  ///***************************************************************************

  Future DBGetQuestions() async {
    try {
      await connect();
      final questions = await connection!.query('''
      SELECT 
        "COD_PREGUNTA", 
        "DES_PREGUNTA", 
        "F_ALTA", 
        "F_BAJA"
      FROM "PREGUNTA"
      WHERE "F_BAJA" IS NULL
      ORDER BY "COD_PREGUNTA";
      ''');
      await connection!.close();
      print(questions);
      return questions;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que agrega preguntas a la base de datos con fecha de alta
  ///***************************************************************************

  Future<void> DBAddQuestion(String desPregunta) async {
    try {
      await connect();
      await connection!.query(
        '''
      INSERT INTO "PREGUNTA" ("DES_PREGUNTA", "F_ALTA") 
      VALUES (@DES_PREGUNTA, NOW());
    ''',
        substitutionValues: {'DES_PREGUNTA': desPregunta},
      );
      await connection!.close();
    } catch (e) {
      await connection!.close();
      rethrow;
    }
  }

  /// ***************************************************************************
  /// Funcion que devuelve todos los Sensores, sin repertirse y con la ultima
  /// fecha de baja,
  ///***************************************************************************

  Future DBGetInactiveQuestions() async {
    try {
      await connect();
      final questions = await connection!.query('''
      SELECT 
        "COD_PREGUNTA", 
        "DES_PREGUNTA", 
        "F_ALTA", 
        "F_BAJA"
      FROM "PREGUNTA"
      WHERE "F_BAJA" IS NOT NULL 
      ORDER BY "COD_PREGUNTA";
    ''');

      print("Fetched Questions: $questions");

      await connection!.close();
      return questions;
    } catch (e) {
      print('Error: $e');
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que da de baja una pregunta
  ///***************************************************************************

  Future<void> DBDeactivateQuestion(int codPregunta) async {
    try {
      await connect();
      await connection!.query(
        '''
      UPDATE "PREGUNTA"
      SET "F_BAJA" = NOW()
      WHERE "COD_PREGUNTA" = @COD_PREGUNTA;
    ''',
        substitutionValues: {'COD_PREGUNTA': codPregunta},
      );
      await connection!.close();
    } catch (e) {
      await connection!.close();
      print("Error al desactivar pregunta: $e");
    }
  }

  /// ***************************************************************************
  /// Funcion que da de alta una pregunta
  ///***************************************************************************

  Future<void> DBActivateQuestion(int codPregunta) async {
    try {
      await connect();
      await connection!.query(
        '''
      UPDATE "PREGUNTA"
      SET "F_BAJA" = NULL
      WHERE "COD_PREGUNTA" = @COD_PREGUNTA;
      ''',
        substitutionValues: {'COD_PREGUNTA': codPregunta},
      );
      await connection!.close();
    } catch (e) {
      await connection!.close();
      print("Error al activar pregunta: $e");
    }
  }

  /// ***************************************************************************
  /// Funcion que actualiza la pregunta
  ///***************************************************************************
  Future<void> DBUpdateQuestionDescription(
    int codPregunta,
    String nuevaDescripcion,
  ) async {
    try {
      await connect();
      await connection!.query(
        '''
      UPDATE "PREGUNTA"
      SET "DES_PREGUNTA" = @nuevaDescripcion
      WHERE "COD_PREGUNTA" = @COD_PREGUNTA;
      ''',
        substitutionValues: {
          'COD_PREGUNTA': codPregunta,
          'nuevaDescripcion': nuevaDescripcion,
        },
      );
      await connection!.close();
    } catch (e) {
      await connection!.close();
      print("Error al actualizar la descripción de la pregunta: $e");
    }
  }

  /// ***************************************************************************
  /// Funcion que retorna las preguntas del paciente al asignarlas por dia de la semana
  ///***************************************************************************

  Future<List> DBGetQuestionsByAssignment({
    required int patientId,
    required int weekDay,
  }) async {
    try {
      await connect();

      final result = await connection!.query(
        '''
      SELECT p."COD_PREGUNTA", p."DES_PREGUNTA", p."F_ALTA", p."F_BAJA"
      FROM "PREGUNTA" p
      JOIN "PREGUNTA_PACIENTE" pp ON p."COD_PREGUNTA" = pp."COD_PREGUNTA"
      JOIN "PREGUNTA_PACIENTE_DIA" ppd ON pp."COD_PREGUNTA_PACIENTE" = ppd."COD_PREGUNTA_PACIENTE"
      WHERE pp."COD_USUARIO" = @COD_USUARIO
        AND (ppd."COD_DIA_SEMANA" = @DIA_SEMANA OR ppd."COD_DIA_SEMANA" = 8)
        AND p."F_BAJA" IS NULL
        AND pp."F_BAJA" IS NULL
    ''',
        substitutionValues: {'COD_USUARIO': patientId, 'DIA_SEMANA': weekDay},
      );

      await connection!.close();
      return result;
    } catch (e) {
      await connection?.close();
      print("Error al obtener preguntas por fecha: $e");
      return [];
    }
  }

  /// ***************************************************************************
  /// Funcion que retorna las preguntas del paciente segun el dia de asignacion
  ///***************************************************************************

  Future<List> DBGetQuestionsByPatientAndDate({
    required int patientId,
    required int weekDay,
  }) async {
    try {
      await connect();

      final result = await connection!.query(
        '''
      SELECT p."COD_PREGUNTA", p."DES_PREGUNTA", p."F_ALTA", p."F_BAJA"
      FROM "PREGUNTA" p
      JOIN "PREGUNTA_PACIENTE" pp ON p."COD_PREGUNTA" = pp."COD_PREGUNTA"
      JOIN "PREGUNTA_PACIENTE_DIA" ppd ON pp."COD_PREGUNTA_PACIENTE" = ppd."COD_PREGUNTA_PACIENTE"
      WHERE pp."COD_USUARIO" = @COD_USUARIO
        AND (ppd."COD_DIA_SEMANA" = @DIA_SEMANA OR ppd."COD_DIA_SEMANA" = 8)
        AND p."F_BAJA" IS NULL
        AND pp."F_BAJA" IS NULL
    ''',
        substitutionValues: {'COD_USUARIO': patientId, 'DIA_SEMANA': weekDay},
      );

      await connection!.close();
      return result;
    } catch (e) {
      await connection?.close();
      print("Error al obtener preguntas por fecha: $e");
      return [];
    }
  }

  Future<bool> hayPreguntasDisponiblesYEsHora(int pacienteId) async {
    try {
      final now = DateTime.now();
      final esHora = now.hour >= 13; // después de la 1:00 PM

      if (!esHora) return false;
      final int weekDay = now.weekday;

      final result = await connection!.query(
        '''
      SELECT p."COD_PREGUNTA", p."DES_PREGUNTA", p."F_ALTA", p."F_BAJA"
      FROM "PREGUNTA" p
      JOIN "PREGUNTA_PACIENTE" pp ON p."COD_PREGUNTA" = pp."COD_PREGUNTA"
      JOIN "PREGUNTA_PACIENTE_DIA" ppd ON pp."COD_PREGUNTA_PACIENTE" = ppd."COD_PREGUNTA_PACIENTE"
      WHERE pp."COD_USUARIO" = @COD_USUARIO
        AND (ppd."COD_DIA_SEMANA" = @DIA_SEMANA OR ppd."COD_DIA_SEMANA" = 8)
        AND p."F_BAJA" IS NULL
        AND pp."F_BAJA" IS NULL
      ''',
        substitutionValues: {'COD_USUARIO': pacienteId, 'DIA_SEMANA': weekDay},
      );

      await connection?.close();
      return result.isNotEmpty;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  /// ***************************************************************************
  /// Funcion para dar de baja una pregunta al paciente segun el dia
  ///***************************************************************************

  Future<bool> dbDeactivateQuestionForDay({
    required int codUsuario,
    required int codPregunta,
    required int diaSemana,
  }) async {
    try {
      await connect();

      final result = await connection!.query(
        '''
      SELECT "COD_PREGUNTA_PACIENTE"
      FROM "PREGUNTA_PACIENTE"
      WHERE "COD_USUARIO" = @codUsuario AND "COD_PREGUNTA" = @codPregunta AND "F_BAJA" IS NULL
      ''',
        substitutionValues: {
          'codUsuario': codUsuario,
          'codPregunta': codPregunta,
        },
      );

      if (result.isEmpty) {
        throw Exception('No se encontró la pregunta asignada al usuario.');
      }

      final codPreguntaPaciente = result.first[0];

      await connection!.query(
        '''
      DELETE FROM "PREGUNTA_PACIENTE_DIA"
      WHERE "COD_PREGUNTA_PACIENTE" = @cpp AND "COD_DIA_SEMANA" = @dia
      ''',
        substitutionValues: {'cpp': codPreguntaPaciente, 'dia': diaSemana},
      );

      print('Pregunta desactivada para el día $diaSemana');
      await connection!.close();
      return true;
    } catch (e) {
      print('Error al desactivar la pregunta para el día: $e');
      await connection!.close();
      return false;
    }
  }

  /// ***************************************************************************
  /// Funcion que sube a postgreSQl la pregunta asignada al paciente segun el dia
  ///***************************************************************************

  Future dbAssignQuestionPatient({
    required int codUsuario,
    required int codPregunta,
    required List<int> diasSeleccionados,
  }) async {
    try {
      await connect();
      final result = await connection!.query(
        '''
      INSERT INTO "PREGUNTA_PACIENTE" ("COD_USUARIO", "COD_PREGUNTA")
      VALUES (@codUsuario, @codPregunta)
      ON CONFLICT ("COD_USUARIO", "COD_PREGUNTA")
      DO UPDATE SET "F_BAJA" = NULL
      RETURNING "COD_PREGUNTA_PACIENTE";
    ''',
        substitutionValues: {
          'codUsuario': codUsuario,
          'codPregunta': codPregunta,
        },
      );

      final codPreguntaPaciente = result.first[0];

      for (final dia in diasSeleccionados) {
        await connection!.query(
          '''
        INSERT INTO "PREGUNTA_PACIENTE_DIA" ("COD_PREGUNTA_PACIENTE", "COD_DIA_SEMANA")
        VALUES (@cpp, @dia)
        ON CONFLICT DO NOTHING;
      ''',
          substitutionValues: {'cpp': codPreguntaPaciente, 'dia': dia},
        );
      }

      print("Pregunta asignada exitosamente con días: $diasSeleccionados");
      await connection!.close();
      return true;
    } catch (e) {
      print('Error al asignar pregunta: $e');
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que devuelve todos los Sensores, sin repertirse y con la ultima
  /// fecha de alta y baja,
  ///***************************************************************************
  Future<List> DBGetTodoSensor(FechaBaja) async {
    try {
      await connect();
      //Insert en USUARIO_PRIVADO
      // TodoSensor = await connection!.query(
      //   '''
      //   select
      //       MAX("SENSOR"."COD_SENSOR"),
      //       "SENSOR"."ID_SENSOR",
      //       "SENSOR"."DES_OTROS",
      //       "SENSOR"."EMISOR_RECEPTOR",
      //       "SENSOR"."F_ALTA",
      //       "SENSOR"."F_BAJA",
      //       "TIPO_SENSOR"."TIPO_SENSOR",
      //       MAX("HABITACION_SENSOR"."F_ALTA") as "F_ALTA",
      //       MAX("HABITACION_SENSOR"."F_BAJA") as "F_BAJA",
      //       MAX("HABITACION_SENSOR"."COD_HABITACION"),
      //       MAX("TIPO_HABITACION"."TIPO_HABITACION"),
      //       MAX("HABITACION"."OBSERVACIONES"),
      //       MAX("CASA"."DIRECCION"),
      //       MAX("CASA"."NUMERO"),
      //       MAX("CASA"."PISO"),
      //       MAX("CASA"."PUERTA"),
      //       MAX("CASA"."LOCALIDAD"),
      //       MAX("CASA"."PROVINCIA"),
      //       MAX("CASA"."PAIS"),
      //       MAX("CASA"."COD_POSTAL")
      //   from
      //       "SENSOR"
      //   inner join "TIPO_SENSOR" on
      //       "SENSOR"."COD_TIPO_SENSOR" = "TIPO_SENSOR"."COD_TIPO_SENSOR"
      //   left join "HABITACION_SENSOR" on
      //       "SENSOR"."COD_SENSOR" = "HABITACION_SENSOR"."COD_SENSOR"
      //   inner join "HABITACION" on
      //       "HABITACION_SENSOR"."COD_HABITACION" = "HABITACION"."COD_HABITACION"
      //   inner join "TIPO_HABITACION" on
      //       "HABITACION"."COD_TIPO_HABITACION" = "TIPO_HABITACION"."COD_TIPO_HABITACION"
      //   inner join "CASA" on
      //       "HABITACION"."COD_CASA" = "CASA"."COD_CASA"
      //   group by
      //       ( "SENSOR"."ID_SENSOR",
      //       "SENSOR"."DES_OTROS",
      //       "SENSOR"."EMISOR_RECEPTOR",
      //       "SENSOR"."F_ALTA",
      //       "SENSOR"."F_BAJA",
      //       "TIPO_SENSOR"."TIPO_SENSOR")
      //   having
      //       (MAX("HABITACION_SENSOR"."F_BAJA") is not null
      //           or MAX("HABITACION_SENSOR"."F_BAJA") is null)
      //       and "SENSOR"."F_BAJA" is ''' +
      //       FechaBaja +
      //       '''
      //   order by
      //       "SENSOR"."ID_SENSOR" asc;

      // ''',
      //);
      var CasaHabitacionesSensorQuery = '''
      select
          "HABITACION"."COD_HABITACION",
          "CASA"."DIRECCION",
          "CASA"."COD_POSTAL",
          "CASA"."LOCALIDAD",
          "CASA"."PROVINCIA",
          "CASA"."NUM_PLANTAS",
          "CASA"."PAIS",
          "CASA"."NUMERO",
          "CASA"."PISO",
          "CASA"."PUERTA",
          "HABITACION"."OBSERVACIONES",
          "HABITACION"."N_PLANTA",
          "TIPO_HABITACION"."COD_TIPO_HABITACION",
          "TIPO_HABITACION"."TIPO_HABITACION",
          "HABITACION_SENSOR"."COD_SENSOR"
      from
          "HABITACION_SENSOR"
      inner join "HABITACION" on
          "HABITACION_SENSOR"."COD_HABITACION" = "HABITACION"."COD_HABITACION"
      inner join "CASA" on
          "HABITACION"."COD_CASA" = "CASA"."COD_CASA"
      inner join "TIPO_HABITACION" on
          "HABITACION"."COD_TIPO_HABITACION" = "TIPO_HABITACION"."COD_TIPO_HABITACION"
      where
          "HABITACION_SENSOR"."F_BAJA" is null and "HABITACION"."F_BAJA" is null and "CASA"."F_BAJA" is null
      ''',
          CasaHabitacionesSensor = await connection!.query(
            CasaHabitacionesSensorQuery,
          );
      var TodoSensorQuery =
              '''
        select
            "SENSOR"."COD_SENSOR",
            "SENSOR"."ID_SENSOR",
            "SENSOR"."DES_OTROS",
            "SENSOR"."EMISOR_RECEPTOR",
            "SENSOR"."COD_TIPO_SENSOR",
            "TIPO_SENSOR"."TIPO_SENSOR",
            "SENSOR"."F_ALTA",
            "SENSOR"."F_BAJA"
        from
            "SENSOR"
        inner join "TIPO_SENSOR" on
            "SENSOR"."COD_TIPO_SENSOR" = "TIPO_SENSOR"."COD_TIPO_SENSOR"
            where "SENSOR"."F_BAJA" is ''' +
              FechaBaja +
              '''
        order by
            "SENSOR"."ID_SENSOR" asc;
        ''',
          TodoSensor = await connection!.query(TodoSensorQuery);
      await connection!.close();
      print(TodoSensor);
      return [CasaHabitacionesSensor, TodoSensor];
    } catch (e) {
      await connection!.close();
      return [];
    }
  }

  /// ***************************************************************************
  /// Funcion que devuelve los Sensores Disponible
  ///***************************************************************************
  Future DBGetSensorDisp() async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      SensorDisp = await connection!.query(
        // '''SELECT
        //           "SENSOR"."COD_SENSOR",
        //           "SENSOR"."ID_SENSOR",
        //           "HABITACION_SENSOR"."COD_HABITACION",
        //           "SENSOR"."EMISOR_RECEPTOR",
        //           "HABITACION_SENSOR"."F_ALTA",
        //           "HABITACION_SENSOR"."F_BAJA",
        //           "TIPO_SENSOR"."TIPO_SENSOR",
        //           "TIPO_SENSOR"."COD_TIPO_SENSOR",
        //           "SENSOR"."DES_OTROS"

        //     FROM "HABITACION_SENSOR"
        //     inner join "SENSOR" ON "HABITACION_SENSOR"."COD_SENSOR" = "SENSOR"."COD_SENSOR"
        //   	inner join "TIPO_SENSOR" on
        //         "SENSOR"."COD_TIPO_SENSOR" = "TIPO_SENSOR"."COD_TIPO_SENSOR"
        //     WHERE "HABITACION_SENSOR"."F_BAJA" is not null
        //     AND "SENSOR"."F_BAJA" is null
        //     AND NOT EXISTS (
        //       SELECT 1
        //       FROM "HABITACION_SENSOR" t2
        //       WHERE "HABITACION_SENSOR"."COD_SENSOR" = t2."COD_SENSOR"
        //       AND t2."F_BAJA" is null
        //       AND "HABITACION_SENSOR".ctid <> t2.ctid
        //     )
        //     order by "SENSOR"."ID_SENSOR"
        //     ''',
        '''
          SELECT 
            "SENSOR"."COD_SENSOR", 
            "SENSOR"."ID_SENSOR", 
            "HABITACION_SENSOR"."COD_HABITACION",
            "SENSOR"."EMISOR_RECEPTOR",
            "HABITACION_SENSOR"."F_ALTA",
            "HABITACION_SENSOR"."F_BAJA",
            "TIPO_SENSOR"."TIPO_SENSOR", 
            "TIPO_SENSOR"."COD_TIPO_SENSOR",
            "SENSOR"."DES_OTROS"
          FROM "SENSOR"
          INNER JOIN "TIPO_SENSOR" ON 
            "SENSOR"."COD_TIPO_SENSOR" = "TIPO_SENSOR"."COD_TIPO_SENSOR"
          LEFT JOIN "HABITACION_SENSOR" ON 
            "SENSOR"."COD_SENSOR" = "HABITACION_SENSOR"."COD_SENSOR"
          WHERE ("HABITACION_SENSOR"."COD_HABITACION" IS NULL OR "HABITACION_SENSOR"."F_BAJA" IS NOT NULL and "SENSOR"."F_BAJA" IS NULL)
          AND NOT EXISTS (
              SELECT 1
              FROM "HABITACION_SENSOR" AS PW
              WHERE PW."COD_SENSOR" = "SENSOR"."COD_SENSOR"
              AND PW."F_BAJA" IS NULL
          )
          ORDER BY "SENSOR"."ID_SENSOR";
        ''',
      );
      await connection!.close();
      print(SensorDisp);
      return SensorDisp!;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que devuelve los Wearable Disponible
  ///***************************************************************************
  Future DBGetWearablesDisp() async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      WearableDisp = await connection!.query('''
        SELECT 
          "WEARABLE"."COD_WEARABLE", 
          "WEARABLE"."ID_WEARABLE", 
          "PACIENTE_WEARABLE"."COD_USUARIO", 
          "PACIENTE_WEARABLE"."COD_PACIENTE_WEARABLE", 
          "TIPO_WEARABLE"."TIPO_WEARABLE", 
          "PACIENTE_WEARABLE"."F_ALTA", 
          "PACIENTE_WEARABLE"."F_BAJA", 
          "WEARABLE"."DES_OTROS", 
          "WEARABLE"."COD_TIPO_WEARABLE"
        FROM "WEARABLE"
        INNER JOIN "TIPO_WEARABLE" ON 
          "WEARABLE"."COD_TIPO_WEARABLE" = "TIPO_WEARABLE"."COD_TIPO_WEARABLE"
        LEFT JOIN "PACIENTE_WEARABLE" ON 
          "WEARABLE"."COD_WEARABLE" = "PACIENTE_WEARABLE"."COD_WEARABLE"
        WHERE ("PACIENTE_WEARABLE"."COD_USUARIO" IS NULL OR "PACIENTE_WEARABLE"."F_BAJA" IS NOT NULL and "WEARABLE"."F_BAJA" is null)
        AND NOT EXISTS (
            SELECT 1
            FROM "PACIENTE_WEARABLE" AS PW
            WHERE PW."COD_WEARABLE" = "WEARABLE"."COD_WEARABLE"
            AND PW."F_BAJA" IS NULL
        )
        ORDER BY "WEARABLE"."ID_WEARABLE";
            ''');
      await connection!.close();
      print(WearableDisp);
      return WearableDisp!;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que crea un nuevo sensdor en la base de datos con una habitacion asignada
  ///  1º abre la conexion con la base de datos
  ///  2º inserta los dator en la tabla Sensor con el codigo de la habitacion
  ///  correspondiente
  ///  3º en caso de que el sensor exista devuelve el error que se analiza en la
  ///    funcion que llama a esta funcion
  ///***************************************************************************
  Future DBAnagdirSensor(
    ID_SENSOR,
    COD_HABITACION,
    COD_TIPO_SENSOR,
    EMISOR_RECEPTOR,
    DES_OTROS,
  ) async {
    try {
      await connect();
      var Insert = '''
        with first_insert AS (
          INSERT INTO "SENSOR"
          ("ID_SENSOR", "COD_TIPO_SENSOR", "EMISOR_RECEPTOR", "DES_OTROS")
          VALUES(@ID_SENSOR, @COD_TIPO_SENSOR, @EMISOR_RECEPTOR, @DES_OTROS)
          RETURNING "COD_SENSOR"
        )
        INSERT INTO "HABITACION_SENSOR"
        ("COD_HABITACION", "COD_SENSOR")
        VALUES(@COD_HABITACION, (SELECT "COD_SENSOR" FROM first_insert))
        ''';
      var NewSensor = await connection!.execute(
        Insert,
        substitutionValues: {
          'ID_SENSOR': ID_SENSOR,
          'DES_OTROS': DES_OTROS,
          'COD_HABITACION': COD_HABITACION,
          'COD_TIPO_SENSOR': COD_TIPO_SENSOR,
          'EMISOR_RECEPTOR': EMISOR_RECEPTOR,
        },
      );
      await connection!.close();
      return true;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que crea un nuevo sensdor en la base de datos.
  ///  1º abre la conexion con la base de datos
  ///  2º inserta los dator en la tabla Sensor con el codigo de la habitacion
  ///  correspondiente
  ///  3º en caso de que el sensor exista devuelve el error que se analiza en la
  ///    funcion que llama a esta funcion
  ///***************************************************************************
  Future DBAnagdirSensorNuevo(
    ID_SENSOR,
    COD_TIPO_SENSOR,
    EMISOR_RECEPTOR,
    DES_OTROS,
  ) async {
    try {
      await connect();
      var Insert = '''
        
        INSERT INTO "SENSOR"
        ("ID_SENSOR", "DES_OTROS", "EMISOR_RECEPTOR", "COD_TIPO_SENSOR")
        VALUES(@ID_SENSOR, @DES_OTROS, @EMISOR_RECEPTOR,  @COD_TIPO_SENSOR);

        ''';
      var NewSensor = await connection!.execute(
        Insert,
        substitutionValues: {
          'ID_SENSOR': ID_SENSOR,
          'DES_OTROS': DES_OTROS,
          'COD_TIPO_SENSOR': COD_TIPO_SENSOR,
          'EMISOR_RECEPTOR': EMISOR_RECEPTOR,
        },
      );
      await connection!.close();
      return true;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que Desactiva o Activa un sensor en la base de datos de una habitacion
  ///***************************************************************************
  Future DBActDesactSensorHabitacion(COD_HABITACION, COD_SENSOR) async {
    try {
      await connect();
      var update = '''
        UPDATE "HABITACION_SENSOR" 
        SET "F_BAJA"= CURRENT_TIMESTAMP
        WHERE "COD_HABITACION"=@COD_HABITACION and "COD_SENSOR"=@COD_SENSOR;
        ''';
      var ActDes = await connection!.execute(
        update,
        substitutionValues: {
          'COD_SENSOR': COD_SENSOR,
          'COD_HABITACION': COD_HABITACION,
        },
      );
      await connection!.close();
      return 'Correcto';
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que Desactiva o Activa un sensor en la base de datos de una habitacion
  ///***************************************************************************
  Future DBActDesactSensorConHabitacion(
    COD_HABITACION,
    COD_SENSOR,
    F_BAJA_SENSOR,
    F_BAJA_HABITACION_SENSOR,
  ) async {
    try {
      await connect();
      var update = '''
        BEGIN TRANSACTION;
        UPDATE "HABITACION_SENSOR" 
        SET "F_BAJA"= 
          CASE 
            WHEN @F_BAJA_HABITACION_SENSOR IS NULL THEN NULL 
            WHEN @F_BAJA_HABITACION_SENSOR = 'CURRENT_TIMESTAMP' THEN CURRENT_TIMESTAMP                 
          END 
        WHERE "COD_HABITACION"=@COD_HABITACION and "COD_SENSOR"=@COD_SENSOR;
        UPDATE "SENSOR"
        SET "F_BAJA"= 
          CASE 
            WHEN @F_BAJA_SENSOR IS NULL THEN NULL 
            WHEN @F_BAJA_SENSOR = 'CURRENT_TIMESTAMP' THEN CURRENT_TIMESTAMP                 
          END
        WHERE "COD_SENSOR"=@COD_SENSOR;
        COMMIT TRANSACTION;
        ''';
      var ActDes = await connection!.execute(
        update,
        substitutionValues: {
          'COD_SENSOR': COD_SENSOR,
          'COD_HABITACION': COD_HABITACION,
          'F_BAJA_SENSOR': F_BAJA_SENSOR,
          'F_BAJA_HABITACION_SENSOR': F_BAJA_HABITACION_SENSOR,
        },
      );
      await connection!.close();
      return 'Correcto';
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que Desactiva o Activa un sensor on
  ///***************************************************************************
  Future DBActDesactSensorSinHabitacion(COD_SENSOR, F_BAJA_SENSOR) async {
    try {
      await connect();
      var update = '''
    
        UPDATE "SENSOR"
        SET "F_BAJA"= 
          CASE 
            WHEN @F_BAJA_SENSOR IS NULL THEN NULL 
            WHEN @F_BAJA_SENSOR = 'CURRENT_TIMESTAMP' THEN CURRENT_TIMESTAMP                 
          END
        WHERE "COD_SENSOR"=@COD_SENSOR;
        ''';
      var ActDes = await connection!.execute(
        update,
        substitutionValues: {
          'COD_SENSOR': COD_SENSOR,
          'F_BAJA_SENSOR': F_BAJA_SENSOR,
        },
      );
      await connection!.close();
      return 'Correcto';
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que Elimina el Tipo de hABITACION
  ///***************************************************************************
  Future DBEliminarTipoSensor(COD_TIPO_SENSOR) async {
    try {
      await connect();
      var update = '''
        DELETE FROM "TIPO_SENSOR"
        WHERE "COD_TIPO_SENSOR"=@COD_TIPO_SENSOR;
        ''';
      var ActDes = await connection!.execute(
        update,
        substitutionValues: {'COD_TIPO_SENSOR': COD_TIPO_SENSOR},
      );
      await connection!.close();
      return 'Correcto';
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /*****************************************************************************
      Funcion que crea el Tipo de Habitacion
   ****************************************************************************/
  Future DBNewTipoHabitacion(TIPO_HABITACION) async {
    try {
      await connect();
      var Insert = '''
        INSERT INTO "TIPO_HABITACION"
        ("TIPO_HABITACION")
        VALUES(@TIPO_HABITACION);
        ''';
      var NewSensor = await connection!.execute(
        Insert,
        substitutionValues: {'TIPO_HABITACION': TIPO_HABITACION},
      );
      await connection!.close();
      return true;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /*****************************************************************************
      Funcion que crea el Tipo de Cuidaodr
   ****************************************************************************/
  Future DBNewTipoCuidador(TIPO_CUIDADOR) async {
    try {
      await connect();
      var Insert = '''
        INSERT INTO "TIPO_CUIDADOR"
        ("TIPO_CUIDADOR")
        VALUES(@TIPO_CUIDADOR);
        ''';
      var NewSensor = await connection!.execute(
        Insert,
        substitutionValues: {'TIPO_CUIDADOR': TIPO_CUIDADOR},
      );
      await connection!.close();
      return true;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que Elimina el Tipo de Habitacion
  ///***************************************************************************
  Future DBEliminarTipoHabitacion(COD_TIPO_HABITACION) async {
    try {
      await connect();
      var update = '''
        DELETE FROM "TIPO_HABITACION"
        WHERE "COD_TIPO_HABITACION"=@COD_TIPO_HABITACION;
        ''';
      var ActDes = await connection!.execute(
        update,
        substitutionValues: {'COD_TIPO_HABITACION': COD_TIPO_HABITACION},
      );
      await connection!.close();
      return 'Correcto';
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que Elimina el Tipo de Cuidador
  ///***************************************************************************
  Future DBEliminarTipoCuidador(COD_TIPO_CUIDADOR) async {
    try {
      await connect();
      var update = '''
        DELETE FROM "TIPO_CUIDADOR"
        WHERE "COD_TIPO_CUIDADOR"=@COD_TIPO_CUIDADOR;
        ''';
      var ActDes = await connection!.execute(
        update,
        substitutionValues: {'COD_TIPO_CUIDADOR': COD_TIPO_CUIDADOR},
      );
      await connection!.close();
      return 'Correcto';
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que modifica el Tipo de Cuidador
  ///***************************************************************************
  Future DBModificarTipoCuidador(COD_TIPO_CUIDADOR, TIPO_CUIDADOR) async {
    try {
      await connect();
      var update = '''
        UPDATE "TIPO_CUIDADOR"
        SET "TIPO_CUIDADOR"=@TIPO_CUIDADOR
        WHERE "COD_TIPO_CUIDADOR"=@COD_TIPO_CUIDADOR;
        ''';
      var ActDes = await connection!.execute(
        update,
        substitutionValues: {
          'COD_TIPO_CUIDADOR': COD_TIPO_CUIDADOR,
          'TIPO_CUIDADOR': TIPO_CUIDADOR,
        },
      );
      await connection!.close();
      return true;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que modifica el Tecnologia Wearable
  ///***************************************************************************
  Future DBModificarTipoWearable(COD_TIPO_WEARABLE, TIPO_WEARABLE) async {
    try {
      await connect();
      var update = '''
        UPDATE "TIPO_WEARABLE"
        SET "TIPO_WEARABLE"=@TIPO_WEARABLE
        WHERE "COD_TIPO_WEARABLE"=@COD_TIPO_WEARABLE;
        ''';
      var ActDes = await connection!.execute(
        update,
        substitutionValues: {
          'COD_TIPO_WEARABLE': COD_TIPO_WEARABLE,
          'TIPO_WEARABLE': TIPO_WEARABLE,
        },
      );
      await connection!.close();
      return true;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que modifica el  Wearable
  ///***************************************************************************
  Future DBModificarWearable(
    COD_WEARABLE,
    ID_WEARABLE,
    COD_TIPO_WEARABLE,
    DES_OTROS,
  ) async {
    try {
      await connect();
      var update = '''
        UPDATE "WEARABLE"
        SET "ID_WEARABLE"=@ID_WEARABLE, "DES_OTROS"=@DES_OTROS, "COD_TIPO_WEARABLE"=@COD_TIPO_WEARABLE
        WHERE "COD_WEARABLE"=@COD_WEARABLE;
        ''';
      var ActDes = await connection!.execute(
        update,
        substitutionValues: {
          'COD_WEARABLE': COD_WEARABLE,
          'ID_WEARABLE': ID_WEARABLE,
          'COD_TIPO_WEARABLE': COD_TIPO_WEARABLE,
          'DES_OTROS': DES_OTROS,
        },
      );
      await connection!.close();
      return true;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que modifica el  Sensor
  ///***************************************************************************
  Future DBModificarSensor(
    COD_SENSOR,
    ID_SENSOR,
    COD_TIPO_SENSOR,
    EMISOR_RECEPTOR,
    DES_OTROS,
  ) async {
    try {
      await connect();
      var update = '''
        UPDATE "SENSOR"
        SET "ID_SENSOR"=@ID_SENSOR, "COD_TIPO_SENSOR"=@COD_TIPO_SENSOR, "EMISOR_RECEPTOR"=@EMISOR_RECEPTOR, "DES_OTROS"=@DES_OTROS
        WHERE "COD_SENSOR"=@COD_SENSOR;
        ''';
      var ActDes = await connection!.execute(
        update,
        substitutionValues: {
          'COD_SENSOR': COD_SENSOR,
          'ID_SENSOR': ID_SENSOR,
          'COD_TIPO_SENSOR': COD_TIPO_SENSOR,
          'EMISOR_RECEPTOR': EMISOR_RECEPTOR,
          'DES_OTROS': DES_OTROS,
        },
      );
      await connection!.close();
      return true;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que modifica la Habitacion
  ///***************************************************************************
  Future DBModificarHabitacion(
    COD_HABITACION,
    OBSERVACIONES,
    N_PLANTA,
    COD_TIPO_HABITACION,
  ) async {
    try {
      await connect();
      var update = '''
        UPDATE "HABITACION"
        SET "OBSERVACIONES"=@OBSERVACIONES, "N_PLANTA"=@N_PLANTA, "COD_TIPO_HABITACION"=@COD_TIPO_HABITACION
        WHERE "COD_HABITACION"=@COD_HABITACION;
        ''';
      var ActDes = await connection!.execute(
        update,
        substitutionValues: {
          'COD_HABITACION': COD_HABITACION,
          'OBSERVACIONES': OBSERVACIONES,
          'N_PLANTA': N_PLANTA,
          'COD_TIPO_HABITACION': COD_TIPO_HABITACION,
        },
      );
      await connection!.close();
      return true;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que modifica el Tecnologia Sensor
  ///***************************************************************************
  Future DBModificarTipoSensor(COD_TIPO_SENSOR, TIPO_SENSOR) async {
    try {
      await connect();
      var update = '''
        UPDATE "TIPO_SENSOR"
        SET "TIPO_SENSOR"=@TIPO_SENSOR
        WHERE "COD_TIPO_SENSOR"=@COD_TIPO_SENSOR;
        ''';
      var ActDes = await connection!.execute(
        update,
        substitutionValues: {
          'COD_TIPO_SENSOR': COD_TIPO_SENSOR,
          'TIPO_SENSOR': TIPO_SENSOR,
        },
      );
      await connection!.close();
      return true;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que modifica el tipo de variable sanitria
  ///***************************************************************************
  Future DBModificarVariableSanitaria(
    COD_VARIABLES_SANITARIAS,
    VARIABLES_SANITARIAS,
  ) async {
    try {
      await connect();
      var update = '''
        UPDATE "VARIABLES_SANITARIAS"
        SET "VARIABLES_SANITARIAS"=@VARIABLES_SANITARIAS
        WHERE "COD_VARIABLES_SANITARIAS"=@COD_VARIABLES_SANITARIAS;
        ''';
      var ActDes = await connection!.execute(
        update,
        substitutionValues: {
          'COD_VARIABLES_SANITARIAS': COD_VARIABLES_SANITARIAS,
          'VARIABLES_SANITARIAS': VARIABLES_SANITARIAS,
        },
      );
      await connection!.close();
      return true;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que modifica el tipo de variable social
  ///***************************************************************************
  Future DBModificarVariableSocial(
    COD_VARIABLES_SOCIALES,
    VARIABLES_SOCIALES,
  ) async {
    try {
      await connect();
      var update = '''
        UPDATE "VARIABLES_SOCIALES"
        SET "VARIABLES_SOCIALES"=@VARIABLES_SOCIALES
        WHERE "COD_VARIABLES_SOCIALES"=@COD_VARIABLES_SOCIALES;
        ''';
      var ActDes = await connection!.execute(
        update,
        substitutionValues: {
          'COD_VARIABLES_SOCIALES': COD_VARIABLES_SOCIALES,
          'VARIABLES_SOCIALES': VARIABLES_SOCIALES,
        },
      );
      await connection!.close();
      return true;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que modifica el Tipo de Habitacion
  ///***************************************************************************
  Future DBModificarTipoHabitacion(COD_TIPO_HABITACION, TIPO_HABITACION) async {
    try {
      await connect();
      var update = '''
        UPDATE "TIPO_HABITACION"
        SET "TIPO_HABITACION"=@TIPO_HABITACION
        WHERE "COD_TIPO_HABITACION"=@COD_TIPO_HABITACION;
        ''';
      var ActDes = await connection!.execute(
        update,
        substitutionValues: {
          'COD_TIPO_HABITACION': COD_TIPO_HABITACION,
          'TIPO_HABITACION': TIPO_HABITACION,
        },
      );
      await connection!.close();
      return true;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que crea una nueva Variable Social en la base de datos
  ///**************************************************************************
  Future DBNewVariableSocial(VARIABLES_SOCIALES) async {
    try {
      await connect();
      var Insert = '''
        INSERT INTO "VARIABLES_SOCIALES"
        ("VARIABLES_SOCIALES")
        VALUES(@VARIABLES_SOCIALES);
        ''';
      var NewSensor = await connection!.execute(
        Insert,
        substitutionValues: {'VARIABLES_SOCIALES': VARIABLES_SOCIALES},
      );
      await connection!.close();
      return true;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que crea una nueva Variable Sanitaria en la base de datos
  ///**************************************************************************
  Future DBNewVariableSanitaria(VARIABLES_SANITARIAS) async {
    try {
      await connect();
      var Insert = '''
        INSERT INTO "VARIABLES_SANITARIAS"
        ("VARIABLES_SANITARIAS")
        VALUES(@VARIABLES_SANITARIAS);
        ''';
      var NewSensor = await connection!.execute(
        Insert,
        substitutionValues: {'VARIABLES_SANITARIAS': VARIABLES_SANITARIAS},
      );
      await connection!.close();
      return true;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que elimina una variable social de la base de datos
  /// ****************************************************************************
  Future DBEliminarVariableSocial(COD_VARIABLES_SOCIALES) async {
    try {
      await connect();
      var update = '''
        DELETE FROM "VARIABLES_SOCIALES"
        WHERE "COD_VARIABLES_SOCIALES"=@COD_VARIABLES_SOCIALES;
        ''';
      var ActDes = await connection!.execute(
        update,
        substitutionValues: {'COD_VARIABLES_SOCIALES': COD_VARIABLES_SOCIALES},
      );
      await connection!.close();
      return 'Correcto';
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que elimina una variable social de la base de datos
  /// ****************************************************************************
  Future DBEliminarVariableSanitaria(COD_VARIABLES_SANITARIAS) async {
    try {
      await connect();
      var update = '''
        DELETE FROM "VARIABLES_SANITARIAS"
        WHERE "COD_VARIABLES_SANITARIAS"=@COD_VARIABLES_SANITARIAS;
        ''';
      var ActDes = await connection!.execute(
        update,
        substitutionValues: {
          'COD_VARIABLES_SANITARIAS': COD_VARIABLES_SANITARIAS,
        },
      );
      await connection!.close();
      return 'Correcto';
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que crea un nuevo Tipo de Wearable en la base de datos.
  ///***************************************************************************
  Future DBNewTipoWearable(TIPO_WEARABLE) async {
    try {
      await connect();
      var Insert = '''
        INSERT INTO "TIPO_WEARABLE"
        ("TIPO_WEARABLE")
        VALUES(@TIPO_WEARABLE);
        ''';
      var NewSensor = await connection!.execute(
        Insert,
        substitutionValues: {'TIPO_WEARABLE': TIPO_WEARABLE},
      );
      await connection!.close();
      return true;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  Future DBEliminarTipoWearable(COD_TIPO_WEARABLE) async {
    try {
      await connect();
      var update = '''
        DELETE FROM "TIPO_WEARABLE"
        WHERE "COD_TIPO_WEARABLE"=@COD_TIPO_WEARABLE;
        ''';
      var ActDes = await connection!.execute(
        update,
        substitutionValues: {'COD_TIPO_WEARABLE': COD_TIPO_WEARABLE},
      );
      await connection!.close();
      return 'Correcto';
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que añade un nuevo tipo de sensor a la base de datos
  ///**************************************************************************
  Future DBNewTipoSensor(TIPO_SENSOR) async {
    try {
      await connect();
      var Insert = '''
        INSERT INTO "TIPO_SENSOR"
        ("TIPO_SENSOR")
        VALUES(@TIPO_SENSOR);
        ''';
      var NewSensor = await connection!.execute(
        Insert,
        substitutionValues: {'TIPO_SENSOR': TIPO_SENSOR},
      );
      await connection!.close();
      return true;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que Desactiva o Activa un wearable y da de baja el wearable del pac
  /// en la base de datos de un paceinte
  ///***************************************************************************
  Future DBActDesActWearableConPaciente(
    COD_USUARIO,
    COD_WEARABLE,
    F_BAJA_WEARABLE,
    F_BAJA_PACIENTE_WEARABLE,
  ) async {
    try {
      await connect();
      var update = '''
        BEGIN TRANSACTION;
        UPDATE "PACIENTE_WEARABLE" 
        SET "F_BAJA"= 
          CASE 
            WHEN @F_BAJA_PACIENTE_WEARABLE IS NULL THEN NULL 
            WHEN @F_BAJA_PACIENTE_WEARABLE = 'CURRENT_TIMESTAMP' THEN CURRENT_TIMESTAMP                 
          END 
        WHERE "COD_USUARIO"=@COD_USUARIO and "COD_WEARABLE"=@COD_WEARABLE;
        UPDATE "WEARABLE"
        SET "F_BAJA"= 
          CASE 
            WHEN @F_BAJA_WEARABLE IS NULL THEN NULL 
            WHEN @F_BAJA_WEARABLE = 'CURRENT_TIMESTAMP' THEN CURRENT_TIMESTAMP                 
          END
        WHERE "COD_WEARABLE"=@COD_WEARABLE;
        COMMIT TRANSACTION;
        ''';
      var ActDes = await connection!.execute(
        update,
        substitutionValues: {
          'COD_WEARABLE': COD_WEARABLE,
          'COD_USUARIO': COD_USUARIO,
          'F_BAJA_WEARABLE': F_BAJA_WEARABLE,
          'F_BAJA_PACIENTE_WEARABLE': F_BAJA_PACIENTE_WEARABLE,
        },
      );
      await connection!.close();
      return 'Correcto';
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que Desactiva o Activa un wearable
  ///***************************************************************************
  Future DBActDesActWearableSinPaciente(COD_WEARABLE, F_BAJA_WEARABLE) async {
    try {
      await connect();
      var update = '''
        
        UPDATE "WEARABLE"
        SET "F_BAJA"= 
          CASE 
            WHEN @F_BAJA_WEARABLE IS NULL THEN NULL 
            WHEN @F_BAJA_WEARABLE = 'CURRENT_TIMESTAMP' THEN CURRENT_TIMESTAMP                 
          END
        WHERE "COD_WEARABLE"=@COD_WEARABLE;
        
        ''';
      var ActDes = await connection!.execute(
        update,
        substitutionValues: {
          'COD_WEARABLE': COD_WEARABLE,
          'F_BAJA_WEARABLE': F_BAJA_WEARABLE,
        },
      );
      await connection!.close();
      return 'Correcto';
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que Desactiva o Activa un wearable en la base de datos de un paceinte
  ///***************************************************************************
  Future DBActDesactWearablePaciente(COD_USUARIO, COD_WEARABLE, STATUS) async {
    try {
      await connect();
      var update = '''
        UPDATE "PACIENTE_WEARABLE" 
        SET "F_BAJA"= CURRENT_TIMESTAMP
        WHERE "COD_USUARIO"=@COD_USUARIO and "COD_WEARABLE"=@COD_WEARABLE;
        ''';
      var ActDes = await connection!.execute(
        update,
        substitutionValues: {
          'COD_WEARABLE': COD_WEARABLE,
          'COD_USUARIO': COD_USUARIO,
          'STATUS': STATUS,
        },
      );
      await connection!.close();
      return 'Correcto';
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que asigna un sensor a una habitacion en la base de datos.
  ///  1º abre la conexion con la base de datos
  ///  2º da de alta de nuevo el sensor en la tabla HABITACION_SENSOR
  /// NOTA: esta funcion se llama cuando se da de alta un sensor que ya existia
  /// en la habitacion
  ///***************************************************************************
  Future DBAnagdirSensorExistente(COD_SENSOR, COD_HABITACION) async {
    try {
      await connect();
      var update = '''
        UPDATE "HABITACION_SENSOR"
        SET   "F_BAJA"=NULL
        WHERE "COD_HABITACION"=@COD_HABITACION and "COD_SENSOR"=@COD_SENSOR;  
        ''';
      var NewSensor = await connection!.execute(
        update,
        substitutionValues: {
          'COD_SENSOR': COD_SENSOR,
          'COD_HABITACION': COD_HABITACION,
        },
      );

      await connection!.close();
      return true;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que asigna un sensor a una habitacion en la base de datos.
  ///  1º abre la conexion con la base de datos
  ///  2º inserta los dator en la tabla Sensor con el codigo de la habitacion
  ///  correspondiente
  ///***************************************************************************
  Future DBAnagdirSensorDisp(COD_SENSOR, COD_HABITACION) async {
    try {
      await connect();
      var Insert = '''
        INSERT INTO "HABITACION_SENSOR"
        ("COD_HABITACION", "COD_SENSOR")
        VALUES(@COD_HABITACION, @COD_SENSOR);
        ''';
      var NewSensor = await connection!.execute(
        Insert,
        substitutionValues: {
          'COD_SENSOR': COD_SENSOR,
          'COD_HABITACION': COD_HABITACION,
        },
      );
      await connection!.close();
      return true;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que asigna un WEARABLE a un PACIENTE que ya lo tubo asignado
  ///  1º abre la conexion con la base de datos
  ///  2º inserta los dator en la tabla Sensor con el codigo de la habitacion
  ///  correspondiente
  ///***************************************************************************
  Future DBAnagdirWearableExistente(COD_WEARABLE, COD_USUARIO) async {
    try {
      await connect();
      var Insert = '''
        UPDATE "PACIENTE_WEARABLE"
        SET "F_BAJA"=NULL
        WHERE "COD_USUARIO"=@COD_USUARIO and "COD_WEARABLE"=@COD_WEARABLE;
        ''';
      var NewWearable = await connection!.execute(
        Insert,
        substitutionValues: {
          'COD_WEARABLE': COD_WEARABLE,
          'COD_USUARIO': COD_USUARIO,
        },
      );
      await connection!.close();
      return true;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  // /*****************************************************************************
  //  * Funcion que asigna un WEARABLE a una PACIENTE en la base de datos.
  //  *  1º abre la conexion con la base de datos
  //  *  2º inserta los dator en la tabla Sensor con el codigo de la habitacion
  //  *  correspondiente
  //  *****************************************************************************/
  // Future DBAnagdirWearableDisp(COD_WEARABLE, COD_USUARIO) async {
  //   try {
  //     await connect();
  //     var Insert = '''
  //       INSERT INTO "PACIENTE_WEARABLE"
  //       ("COD_USUARIO", "COD_WEARABLE")
  //       VALUES(@COD_USUARIO, @COD_WEARABLE)
  //       returning "COD_PACIENTE_WEARABLE";
  //       ''';
  //     var NewWearable = await connection!.query(
  //       Insert,
  //       substitutionValues: {
  //         'COD_WEARABLE': COD_WEARABLE,
  //         'COD_USUARIO': COD_USUARIO,
  //       },
  //     );
  //     if (NewWearable.isNotEmpty) {
  //       var result =
  //           await InfluxDBService().PacienteWearable(NewWearable[0][0]);
  //       //return NewWearable[0][0];
  //       if (result == true) {
  //         return true;
  //       } else {
  //         await ctx.query(
  //             'DELETE FROM "PACIENTE_WEARABLE" WHERE "COD_PACIENTE_WEARABLE" = @codPacienteWearable',
  //             substitutionValues: {'codPacienteWearable': NewWearable[0][0]});
  //         return false;
  //       }
  //     } else {
  //       return false;
  //     }
  //   } catch (e) {
  //     return e;
  //   }
  // }

  Future DBAnagdirWearableDisp(COD_WEARABLE, COD_USUARIO) async {
    try {
      await connect();
      await connection!.transaction((ctx) async {
        var Insert = '''
        INSERT INTO "PACIENTE_WEARABLE"
        ("COD_USUARIO", "COD_WEARABLE")
        VALUES(@COD_USUARIO, @COD_WEARABLE)
        returning "COD_PACIENTE_WEARABLE";
        ''';
        var NewWearable = await ctx.query(
          Insert,
          substitutionValues: {
            'COD_WEARABLE': COD_WEARABLE,
            'COD_USUARIO': COD_USUARIO,
          },
        );

        // if (NewWearable.length > 0) {
        //   var result =
        //       await InfluxDBService().AddPacienteWearable(NewWearable[0][0]);

        //   if (result != true) {
        //     // La escritura en InfluxDB falló, deshacer la escritura en PostgreSQL
        //     await ctx.query(
        //         'DELETE FROM "PACIENTE_WEARABLE" WHERE "COD_PACIENTE_WEARABLE" = @codPacienteWearable',
        //         substitutionValues: {
        //           'codPacienteWearable': NewWearable[0][0]
        //         });
        //     return false;
        //   }
        // } else {
        //   //return false;
        // }
      });
      await connection!.close();
      return true;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que devuelve los usuarios CUIDADORES de una vivienda
  ///***************************************************************************
  Future<List> DBGetCuidadoresVivienda(COD_CASA) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      CuidadorVivienda = await connection!.query(
        'select'
        '    "USUARIO_PRIVADO"."COD_USUARIO",'
        '    "USUARIO_PRIVADO"."NOMBRE",'
        '    "USUARIO_PRIVADO"."APELLIDO1",'
        '    "USUARIO_PRIVADO"."APELLIDO2",'
        '    "USUARIO_PRIVADO"."F_NACIMIENTO",'
        '    "USUARIO_PRIVADO"."TELEFONO",'
        '    "USUARIO_PRIVADO"."MAIL",'
        '    "USUARIO_PRIVADO"."ORGANIZACION",'
        '    "USUARIO_PRIVADO"."F_ALTA",'
        '    "USUARIO_PRIVADO"."F_BAJA",'
        '    "TIPO_CUIDADOR"."TIPO_CUIDADOR",'
        '    "USUARIO_CUIDADOR"."COD_TIPO_CUIDADOR",'
        '    "USUARIO_CUIDADOR"."DES_OTROS"'
        'from'
        '    "USUARIO_PRIVADO"'
        'inner join "USUARIO_CUIDADOR" on'
        '    "USUARIO_PRIVADO"."COD_USUARIO" = "USUARIO_CUIDADOR"."COD_USUARIO"'
        'inner join "CUIDADOR_CASA" on'
        '    "USUARIO_CUIDADOR"."COD_USUARIO" = "CUIDADOR_CASA"."COD_USUARIO"'
        'inner join "TIPO_CUIDADOR" on'
        '"USUARIO_CUIDADOR"."COD_TIPO_CUIDADOR" ="TIPO_CUIDADOR"."COD_TIPO_CUIDADOR"'
        'where "CUIDADOR_CASA"."COD_CASA" = @COD_CASA and "USUARIO_PRIVADO"."F_BAJA" is null and "CUIDADOR_CASA"."F_BAJA" is null;',
        substitutionValues: {'COD_CASA': COD_CASA},
      );
      print(CuidadorVivienda);
      await connection!.close();
      return CuidadorVivienda!;
    } catch (e) {
      return [];
    }
  }

  /// *****************************************************************************
  /// Funcion que elimina los usuarios CUIDADORES de una vivienda
  ///****************************************************************************

  Future DBActDesactCuidaorVivienda(COD_CASA, COD_USUARIO, F_BAJA) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      var ActDesact = '''
          UPDATE "CUIDADOR_CASA"
          SET "F_BAJA"=
            CASE
              WHEN @F_BAJA = 'CURRENT_TIMESTAMP' THEN CURRENT_TIMESTAMP
              WHEN @F_BAJA IS NULL THEN NULL
            END
          WHERE "COD_USUARIO"=@COD_USUARIO AND "COD_CASA"=@COD_CASA;
      ''';
      var CuidadorViviendaDelete = await connection!.execute(
        ActDesact,
        substitutionValues: {
          'COD_CASA': COD_CASA,
          'COD_USUARIO': COD_USUARIO,
          'F_BAJA': F_BAJA,
        },
      );
      await connection!.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// ***************************************************************************
  /// Funcion que crea un nuevo USUARIO_CUIDADOR de una vivienda en concreto.
  ///  1º abre la conexion con la base de datos
  ///  2º convierte la contraseña a un hash
  ///  3º inserta los datos en la tabla USUARIO_PRIVADO
  ///***************************************************************************
  Future DBNewCuidadorVivienda(
    Name,
    Surname1,
    Surname2,
    DateBirth,
    PhoneNumber,
    Email,
    Organitation,
    COD_TIPO_CUIDADOR,
    Password,
    COD_CASA,
    DES_OTROS,
  ) async {
    try {
      await connect();
      var PasswordHash = sha256.convert(utf8.encode(Password)).toString();
      // Insert en USUARIO_PRIVADO
      NewCuidadorVivienda = await connection!.query(
        '''
        WITH first_insert AS (
          INSERT INTO "USUARIO_PRIVADO"
            ("NOMBRE", "APELLIDO1", "APELLIDO2", "F_NACIMIENTO", "TELEFONO", "MAIL", "PASSWORD", "ORGANIZACION")
            VALUES (@Name, @Surname1, @Surname2, @DateBirth, @PhoneNumber, @Email, @Password, @Organitation)
            RETURNING "COD_USUARIO"
          ), 
        second_insert AS (
        INSERT INTO "USUARIO_CUIDADOR" ("COD_USUARIO", "COD_TIPO_CUIDADOR", "DES_OTROS")
        SELECT "COD_USUARIO", @COD_TIPO_CUIDADOR, @DES_OTROS FROM first_insert
        RETURNING "COD_USUARIO"
        )
        insert into "CUIDADOR_CASA" ("COD_USUARIO", "COD_CASA")
        select second_insert."COD_USUARIO", @COD_CASA from second_insert
        ''',
        substitutionValues: {
          'Name': Name,
          'Surname1': Surname1,
          'Surname2': Surname2,
          'DateBirth': DateBirth,
          'PhoneNumber': PhoneNumber,
          'Email': Email,
          'COD_TIPO_CUIDADOR': COD_TIPO_CUIDADOR,
          'Password': PasswordHash,
          'Organitation': Organitation,
          'COD_CASA': COD_CASA,
          'DES_OTROS': DES_OTROS,
        },
      );
      await connection!.close();
      return true;
    } catch (e) {
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que Modifica EL cuidador de una vivienda en concreto.
  ///***************************************************************************
  Future DBModCuidadorVivienda(
    COD_USUARIO,
    Name,
    Surname1,
    Surname2,
    DateBirth,
    PhoneNumber,
    Email,
    Organitation,
    COD_TIPO_CUIDADOR,
    COD_CASA,
    DES_OTROS,
  ) async {
    try {
      await connect();

      // Comenzar la transacción
      await connection!.query('BEGIN');

      // Actualizar la tabla "USUARIO_PRIVADO"
      await connection!.query(
        '''
      UPDATE "USUARIO_PRIVADO"
      SET "NOMBRE"=@Name, 
      "APELLIDO1"=@Surname1, 
      "APELLIDO2"=@Surname2, 
      "F_NACIMIENTO"=@DateBirth, 
      "TELEFONO"=@PhoneNumber, 
      "MAIL"=@Email, 
      "ORGANIZACION"=@Organitation
      WHERE "COD_USUARIO"=@COD_USUARIO;
      ''',
        substitutionValues: {
          'COD_USUARIO': COD_USUARIO,
          'Name': Name,
          'Surname1': Surname1,
          'Surname2': Surname2,
          'DateBirth': DateBirth,
          'PhoneNumber': PhoneNumber,
          'Email': Email,
          'Organitation': Organitation,
        },
      );

      // Actualizar la tabla "USUARIO_CUIDADOR"
      await connection!.query(
        '''
      UPDATE "USUARIO_CUIDADOR"
      SET "COD_TIPO_CUIDADOR"=@COD_TIPO_CUIDADOR, "DES_OTROS" = @DES_OTROS
      WHERE "COD_USUARIO"=@COD_USUARIO;
      ''',
        substitutionValues: {
          'COD_USUARIO': COD_USUARIO,
          'COD_TIPO_CUIDADOR': COD_TIPO_CUIDADOR,
          'DES_OTROS': DES_OTROS,
        },
      );

      // Hacer COMMIT de la transacción
      await connection!.query('COMMIT');

      await connection!.close();
      return true;
    } catch (e) {
      await connect();
      // Si ocurre un error, revertir la transacción
      await connection!.query('ROLLBACK');
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que devuelve los usuarios PACIENTES de una Vivienda
  ///***************************************************************************
  Future<List> DBGetPacientesVivienda(COD_CASA, F_BAJA) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      PacienteVivienda = await connection!.query(
        '''
      SELECT 
        "USUARIO_PRIVADO"."COD_USUARIO", 
        "USUARIO_PRIVADO"."NOMBRE", 
        "USUARIO_PRIVADO"."APELLIDO1", 
        "USUARIO_PRIVADO"."APELLIDO2", 
        "USUARIO_PRIVADO"."F_NACIMIENTO", 
        "USUARIO_PRIVADO"."TELEFONO", 
        "USUARIO_PRIVADO"."MAIL", 
        "USUARIO_PRIVADO"."ORGANIZACION",
        MAX("SOCIAL_PACIENTE"."DES_OTROS"), 
        string_agg(DISTINCT 
            CASE
                WHEN "VARIABLES_SOCIALES"."VARIABLES_SOCIALES" = 'Otros' THEN "VARIABLES_SOCIALES"."VARIABLES_SOCIALES" || ' (' || "SOCIAL_PACIENTE"."DES_OTROS" || ')'
                ELSE "VARIABLES_SOCIALES"."VARIABLES_SOCIALES"
            END,
            ', '
        ) AS "VARIABLES_SOCIALES",
        MAX("SANITARIA_PACIENTE"."DES_OTROS"),
        string_agg(DISTINCT 
            CASE
                WHEN "VARIABLES_SANITARIAS"."VARIABLES_SANITARIAS" = 'Otros' THEN "VARIABLES_SANITARIAS"."VARIABLES_SANITARIAS" || ' (' || "SANITARIA_PACIENTE"."DES_OTROS" || ')'
                ELSE "VARIABLES_SANITARIAS"."VARIABLES_SANITARIAS"
            END,
            ', '
        ) as "VARIABLES_SANITARIAS",
        "USUARIO_PRIVADO"."F_ALTA", 
        MAX("PACIENTE_CASA"."F_BAJA")
      FROM "USUARIO_PRIVADO" 
      INNER JOIN "USUARIO_PACIENTE" ON "USUARIO_PRIVADO"."COD_USUARIO" = "USUARIO_PACIENTE"."COD_USUARIO" 
      INNER JOIN "PACIENTE_CASA" ON "USUARIO_PACIENTE"."COD_USUARIO" = "PACIENTE_CASA"."COD_USUARIO" 
      INNER JOIN "SOCIAL_PACIENTE" ON "USUARIO_PACIENTE"."COD_USUARIO" = "SOCIAL_PACIENTE"."COD_USUARIO" 
      INNER JOIN "VARIABLES_SOCIALES" ON "SOCIAL_PACIENTE"."COD_VARIABLES_SOCIALES" = "VARIABLES_SOCIALES"."COD_VARIABLES_SOCIALES" 
      INNER JOIN "SANITARIA_PACIENTE" ON "USUARIO_PACIENTE"."COD_USUARIO" = "SANITARIA_PACIENTE"."COD_USUARIO" 
      INNER JOIN "VARIABLES_SANITARIAS" ON "SANITARIA_PACIENTE"."COD_VARIABLES_SANITARIAS" = "VARIABLES_SANITARIAS"."COD_VARIABLES_SANITARIAS" 
      WHERE "PACIENTE_CASA"."COD_CASA" = @COD_CASA and "PACIENTE_CASA"."F_BAJA" is ''' +
            F_BAJA +
            '''
      GROUP BY "USUARIO_PRIVADO"."COD_USUARIO"
      ''',
        substitutionValues: {'COD_CASA': COD_CASA, 'F_BAJA': F_BAJA},
      );
      await connection!.close();
      print(PacienteVivienda);
      return PacienteVivienda!;
    } catch (e) {
      return [];
    }
  }

  /// ***************************************************************************
  /// Funcion que crea un nuevo usuario Paciente en una vivienda en concreto.
  ///  1º abre la conexion con la base de datos
  ///  2º convierte la contraseña a un hash
  ///  3º inserta los datos en la tabla USUARIO_PRIVADO Y EL resto de tablas
  ///***************************************************************************
  Future DBNewPaciente(
    Name,
    Surname1,
    Surname2,
    DateBirth,
    PhoneNumber,
    Email,
    Organitation,
    Password,
    COD_CASA,
    COD_VARIABLES_SANITARIAS_LIST,
    COD_VARIABLES_SOCIALES_LIST,
    DES_OTROS_SANITARIO,
    DES_OTROS_SOCIAL,
  ) async {
    try {
      await connect();
      var PasswordHash = sha256.convert(utf8.encode(Password)).toString();
      // Insert en USUARIO_PRIVADO
      NewPaciente = await connection!.query(
        '''
        WITH first_insert AS (
            INSERT INTO "USUARIO_PRIVADO"
            ("NOMBRE", "APELLIDO1", "APELLIDO2", "F_NACIMIENTO", "TELEFONO", "MAIL", "PASSWORD")
            VALUES (@Name, @Surname1, @Surname2, @DateBirth, @PhoneNumber, @Email, @Password)
            RETURNING "COD_USUARIO"
        ),
        second_insert AS(
            INSERT INTO "USUARIO_PACIENTE" ("COD_USUARIO")
            SELECT "COD_USUARIO" FROM first_insert
            RETURNING "COD_USUARIO"
        ),
        third_insert AS (
            INSERT INTO "PACIENTE_CASA" ("COD_USUARIO", "COD_CASA")
            SELECT "COD_USUARIO", @COD_CASA FROM second_insert
        ),
        fourth_insert AS (
            INSERT INTO "SOCIAL_PACIENTE" ("COD_USUARIO", "DES_OTROS", "COD_VARIABLES_SOCIALES")
            select "COD_USUARIO", @DES_OTROS_SOCIAL, v."COD_VARIABLES_SOCIALES"
            from second_insert, unnest(@COD_VARIABLES_SOCIALES_LIST::integer[]) v("COD_VARIABLES_SOCIALES")
            where v."COD_VARIABLES_SOCIALES" is not null
        ),
        fifth_insert AS (
            INSERT INTO "SANITARIA_PACIENTE" ("COD_USUARIO", "DES_OTROS", "COD_VARIABLES_SANITARIAS")
            select "COD_USUARIO", @DES_OTROS_SANITARIO, v."COD_VARIABLE_SANITARIA"
            from second_insert, unnest(@COD_VARIABLES_SANITARIAS_LIST::integer[]) v("COD_VARIABLE_SANITARIA")
            where v."COD_VARIABLE_SANITARIA" is not null
        )
        SELECT * FROM second_insert;
        ''',
        substitutionValues: {
          'Name': Name,
          'Surname1': Surname1,
          'Surname2': Surname2,
          'DateBirth': DateBirth,
          'PhoneNumber': PhoneNumber,
          'Email': Email,
          'Password': PasswordHash,
          'Organitation': Organitation,
          'COD_CASA': COD_CASA,
          'COD_VARIABLES_SANITARIAS_LIST': COD_VARIABLES_SANITARIAS_LIST,
          'COD_VARIABLES_SOCIALES_LIST': COD_VARIABLES_SOCIALES_LIST,
          'DES_OTROS_SANITARIO': DES_OTROS_SANITARIO,
          'DES_OTROS_SOCIAL': DES_OTROS_SOCIAL,
        },
      );
      await connection!.close();
      return true;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que Modifica el paciente en una vivienda en concreto.
  ///***************************************************************************
  Future DBModPaciente(
    COD_USUARIO,
    Name,
    Surname1,
    Surname2,
    DateBirth,
    PhoneNumber,
    Email,
    Organitation,
    COD_VARIABLES_SANITARIAS_LIST,
    COD_VARIABLES_SOCIALES_LIST,
    DES_OTROS_SANITARIO,
    DES_OTROS_SOCIAL,
  ) async {
    try {
      await connect();
      await connection!.query('BEGIN');
      // Insert en USUARIO_PRIVADO
      NewPaciente = await connection!.query(
        '''
        UPDATE "USUARIO_PRIVADO"
        SET "NOMBRE" = @Name, 
        "APELLIDO1" = @Surname1, 
        "APELLIDO2" = @Surname2, 
        "F_NACIMIENTO" = @DateBirth, 
        "TELEFONO" = @PhoneNumber, 
        "MAIL" = @Email
        WHERE "COD_USUARIO" = @COD_USUARIO;
        ''',
        substitutionValues: {
          'COD_USUARIO': COD_USUARIO,
          'Name': Name,
          'Surname1': Surname1,
          'Surname2': Surname2,
          'DateBirth': DateBirth,
          'PhoneNumber': PhoneNumber,
          'Email': Email,
          'Organitation': Organitation,
        },
      );
      // Eliminar los COD_VARIABLES_SOCIALES_LIST
      await connection!.query(
        '''
        DELETE FROM "SOCIAL_PACIENTE"
          WHERE "COD_USUARIO"=@COD_USUARIO;
        ''',
        substitutionValues: {'COD_USUARIO': COD_USUARIO},
      );
      //Insertar los COD_VARIABLES_SOCIALES_LIST nuevos
      for (final COD_VARIABLES_SOCIALES in COD_VARIABLES_SOCIALES_LIST) {
        if (COD_VARIABLES_SOCIALES == 0) {
          await connection!.query(
            'INSERT INTO "SOCIAL_PACIENTE" ("COD_VARIABLES_SOCIALES", "COD_USUARIO", "DES_OTROS") '
            'VALUES (@COD_VARIABLES_SOCIALES, @COD_USUARIO, @DES_OTROS_SOCIAL)',
            substitutionValues: {
              'COD_VARIABLES_SOCIALES': COD_VARIABLES_SOCIALES,
              'COD_USUARIO': COD_USUARIO,
              'DES_OTROS_SOCIAL': DES_OTROS_SOCIAL,
            },
          );
        } else {
          await connection!.query(
            'INSERT INTO "SOCIAL_PACIENTE" ("COD_VARIABLES_SOCIALES", "COD_USUARIO") '
            'VALUES (@COD_VARIABLES_SOCIALES, @COD_USUARIO)',
            substitutionValues: {
              'COD_VARIABLES_SOCIALES': COD_VARIABLES_SOCIALES,
              'COD_USUARIO': COD_USUARIO,
            },
          );
        }
      }
      // Eliminar los COD_VARIABLES_SANITARIAS_LIST
      await connection!.query(
        '''
        DELETE FROM "SANITARIA_PACIENTE"
          WHERE "COD_USUARIO"=@COD_USUARIO;
        ''',
        substitutionValues: {'COD_USUARIO': COD_USUARIO},
      );
      //Insertar los COD_VARIABLES_SANITARIAS_LIST nuevos
      for (final COD_VARIABLES_SANITARIAS in COD_VARIABLES_SANITARIAS_LIST) {
        if (COD_VARIABLES_SANITARIAS == 0) {
          await connection!.query(
            'INSERT INTO "SANITARIA_PACIENTE" ("COD_VARIABLES_SANITARIAS", "COD_USUARIO", "DES_OTROS") '
            'VALUES (@COD_VARIABLES_SANITARIAS, @COD_USUARIO, @DES_OTROS_SANITARIO)',
            substitutionValues: {
              'COD_VARIABLES_SANITARIAS': COD_VARIABLES_SANITARIAS,
              'COD_USUARIO': COD_USUARIO,
              'DES_OTROS_SANITARIO': DES_OTROS_SANITARIO,
            },
          );
        } else {
          await connection!.query(
            'INSERT INTO "SANITARIA_PACIENTE" ("COD_VARIABLES_SANITARIAS", "COD_USUARIO") '
            'VALUES (@COD_VARIABLES_SANITARIAS, @COD_USUARIO)',
            substitutionValues: {
              'COD_VARIABLES_SANITARIAS': COD_VARIABLES_SANITARIAS,
              'COD_USUARIO': COD_USUARIO,
            },
          );
        }
      }
      await connection!.query('COMMIT');
      await connection!.close();
      return true;
    } catch (e) {
      await connect();
      await connection!.query('ROLLBACK');
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que Modifica el El usuario Administrador
  ///***************************************************************************
  Future DBModUserAdmin(
    COD_USUARIO,
    Name,
    Surname1,
    Surname2,
    PhoneNumber,
    Email,
    ORGANIZACION,
  ) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      NewPaciente = await connection!.query(
        '''
        UPDATE "USUARIO_PRIVADO"
        SET "NOMBRE" = @Name, 
        "APELLIDO1" = @Surname1, 
        "APELLIDO2" = @Surname2,
        "TELEFONO" = @PhoneNumber, 
        "MAIL" = @Email,
        "ORGANIZACION" = @ORGANIZACION
        WHERE "COD_USUARIO" = @COD_USUARIO;
        ''',
        substitutionValues: {
          'COD_USUARIO': COD_USUARIO,
          'Name': Name,
          'Surname1': Surname1,
          'Surname2': Surname2,
          'PhoneNumber': PhoneNumber,
          'Email': Email,
          'ORGANIZACION': ORGANIZACION,
        },
      );
      await connection!.close();
      return true;
    } catch (e) {
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que devuelve las Wearable de un Paciente
  ///***************************************************************************
  Future<List> DBGetWearable(COD_USUARIO, STATUS) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      // AÑADIDO CCN "PACIENTE_WEARABLE"."COD_PACIENTE_WEARABLE",
      Wearable = await connection!.query(
        '''
           select
                "WEARABLE"."COD_WEARABLE",
                "WEARABLE"."ID_WEARABLE",
                "PACIENTE_WEARABLE"."COD_USUARIO",
                "PACIENTE_WEARABLE"."COD_PACIENTE_WEARABLE",
                "TIPO_WEARABLE"."TIPO_WEARABLE",
                "PACIENTE_WEARABLE"."F_ALTA",
                "PACIENTE_WEARABLE"."F_BAJA",
                "WEARABLE"."DES_OTROS",
                "WEARABLE"."COD_TIPO_WEARABLE"
                
           from
               "WEARABLE"
           inner join "TIPO_WEARABLE" on
               "WEARABLE"."COD_TIPO_WEARABLE" = "TIPO_WEARABLE"."COD_TIPO_WEARABLE"
           inner join "PACIENTE_WEARABLE" on
               "WEARABLE"."COD_WEARABLE" = "PACIENTE_WEARABLE"."COD_WEARABLE"
           WHERE "PACIENTE_WEARABLE"."COD_USUARIO" = @COD_USUARIO 
           and "PACIENTE_WEARABLE"."F_BAJA" is null
           and "WEARABLE"."F_BAJA" is null
        ''',
        substitutionValues: {
          'COD_USUARIO': COD_USUARIO,
          "STATUS_PACIENTE_WEARABLE": STATUS,
          'STATUS_WEARABLE': 'ACTIVO',
        },
      );
      print(Wearable);
      await connection!.close();
      return Wearable!;
    } catch (e) {
      return [];
    }
  }

  /// ***************************************************************************
  /// Funcion que devuelve todos los Sensores, sin repertirse y con la ultima
  /// fecha de alta y baja,
  ///***************************************************************************
  Future<List> DBGetTodoWarable(FechaBaja) async {
    try {
      await connect();

      var PacienteWearableQuery = '''
      select
          "USUARIO_PRIVADO"."COD_USUARIO",
          "USUARIO_PRIVADO"."NOMBRE",
          "USUARIO_PRIVADO"."APELLIDO1",
          "USUARIO_PRIVADO"."APELLIDO2",
          "USUARIO_PRIVADO"."F_NACIMIENTO",
          "USUARIO_PRIVADO"."TELEFONO",
          "USUARIO_PRIVADO"."MAIL",
          "USUARIO_PRIVADO"."ORGANIZACION",
          "PACIENTE_WEARABLE"."COD_WEARABLE"
      from
          "PACIENTE_WEARABLE"
      inner join "USUARIO_PACIENTE" on
          "PACIENTE_WEARABLE"."COD_USUARIO" = "USUARIO_PACIENTE"."COD_USUARIO"
      inner join "USUARIO_PRIVADO" on
          "USUARIO_PACIENTE"."COD_USUARIO" = "USUARIO_PRIVADO"."COD_USUARIO"
      where "PACIENTE_WEARABLE"."F_BAJA" is null and "USUARIO_PRIVADO"."F_BAJA" is null
      ''';
      PacienteWearable = await connection!.query(PacienteWearableQuery);

      var TodoWearableQuery =
          '''
      select
          public."WEARABLE"."COD_WEARABLE",
          public."WEARABLE"."ID_WEARABLE",
          public."WEARABLE"."DES_OTROS",
          public."WEARABLE"."COD_TIPO_WEARABLE",
          public."TIPO_WEARABLE"."TIPO_WEARABLE",
          public."WEARABLE"."F_ALTA",
          public."WEARABLE"."F_BAJA"
      from
          public."WEARABLE"
      inner join public."TIPO_WEARABLE" on
          public."WEARABLE"."COD_TIPO_WEARABLE" = public."TIPO_WEARABLE"."COD_TIPO_WEARABLE"
      where
          "WEARABLE"."F_BAJA" is ''' +
          FechaBaja +
          '''
      order by
          "WEARABLE"."ID_WEARABLE" asc
      ''';

      TodoWearable = await connection!.query(TodoWearableQuery);
      // Insert en USUARIO_PRIVADO
      // TodoWearable = await connection!.query(
      //   '''
      //   select
      //       MAX("WEARABLE"."COD_WEARABLE"),
      //       "WEARABLE"."ID_WEARABLE",
      //       "WEARABLE"."DES_OTROS",
      //       "WEARABLE"."F_ALTA",
      //       "WEARABLE"."F_BAJA",
      //       "TIPO_WEARABLE"."TIPO_WEARABLE",
      //       MAX("PACIENTE_WEARABLE"."F_ALTA") as "F_ALTA",
      //       MAX("PACIENTE_WEARABLE"."F_BAJA") as "F_BAJA",
      //       MAX("PACIENTE_WEARABLE"."COD_USUARIO"),
      //       MAX("USUARIO_PRIVADO"."NOMBRE"),
      //       MAX("USUARIO_PRIVADO"."APELLIDO1"),
      //       MAX("USUARIO_PRIVADO"."APELLIDO2"),
      //       MAX("USUARIO_PRIVADO"."MAIL"),
      //       MAX("USUARIO_PRIVADO"."TELEFONO"),
      //       MAX("USUARIO_PRIVADO"."F_NACIMIENTO"),
      //       string_agg(distinct "VARIABLES_SOCIALES"."VARIABLES_SOCIALES", ', ') as "VARIABLES_SOCIALES",
      //       string_agg(distinct "VARIABLES_SANITARIAS"."VARIABLES_SANITARIAS", ', ') as "VARIABLES_SANITARIAS",
      //       MAX("SANITARIA_PACIENTE"."DES_OTROS"),
      //       MAX("SOCIAL_PACIENTE"."DES_OTROS")
      //   from
      //       "WEARABLE"
      //   inner join "TIPO_WEARABLE" on
      //       "WEARABLE"."COD_TIPO_WEARABLE" = "TIPO_WEARABLE"."COD_TIPO_WEARABLE"
      //   left join "PACIENTE_WEARABLE" on
      //       "WEARABLE"."COD_WEARABLE" = "PACIENTE_WEARABLE"."COD_WEARABLE"
      //   inner join public."USUARIO_PACIENTE" on
      //       "PACIENTE_WEARABLE"."COD_USUARIO" = public."USUARIO_PACIENTE"."COD_USUARIO"
      //   inner join public."USUARIO_PRIVADO" on
      //       public."USUARIO_PACIENTE"."COD_USUARIO" = public."USUARIO_PRIVADO"."COD_USUARIO"
      //   inner join public."SOCIAL_PACIENTE" on
      //       public."USUARIO_PACIENTE"."COD_USUARIO" = public."SOCIAL_PACIENTE"."COD_USUARIO"
      //   inner join public."SANITARIA_PACIENTE" on
      //       public."USUARIO_PACIENTE"."COD_USUARIO" = public."SANITARIA_PACIENTE"."COD_USUARIO"
      //   inner join public."VARIABLES_SANITARIAS" on
      //       public."SANITARIA_PACIENTE"."COD_VARIABLES_SANITARIAS" = public."VARIABLES_SANITARIAS"."COD_VARIABLES_SANITARIAS"
      //   inner join public."VARIABLES_SOCIALES" on
      //       public."SOCIAL_PACIENTE"."COD_VARIABLES_SOCIALES" = public."VARIABLES_SOCIALES"."COD_VARIABLES_SOCIALES"
      //   group by
      //       ( ("WEARABLE"."ID_WEARABLE",
      //       "WEARABLE"."DES_OTROS",
      //       "WEARABLE"."F_ALTA",
      //       "WEARABLE"."F_BAJA",
      //       "TIPO_WEARABLE"."TIPO_WEARABLE"),
      //       "WEARABLE"."ID_WEARABLE",
      //       "WEARABLE"."DES_OTROS",
      //       "WEARABLE"."F_ALTA",
      //       "WEARABLE"."F_BAJA",
      //       "TIPO_WEARABLE"."TIPO_WEARABLE" )
      //   having
      //       (MAX("PACIENTE_WEARABLE"."F_BAJA") is not null
      //           or MAX("PACIENTE_WEARABLE"."F_BAJA") is null)
      //       and "WEARABLE"."F_BAJA" is ''' +
      //       FechaBaja +
      //       '''
      //   order by
      //       "WEARABLE"."ID_WEARABLE" asc;
      //   ''',
      //);
      print(TodoWearable);
      await connection!.close();
      return [PacienteWearable!, TodoWearable!];
      //return TodoWearable!;
    } catch (e) {
      await connection!.close();
      return [];
    }
  }

  /// ***************************************************************************
  /// Funcion que crea un nuevo wearable a un paciente en la base de datos.
  ///  1º abre la conexion con la base de datos
  ///  2º inserta los dator en la tabla Wearable con el codigo de paciente
  ///  correspondiente
  ///***************************************************************************
  Future DBAnagdirWearable(
    ID_WEARABLE,
    COD_USUARIO,
    COD_TIPO_WEARABLE,
    DES_OTROS,
  ) async {
    try {
      await connect();
      await connection!.transaction((ctx) async {
        var insertWearable = '''
        
          WITH first_insert AS(
            INSERT INTO "WEARABLE"
              ("ID_WEARABLE", "COD_TIPO_WEARABLE", "DES_OTROS")
              VALUES(@ID_WEARABLE, @COD_TIPO_WEARABLE, @DES_OTROS)
              RETURNING "COD_WEARABLE"
          )
          INSERT INTO "PACIENTE_WEARABLE"
            ("COD_USUARIO", "COD_WEARABLE")
            VALUES(@COD_USUARIO, (SELECT "COD_WEARABLE" FROM first_insert))
          RETURNING "COD_PACIENTE_WEARABLE";
          ''';
        var NewWearable = await ctx.query(
          insertWearable,
          substitutionValues: {
            'ID_WEARABLE': ID_WEARABLE,
            'COD_USUARIO': COD_USUARIO,
            'COD_TIPO_WEARABLE': COD_TIPO_WEARABLE,
            'DES_OTROS': DES_OTROS,
          },
        );
      });
      await connection!.close();
      return true;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  // Future DBAnagdirWearable(
  //     ID_WEARABLE, COD_USUARIO, COD_TIPO_WEARABLE, DES_OTROS) async {
  //   try {
  //     await connect();
  //     var insertWearable = '''

  //       WITH first_insert AS(
  //         INSERT INTO "WEARABLE"
  //           ("ID_WEARABLE", "COD_TIPO_WEARABLE", "DES_OTROS")
  //           VALUES(@ID_WEARABLE, @COD_TIPO_WEARABLE, @DES_OTROS)
  //           RETURNING "COD_WEARABLE"
  //       )
  //       INSERT INTO "PACIENTE_WEARABLE"
  //         ("COD_USUARIO", "COD_WEARABLE")
  //         VALUES(@COD_USUARIO, (SELECT "COD_WEARABLE" FROM first_insert))
  //       RETURNING "COD_PACIENTE_WEARABLE";
  //       ''';
  //     var NewWearable = await connection!.query(
  //       insertWearable,
  //       substitutionValues: {
  //         'ID_WEARABLE': ID_WEARABLE,
  //         'COD_USUARIO': COD_USUARIO,
  //         'COD_TIPO_WEARABLE': COD_TIPO_WEARABLE,
  //         'DES_OTROS': DES_OTROS
  //       },
  //     );
  //     // if (NewWearable.length > 0) {
  //     //   print('Escrito');
  //     // } else {
  //     //   print('No Escrito');
  //     // }
  //     return true;
  //   } catch (e) {
  //     return e;
  //   }
  // }

  /// ***************************************************************************
  /// Funcion que crea un nuevo wearable en la base de datos.
  ///  1º abre la conexion con la base de datos
  ///  2º inserta los dator en la tabla Sensor con el codigo de paciente
  ///  correspondiente
  ///***************************************************************************
  Future DBAnagdirWearableNuevo(
    ID_WEARABLE,
    COD_TIPO_WEARABLE,
    DES_OTROS,
  ) async {
    try {
      await connect();
      var insertWearable = '''        
        INSERT INTO "WEARABLE"
        ("ID_WEARABLE", "DES_OTROS", "COD_TIPO_WEARABLE")
        VALUES( @ID_WEARABLE, @DES_OTROS, @COD_TIPO_WEARABLE);
        ''';
      var NewWearable = await connection!.execute(
        insertWearable,
        substitutionValues: {
          'ID_WEARABLE': ID_WEARABLE,
          'COD_TIPO_WEARABLE': COD_TIPO_WEARABLE,
          'DES_OTROS': DES_OTROS,
        },
      );
      await connection!.close();
      return true;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que añade un cuidador existente a un paciente
  ///***************************************************************************
  Future<dynamic> DBAnagdirCuidadorExist(COD_CASA, COD_USUARIO) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      NewPaciente = await connection!.query(
        '''
        INSERT INTO "CUIDADOR_CASA"
          ("COD_USUARIO", "COD_CASA")
          VALUES(@COD_USUARIO, @COD_CASA);
        ''',
        substitutionValues: {'COD_CASA': COD_CASA, 'COD_USUARIO': COD_USUARIO},
      );
      await connection!.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// ***************************************************************************
  /// Funcion que crea un nuevo usuario cuidador en la base de datos.
  ///  1º abre la conexion con la base de datos
  ///  2º convierte la contraseña a un hash
  ///  3º inserta los datos en la tabla USUARIO_PRIVADO y USUARIO_CUIDADOR
  ///***************************************************************************
  Future DBNewCuidador(
    Name,
    Surname1,
    Surname2,
    DateBirth,
    PhoneNumber,
    Email,
    Organitation,
    Password,
  ) async {
    try {
      await connect();
      var PasswordHash = sha256.convert(utf8.encode(Password)).toString();
      // Insert en USUARIO_PRIVADO
      NewCuidador = await connection!.query(
        'with first_insert as (INSERT INTO "USUARIO_PRIVADO"'
        '("NOMBRE", "APELLIDO1", "APELLIDO2", "F_NACIMIENTO", "TELEFONO", "MAIL", "PASSWORD", "ORGANIZACION")'
        'VALUES (@Name, @Surname1, @Surname2, @DateBirth, @PhoneNumber, @Email, @Password, @Organitation)'
        'returning "COD_USUARIO")'
        'insert into "USUARIO_CUIADOR" ("COD_USUARIO")'
        'select first_insert."COD_USUARIO" from first_insert',
        substitutionValues: {
          'Name': Name,
          'Surname1': Surname1,
          'Surname2': Surname2,
          'DateBirth': DateBirth,
          'PhoneNumber': PhoneNumber,
          'Email': Email,
          'Password': PasswordHash,
          'Organitation': Organitation,
        },
      );
      await connection!.close();
      return true;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que añade un paceinte a una casa
  ///***************************************************************************
  Future<String> DBAddPaciente(COD_USUARIO, COD_CASA) async {
    try {
      await connect();
      var Insert = '''
      INSERT INTO "PACIENTE_CASA" ("COD_USUARIO", "COD_CASA") 
      VALUES (@COD_USUARIO, @COD_CASA);
    ''';
      var addPaciente = await connection!.execute(
        Insert,
        substitutionValues: {"COD_USUARIO": COD_USUARIO, "COD_CASA": COD_CASA},
      );
      await connection!.close();
      return 'Correcto';
    } catch (e) {
      print(e);
      await connection!.close();
      return 'error';
    }
    // try {
    //   await connect();
    //   var Insert = '''
    //       UPDATE "PACIENTE_CASA"
    //       SET "F_BAJA" =NULL
    //       WHERE "COD_USUARIO" = @COD_USUARIO and "COD_CASA" = @COD_CASA;
    //       ''';
    //   var addPaciente = await connection!.execute(
    //     Insert,
    //     substitutionValues: {
    //       "COD_USUARIO": COD_USUARIO,
    //       "COD_CASA": COD_CASA,
    //     },
    //   );
    //   await connection!.close();
    //   return 'Correcto';
    // } catch (e) {
    //   print(e);
    //   await connection!.close();
    //   return 'error';
    // }
  }

  /// ***************************************************************************
  /// Funcion que Activar o Desactivar un usuario Cuidador
  ///***************************************************************************
  Future<String> DBActDesActCuidador(COD_USUARIO, F_BAJA) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      var Update = '''
          UPDATE "USUARIO_PRIVADO" SET "F_BAJA" = 
              CASE 
                WHEN @F_BAJA IS NULL THEN NULL 
                WHEN @F_BAJA = 'CURRENT_TIMESTAMP' THEN CURRENT_TIMESTAMP                 
              END 
          WHERE "COD_USUARIO" = @COD_USUARIO
          ''';
      var ActDesActCuidador = await connection!.execute(
        Update,
        substitutionValues: {"COD_USUARIO": COD_USUARIO, "F_BAJA": F_BAJA},
      );
      await connection!.close();
      if (ActDesActCuidador != 0) {
        return 'Correcto';
      } else {
        return 'incorrecto';
      }
    } catch (e) {
      return 'error';
    }
  }

  Future DBInsertCuidadorCasa(COD_USUARIO, COD_CASA) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      var Update = '''
          INSERT INTO "CUIDADOR_CASA"
          ("COD_USUARIO", "COD_CASA")
          VALUES(@COD_USUARIO, @COD_CASA);

          ''';
      var InsertCuidadorCasa = await connection!.execute(
        Update,
        substitutionValues: {"COD_USUARIO": COD_USUARIO, "COD_CASA": COD_CASA},
      );
      await connection!.close();
      if (InsertCuidadorCasa != 0) {
        return true;
      } else {
        return 'incorrecto';
      }
    } catch (e) {
      return 'error';
    }
  }

  Future DBGetCuidadorCasa() async {
    try {
      await connect();
      var CuidadorCasa = await connection!.query('''
        select
            "CUIDADOR_CASA"."COD_USUARIO",
            "CUIDADOR_CASA"."COD_CASA"
        from
            "CUIDADOR_CASA"
        ''');
      await connection!.close();
      return CuidadorCasa;
    } catch (e) {
      await connection!.close();
      return e;
    }
  }

  /// ***************************************************************************
  /// Funcion que devuelve los usuarios Cuidadores
  ///***************************************************************************
  Future<List> DBGetCuidador(fechaBajaCuidador) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      var cuidador_query =
          '''
        select
            "USUARIO_PRIVADO"."COD_USUARIO",
            "USUARIO_PRIVADO"."NOMBRE",
            "USUARIO_PRIVADO"."APELLIDO1",
            "USUARIO_PRIVADO"."APELLIDO2",
            "USUARIO_PRIVADO"."F_NACIMIENTO",
            "USUARIO_PRIVADO"."TELEFONO",
            "USUARIO_PRIVADO"."MAIL",
            "USUARIO_PRIVADO"."ORGANIZACION",
            "USUARIO_PRIVADO"."F_ALTA",
            "USUARIO_PRIVADO"."F_BAJA",
            "CUIDADOR_CASA"."COD_CASA"
        from
            "USUARIO_CUIDADOR"
        inner join "USUARIO_PRIVADO" on
            "USUARIO_CUIDADOR"."COD_USUARIO" = "USUARIO_PRIVADO"."COD_USUARIO"
        left join "CUIDADOR_CASA" on
            "USUARIO_CUIDADOR"."COD_USUARIO" = "CUIDADOR_CASA"."COD_USUARIO"
        where
        "USUARIO_PRIVADO"."F_BAJA" is ''' +
          fechaBajaCuidador +
          '''
        order by
        "USUARIO_PRIVADO"."NOMBRE" ASC
        ''';
      Cuidador = await connection!.query(cuidador_query);

      var casa_query = '''
        SELECT
          "CUIDADOR_CASA"."COD_USUARIO",
          "CUIDADOR_CASA"."COD_CASA",
          "CASA"."DIRECCION" || ', ' || "CASA"."NUMERO" || ', ' || "CASA"."PISO" || '' || "CASA"."PUERTA" || ', ' || "CASA"."LOCALIDAD" || ', ' || "CASA"."PROVINCIA" || ', ' || "CASA"."PAIS" || ', ' || "CASA"."COD_POSTAL"
          
        FROM
          "CUIDADOR_CASA"
          INNER JOIN "CASA" ON
            "CUIDADOR_CASA"."COD_CASA" = "CASA"."COD_CASA"
        WHERE
           "CUIDADOR_CASA"."F_BAJA" IS NULL
        ''';
      CuidadorCasa = await connection!.query(casa_query);

      var pacientes_query = '''
        select
            "USUARIO_PRIVADO"."COD_USUARIO",
            "USUARIO_PRIVADO"."NOMBRE",
            "USUARIO_PRIVADO"."APELLIDO1",
            "USUARIO_PRIVADO"."APELLIDO2",
            "USUARIO_PRIVADO"."F_NACIMIENTO",
            "USUARIO_PRIVADO"."TELEFONO",
            "USUARIO_PRIVADO"."MAIL",
            "USUARIO_PRIVADO"."ORGANIZACION",
            "USUARIO_PRIVADO"."F_ALTA",
            "USUARIO_PRIVADO"."F_BAJA",
            "CASA"."COD_CASA"
        from
            "USUARIO_PACIENTE"
        inner join "USUARIO_PRIVADO" on
            "USUARIO_PACIENTE"."COD_USUARIO" = "USUARIO_PRIVADO"."COD_USUARIO"
        inner join "PACIENTE_CASA" on
            "USUARIO_PACIENTE"."COD_USUARIO" = "PACIENTE_CASA"."COD_USUARIO"
        inner join "CASA" on
            "PACIENTE_CASA"."COD_CASA" = "CASA"."COD_CASA"
        where "USUARIO_PRIVADO"."F_BAJA" is null and "PACIENTE_CASA"."F_BAJA" is null;
        ''';
      PacientesCuidador = await connection!.query(pacientes_query);
      var TodoCuidadoresQuery =
          '''
        select
            "USUARIO_PRIVADO"."COD_USUARIO",
            "USUARIO_PRIVADO"."NOMBRE",
            "USUARIO_PRIVADO"."APELLIDO1",
            "USUARIO_PRIVADO"."APELLIDO2",
            "USUARIO_PRIVADO"."F_NACIMIENTO",
            "USUARIO_PRIVADO"."TELEFONO",
            "USUARIO_PRIVADO"."MAIL",
            "USUARIO_PRIVADO"."ORGANIZACION",
            "USUARIO_PRIVADO"."F_ALTA",
            "USUARIO_PRIVADO"."F_BAJA"
        from
        	"USUARIO_CUIDADOR"
        inner join "USUARIO_PRIVADO" on
        	"USUARIO_CUIDADOR"."COD_USUARIO" = "USUARIO_PRIVADO"."COD_USUARIO"
        where
        	"USUARIO_PRIVADO"."F_BAJA" is ''' +
          fechaBajaCuidador +
          '''
        order by
              "USUARIO_PRIVADO"."NOMBRE" ASC

        ''';
      TodosCuidadores = await connection!.query(TodoCuidadoresQuery);

      print(Cuidador);

      print(Cuidador);
      print(CuidadorCasa);
      await connection!.close(); //return Cuidador!;
      return [Cuidador, CuidadorCasa!, PacientesCuidador!, TodosCuidadores];
    } catch (e) {
      return [];
    }
  }

  /// ***************************************************************************
  /// Funcion que devuelve los usuarios Pacientes con sus respectivas viviendas
  ///***************************************************************************
  Future<List> DBGetPacientes() async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      Paciente = await connection!.query('''
        select
            "USUARIO_PRIVADO"."COD_USUARIO",
            "USUARIO_PRIVADO"."NOMBRE",
            "USUARIO_PRIVADO"."APELLIDO1",
            "USUARIO_PRIVADO"."APELLIDO2",
            "USUARIO_PRIVADO"."F_NACIMIENTO",
            "USUARIO_PRIVADO"."TELEFONO",
            "USUARIO_PRIVADO"."MAIL",
            "USUARIO_PRIVADO"."ORGANIZACION",
            "USUARIO_PRIVADO"."F_ALTA",
            "USUARIO_PRIVADO"."F_BAJA",
            MAX("CASA"."DIRECCION"),
            MAX("CASA"."NUMERO"),
            MAX("CASA"."PISO"),
            MAX("CASA"."PUERTA"),
            MAX("CASA"."LOCALIDAD"),
            MAX("CASA"."PROVINCIA"),
            string_agg(DISTINCT 
                CASE
                    WHEN "VARIABLES_SOCIALES"."VARIABLES_SOCIALES" = 'Otros' THEN "VARIABLES_SOCIALES"."VARIABLES_SOCIALES" || ' (' || "SOCIAL_PACIENTE"."DES_OTROS" || ')'
                    ELSE "VARIABLES_SOCIALES"."VARIABLES_SOCIALES"
                END,
                ', '
            ) AS "VARIABLES_SOCIALES",
            string_agg(DISTINCT 
                CASE
                    WHEN "VARIABLES_SANITARIAS"."VARIABLES_SANITARIAS" = 'Otros' THEN "VARIABLES_SANITARIAS"."VARIABLES_SANITARIAS" || ' (' || "SANITARIA_PACIENTE"."DES_OTROS" || ')'
                    ELSE "VARIABLES_SANITARIAS"."VARIABLES_SANITARIAS"
                END,
                ', '
            ) as "VARIABLES_SANITARIAS",
            MAX("PACIENTE_CASA"."F_BAJA")
        from
            "USUARIO_PRIVADO"
        inner join "USUARIO_PACIENTE" on
            "USUARIO_PRIVADO"."COD_USUARIO" = "USUARIO_PACIENTE"."COD_USUARIO"
        inner join "PACIENTE_CASA" on
            "USUARIO_PACIENTE"."COD_USUARIO" = "PACIENTE_CASA"."COD_USUARIO"
        inner join "SOCIAL_PACIENTE" on
            "USUARIO_PACIENTE"."COD_USUARIO" = "SOCIAL_PACIENTE"."COD_USUARIO"
        inner join "VARIABLES_SOCIALES" on
            "SOCIAL_PACIENTE"."COD_VARIABLES_SOCIALES" = "VARIABLES_SOCIALES"."COD_VARIABLES_SOCIALES"
        inner join "SANITARIA_PACIENTE" on
            "USUARIO_PACIENTE"."COD_USUARIO" = "SANITARIA_PACIENTE"."COD_USUARIO"
        inner join "VARIABLES_SANITARIAS" on
            "SANITARIA_PACIENTE"."COD_VARIABLES_SANITARIAS" = "VARIABLES_SANITARIAS"."COD_VARIABLES_SANITARIAS"
        inner join public."CASA" on
            "PACIENTE_CASA"."COD_CASA" = public."CASA"."COD_CASA"
        GROUP BY "USUARIO_PRIVADO"."COD_USUARIO"
      ''');
      print(Paciente);
      await connection!.close();
      return Paciente!;
    } catch (e) {
      return [];
    }
  }

  /// ***************************************************************************
  /// Funcion que Activar o Desactivar unA habitacion de una vivienda junto con
  /// los sensores que tenga asociados para que se puedan tulizar en
  /// otra vivienda
  ///***************************************************************************
  Future<String> DBActDesActHabitacion(
    COD_CASA,
    COD_HABITACION,
    F_BAJA_HABITACION,
    F_BAJA_SENSOR,
  ) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      var Update = '''
            BEGIN TRANSACTION;
            UPDATE "HABITACION"
            SET "F_BAJA" = 
              CASE 
                WHEN @F_BAJA_HABITACION IS NULL THEN NULL 
                WHEN @F_BAJA_HABITACION = 'CURRENT_TIMESTAMP' THEN CURRENT_TIMESTAMP 
                
              END
            WHERE "HABITACION"."COD_CASA" = @COD_CASA AND "HABITACION"."COD_HABITACION" = @COD_HABITACION;
            UPDATE "HABITACION_SENSOR"
            SET "F_BAJA" = 
              CASE 
                WHEN @F_BAJA_SENSOR IS NULL THEN NULL 
                WHEN @F_BAJA_SENSOR = 'CURRENT_TIMESTAMP' THEN CURRENT_TIMESTAMP                 
              END
            WHERE "HABITACION_SENSOR"."COD_HABITACION" = @COD_HABITACION
            AND ("F_BAJA", "COD_HABITACION") NOT IN (
            SELECT "F_BAJA", "COD_HABITACION"
            FROM "HABITACION_SENSOR"
            WHERE "COD_HABITACION" = @COD_HABITACION
            AND "F_BAJA" =   
              CASE 
                WHEN @F_BAJA_SENSOR IS NULL THEN NULL 
                WHEN @F_BAJA_SENSOR = 'CURRENT_TIMESTAMP' THEN CURRENT_TIMESTAMP              
              END
            );
            COMMIT TRANSACTION;
            ''';
      var ActDesActHabitacion = await connection!.execute(
        Update,
        substitutionValues: {
          "COD_CASA": COD_CASA,
          "COD_HABITACION": COD_HABITACION,
          "F_BAJA_HABITACION": F_BAJA_HABITACION,
          "F_BAJA_SENSOR": F_BAJA_SENSOR,
        },
      );
      await connection!.close();
      if (ActDesActHabitacion == 0) {
        return 'Correcto';
      } else {
        return 'incorrecto';
      }
    } catch (e) {
      return 'error';
    }
  }

  /// ***************************************************************************
  /// Funcion que Activar o Desactivar paciente
  ///***************************************************************************
  Future<String> DBActDesActPaciente(
    COD_USUARIO,
    COD_CASA,
    F_BAJA_PACIENTE_CASA,
    F_BAJA_PACIENTE,
    F_BAJA_PACIENTE_WEARABLE,
  ) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      var Update = '''
            BEGIN TRANSACTION;
            UPDATE "USUARIO_PRIVADO"
            SET "F_BAJA" = 
              CASE 
                WHEN @F_BAJA_PACIENTE IS NULL THEN NULL 
                WHEN @F_BAJA_PACIENTE = 'CURRENT_TIMESTAMP' THEN CURRENT_TIMESTAMP 
                
              END
            WHERE "USUARIO_PRIVADO"."COD_USUARIO" = @COD_USUARIO;
            UPDATE "PACIENTE_WEARABLE"
            SET "F_BAJA" = 
              CASE 
                WHEN @F_BAJA_PACIENTE_WEARABLE IS NULL THEN NULL 
                WHEN @F_BAJA_PACIENTE_WEARABLE = 'CURRENT_TIMESTAMP' THEN CURRENT_TIMESTAMP                 
              END
            WHERE "PACIENTE_WEARABLE"."COD_USUARIO" = @COD_USUARIO
            AND ("F_BAJA", "COD_USUARIO") NOT IN (
            SELECT "F_BAJA", "COD_USUARIO"
            FROM "PACIENTE_WEARABLE"
            WHERE "COD_USUARIO" = @COD_USUARIO
            AND "F_BAJA" =  
              CASE 
                WHEN @F_BAJA_PACIENTE_WEARABLE IS NULL THEN NULL 
                WHEN @F_BAJA_PACIENTE_WEARABLE = 'CURRENT_TIMESTAMP' THEN CURRENT_TIMESTAMP              
              END
            );
            UPDATE "PACIENTE_CASA"
            SET "F_BAJA" = 
              CASE 
                WHEN @F_BAJA_PACIENTE_CASA IS NULL THEN NULL 
                WHEN @F_BAJA_PACIENTE_CASA = 'CURRENT_TIMESTAMP' THEN CURRENT_TIMESTAMP                 
              END
            WHERE "PACIENTE_CASA"."COD_USUARIO" = @COD_USUARIO AND "PACIENTE_CASA"."COD_CASA" = @COD_CASA
            AND ("F_BAJA", "COD_USUARIO", "COD_CASA") NOT IN (
            SELECT "F_BAJA", "COD_USUARIO", "COD_CASA"
            FROM "PACIENTE_CASA"
            WHERE "COD_USUARIO" = @COD_USUARIO AND "COD_CASA" = @COD_CASA
            AND "F_BAJA" =  
              CASE 
                WHEN @F_BAJA_PACIENTE_CASA IS NULL THEN NULL 
                WHEN @F_BAJA_PACIENTE_CASA = 'CURRENT_TIMESTAMP' THEN CURRENT_TIMESTAMP              
              END
            );
            COMMIT TRANSACTION;
            ''';
      var ActDesActPaciente = await connection!.execute(
        Update,
        substitutionValues: {
          "COD_USUARIO": COD_USUARIO,
          "COD_CASA": COD_CASA,
          "F_BAJA_PACIENTE": F_BAJA_PACIENTE,
          "F_BAJA_PACIENTE_WEARABLE": F_BAJA_PACIENTE_WEARABLE,
          "F_BAJA_PACIENTE_CASA": F_BAJA_PACIENTE_CASA,
        },
      );
      await connection!.close();
      if (ActDesActPaciente == 0) {
        return 'Correcto';
      } else {
        return 'incorrecto';
      }
    } catch (e) {
      return 'error';
    }
  }

  /// ***************************************************************************
  /// Funcion que Activar o Desactivar una Vivienda junto con los pacientes,
  /// habitaciones, sensores, wearables y cuidadores que tenga asociados.
  ///***************************************************************************
  Future<String> DBActDesActVivienda(
    COD_CASA,
    F_BAJA_CASA,
    F_BAJA_HABITACION,
    F_BAJA_HABITACION_SENSOR,
    F_BAJA_PACIENTE_CASA,
    F_BAJA_PACIENTE_WEARABLE,
    F_BAJA_PRIVADO,
  ) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      var Update = '''
        BEGIN TRANSACTION;
          UPDATE "CASA"
          SET "F_BAJA"=
            CASE 
              WHEN @F_BAJA_CASA IS NULL THEN NULL 
              WHEN @F_BAJA_CASA = 'CURRENT_TIMESTAMP' THEN CURRENT_TIMESTAMP 
            END
          WHERE "COD_CASA"=@COD_CASA;
          DELETE FROM "CUIDADOR_CASA"
          WHERE "COD_CASA"= @COD_CASA;
          WITH UPDATE_HABITACIONES AS (
              UPDATE "HABITACION"
            SET "F_BAJA"=
              CASE 
                WHEN @F_BAJA_HABITACION IS NULL THEN NULL 
                WHEN @F_BAJA_HABITACION = 'CURRENT_TIMESTAMP' THEN CURRENT_TIMESTAMP 
              END
            WHERE "COD_CASA"=@COD_CASA
            RETURNING "COD_HABITACION"
          ) 
          UPDATE "HABITACION_SENSOR"
          SET  "F_BAJA" = 
            CASE 
              WHEN @F_BAJA_HABITACION_SENSOR IS NULL THEN NULL 
              WHEN @F_BAJA_HABITACION_SENSOR = 'CURRENT_TIMESTAMP' THEN CURRENT_TIMESTAMP 
            END
          WHERE "COD_HABITACION" IN (
            SELECT "COD_HABITACION" FROM UPDATE_HABITACIONES
          );
          UPDATE "PACIENTE_CASA" 
        SET "F_BAJA"= 
          CASE 
            WHEN @F_BAJA_PACIENTE_CASA IS NULL THEN NULL 
            WHEN @F_BAJA_PACIENTE_CASA = 'CURRENT_TIMESTAMP' THEN CURRENT_TIMESTAMP 
          END
        FROM "PACIENTE_WEARABLE", "USUARIO_PRIVADO"
        WHERE "PACIENTE_CASA"."COD_USUARIO" = "PACIENTE_WEARABLE"."COD_USUARIO"
        AND "PACIENTE_CASA"."COD_USUARIO" = "USUARIO_PRIVADO"."COD_USUARIO"
        AND "PACIENTE_CASA"."COD_CASA" = @COD_CASA;

        UPDATE "PACIENTE_WEARABLE"
        SET "F_BAJA"=
          CASE 
            WHEN @F_BAJA_PACIENTE_WEARABLE IS NULL THEN NULL 
            WHEN @F_BAJA_PACIENTE_WEARABLE = 'CURRENT_TIMESTAMP' THEN CURRENT_TIMESTAMP 
          END
        WHERE "COD_USUARIO" IN (
          SELECT "COD_USUARIO" FROM "PACIENTE_CASA"
          WHERE "COD_CASA" = @COD_CASA
        );

        UPDATE "USUARIO_PRIVADO"
        SET "F_BAJA"=
          CASE 
            WHEN @F_BAJA_PRIVADO IS NULL THEN NULL 
            WHEN @F_BAJA_PRIVADO = 'CURRENT_TIMESTAMP' THEN CURRENT_TIMESTAMP 
          END
        WHERE "COD_USUARIO" IN (
          SELECT "COD_USUARIO" FROM "PACIENTE_CASA"
          WHERE "COD_CASA" = @COD_CASA
        );
        COMMIT TRANSACTION;
          ''';
      var ActDesActPaciente = await connection!.execute(
        Update,
        substitutionValues: {
          "COD_CASA": COD_CASA,
          "F_BAJA_CASA": F_BAJA_CASA,
          "F_BAJA_HABITACION": F_BAJA_HABITACION,
          "F_BAJA_HABITACION_SENSOR": F_BAJA_HABITACION_SENSOR,
          "F_BAJA_PACIENTE_CASA": F_BAJA_PACIENTE_CASA,
          "F_BAJA_PACIENTE_WEARABLE": F_BAJA_PACIENTE_WEARABLE,
          "F_BAJA_PRIVADO": F_BAJA_PRIVADO,
        },
      );
      await connection!.close();
      if (ActDesActPaciente == 0) {
        return 'Correcto';
      } else {
        return 'incorrecto';
      }
    } catch (e) {
      return 'error';
    }
  }

  /// ***************************************************************************
  /// Funcion que devuelve la lista de las variables sanitarias
  ///***************************************************************************
  Future<List> DBGetVariableSanitarias() async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      Wearable = await connection!.query('''
        select
          "VARIABLES_SANITARIAS"."COD_VARIABLES_SANITARIAS",
          "VARIABLES_SANITARIAS"."VARIABLES_SANITARIAS"
        from
          "VARIABLES_SANITARIAS"
        ORDER BY
        CASE
          WHEN "VARIABLES_SANITARIAS" = 'Otros' THEN 1
          ELSE 0
        END,
        "VARIABLES_SANITARIAS";
        ''', substitutionValues: {});
      await connection!.close();
      print(Wearable);
      return Wearable!;
    } catch (e) {
      return [];
    }
  }

  /// ***************************************************************************
  /// Funcion que devuelve la lista de las variables sanitarias
  ///***************************************************************************
  Future<List> DBGetVariableSocial() async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      Wearable = await connection!.query('''
        select
          "VARIABLES_SOCIALES"."COD_VARIABLES_SOCIALES",
          "VARIABLES_SOCIALES"."VARIABLES_SOCIALES"
        from
          "VARIABLES_SOCIALES"
        ORDER BY
          CASE
            WHEN "VARIABLES_SOCIALES" LIKE '%ed social%' THEN 1
            WHEN "VARIABLES_SOCIALES" = 'Otros' THEN 2
            ELSE 0
          END,
        "VARIABLES_SOCIALES" ASC;
        ''', substitutionValues: {});
      print(Wearable);
      await connection!.close();
      return Wearable!;
    } catch (e) {
      return [];
    }
  }

  /// ***************************************************************************
  /// Funcion que devuelve la lista de las variables de un paciente
  ///***************************************************************************
  Future<List> DBGetVariablePaciente(COD_USUARIO) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      var Sociales = await connection!.query(
        '''
        select
          "COD_VARIABLES_SOCIALES"
        from
          "SOCIAL_PACIENTE"
        where 
          "COD_USUARIO" = @COD_USUARIO;
        ''',
        substitutionValues: {"COD_USUARIO": COD_USUARIO},
      );
      var Sanitarias = await connection!.query(
        '''
        select
          "COD_VARIABLES_SANITARIAS"
        from
          "SANITARIA_PACIENTE"
        where 
          "COD_USUARIO" = @COD_USUARIO;
        ''',
        substitutionValues: {"COD_USUARIO": COD_USUARIO},
      );
      print(Sociales);
      await connection!.close();
      return [Sociales, Sanitarias];
    } catch (e) {
      return [];
    }
  }

  /// ***************************************************************************
  /// Funcion que devuelve la lista de los tipos de sensor
  ///***************************************************************************
  Future<List> DBGetTipoSensor() async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      TipoSensor = await connection!.query('''
        select
            "TIPO_SENSOR"."COD_TIPO_SENSOR",
            "TIPO_SENSOR"."TIPO_SENSOR"
        from
            "TIPO_SENSOR"
        ORDER BY CASE WHEN "TIPO_SENSOR" = 'Otros' THEN 1 ELSE 0 END,
          "TIPO_SENSOR" ASC 
        ''', substitutionValues: {});
      print(TipoSensor);
      await connection!.close();
      return TipoSensor!;
    } catch (e) {
      return [];
    }
  }

  /// ***************************************************************************
  /// Funcion que devuelve la lista de los tipos de Wearable
  ///***************************************************************************
  Future<List> DBGetTipoWearable() async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      TipoWearable = await connection!.query('''
        select
            "TIPO_WEARABLE"."COD_TIPO_WEARABLE",
            "TIPO_WEARABLE"."TIPO_WEARABLE"
        from
            "TIPO_WEARABLE"
        ORDER BY CASE WHEN "TIPO_WEARABLE" = 'Otros' THEN 1 ELSE 0 END,
          "TIPO_WEARABLE" ASC 
        ''', substitutionValues: {});
      print(TipoWearable);
      await connection!.close();
      return TipoWearable!;
    } catch (e) {
      return [];
    }
  }

  /// ***************************************************************************
  /// Funcion que devuelve la lista de los tipos de habitaciones
  ///***************************************************************************
  Future<List> DBGetTipoHabitacion() async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      var TipoHabitacion_query = '''
        select
            "TIPO_HABITACION"."COD_TIPO_HABITACION",
            "TIPO_HABITACION"."TIPO_HABITACION"
        from
            "TIPO_HABITACION"
        ORDER BY CASE WHEN "TIPO_HABITACION" = 'Otros' THEN 1 ELSE 0 END, "TIPO_HABITACION";
      ''';
      TipoHabitacion = await connection!.query(
        TipoHabitacion_query,
        substitutionValues: {},
      );
      print(TipoHabitacion);
      await connection!.close();
      return TipoHabitacion!;
    } catch (e) {
      return [];
    }
  }

  /// ***************************************************************************
  /// Funcion que devuelve la lista de los tipos de cuidadores
  ///***************************************************************************
  Future<List> DBGetTipoCuidador() async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      TipoCuidador = await connection!.query('''
        select
            "TIPO_CUIDADOR"."COD_TIPO_CUIDADOR",
            "TIPO_CUIDADOR"."TIPO_CUIDADOR"
        from
            "TIPO_CUIDADOR"
        ORDER BY CASE 
          WHEN "TIPO_CUIDADOR" like '%(Cuidador Formal)%' THEN 1 
          WHEN "TIPO_CUIDADOR" like '%(Cuidador Informal)%' THEN 2 
          WHEN "TIPO_CUIDADOR" = 'Otros' THEN 3 
          ELSE 0 END, 
          "TIPO_CUIDADOR";
        ''', substitutionValues: {});
      print(TipoCuidador);
      await connection!.close();
      return TipoCuidador!;
    } catch (e) {
      return [];
    }
  }

  /*****************************************************************************
   * Funciones del Usuario Cuidador
   ****************************************************************************/

  /// ***************************************************************************
  /// Funcion que devuelve los usuarios Pacientes con sus respectivas viviendas
  ///***************************************************************************
  Future<List> DBGetPacientesViviendasCuidador(
    COD_CUIDADOR,
    fechaBajaCasa,
  ) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      var casa_query =
          '''
        SELECT
          "CUIDADOR_CASA"."COD_USUARIO",
          "CUIDADOR_CASA"."COD_CASA",
          "CASA"."DIRECCION" || ', ' || "CASA"."NUMERO" || ', ' || "CASA"."PISO" || '' || "CASA"."PUERTA" || ', ' || "CASA"."LOCALIDAD" || ', ' || "CASA"."PROVINCIA" || ', ' || "CASA"."PAIS" || ', ' || "CASA"."COD_POSTAL",
          "CASA"."LATITUD",
          "CASA"."LONGITUD"
          
        FROM
          "CUIDADOR_CASA"
          INNER JOIN "CASA" ON
            "CUIDADOR_CASA"."COD_CASA" = "CASA"."COD_CASA"
        WHERE
          "CUIDADOR_CASA"."COD_USUARIO" = @COD_CUIDADOR and "CUIDADOR_CASA"."F_BAJA" IS ''' +
          fechaBajaCasa +
          '''
        ORDER BY
        "CASA"."DIRECCION" || ', ' || "CASA"."NUMERO" || ', ' || "CASA"."PISO" || '' || "CASA"."PUERTA" || ', ' || "CASA"."LOCALIDAD" || ', ' || "CASA"."PROVINCIA" || ', ' || "CASA"."PAIS" || ', ' || "CASA"."COD_POSTAL" ASC;
        ''';

      Casa = await connection!.query(
        casa_query,
        substitutionValues: {'COD_CUIDADOR': COD_CUIDADOR},
      );

      var pacientes_query = '''
        select
            "USUARIO_PRIVADO"."COD_USUARIO",
            "USUARIO_PRIVADO"."NOMBRE",
            "USUARIO_PRIVADO"."APELLIDO1",
            "USUARIO_PRIVADO"."APELLIDO2",
            "USUARIO_PRIVADO"."F_NACIMIENTO",
            "USUARIO_PRIVADO"."TELEFONO",
            "USUARIO_PRIVADO"."MAIL",
            "USUARIO_PRIVADO"."ORGANIZACION",
            MAX("SOCIAL_PACIENTE"."DES_OTROS"), 
            string_agg(DISTINCT 
            CASE
                      WHEN "VARIABLES_SOCIALES"."VARIABLES_SOCIALES" = 'Otros' THEN "VARIABLES_SOCIALES"."VARIABLES_SOCIALES" || ' (' || "SOCIAL_PACIENTE"."DES_OTROS" || ')'
                      ELSE "VARIABLES_SOCIALES"."VARIABLES_SOCIALES"
                  END,
                  ', '
              ) AS "VARIABLES_SOCIALES",
            MAX("SANITARIA_PACIENTE"."DES_OTROS"),
              string_agg(DISTINCT 
                  CASE
                      WHEN "VARIABLES_SANITARIAS"."VARIABLES_SANITARIAS" = 'Otros' THEN "VARIABLES_SANITARIAS"."VARIABLES_SANITARIAS" || ' (' || "SANITARIA_PACIENTE"."DES_OTROS" || ')'
                      ELSE "VARIABLES_SANITARIAS"."VARIABLES_SANITARIAS"
                  END,
                  ', '
              ) as "VARIABLES_SANITARIAS",
                "USUARIO_PRIVADO"."F_ALTA",
                "USUARIO_PRIVADO"."F_BAJA",
                MAX("PACIENTE_CASA"."COD_CASA"),
                MAX("PACIENTE_WEARABLE"."COD_PACIENTE_WEARABLE")
            from
                "USUARIO_PACIENTE"
            inner join "USUARIO_PRIVADO" on
                "USUARIO_PACIENTE"."COD_USUARIO" = "USUARIO_PRIVADO"."COD_USUARIO"
            inner join "PACIENTE_CASA" on
                "USUARIO_PACIENTE"."COD_USUARIO" = "PACIENTE_CASA"."COD_USUARIO"
            inner join "CASA" on
                "PACIENTE_CASA"."COD_CASA" = "CASA"."COD_CASA"
            INNER JOIN "SOCIAL_PACIENTE" ON "USUARIO_PACIENTE"."COD_USUARIO" = "SOCIAL_PACIENTE"."COD_USUARIO" 
            INNER JOIN "VARIABLES_SOCIALES" ON "SOCIAL_PACIENTE"."COD_VARIABLES_SOCIALES" = "VARIABLES_SOCIALES"."COD_VARIABLES_SOCIALES" 
            INNER JOIN "SANITARIA_PACIENTE" ON "USUARIO_PACIENTE"."COD_USUARIO" = "SANITARIA_PACIENTE"."COD_USUARIO" 
            INNER JOIN "VARIABLES_SANITARIAS" ON "SANITARIA_PACIENTE"."COD_VARIABLES_SANITARIAS" = "VARIABLES_SANITARIAS"."COD_VARIABLES_SANITARIAS"
            inner join public."PACIENTE_WEARABLE" on
                "USUARIO_PACIENTE"."COD_USUARIO" = public."PACIENTE_WEARABLE"."COD_USUARIO" 
            where "USUARIO_PRIVADO"."F_BAJA" is null and "PACIENTE_CASA"."F_BAJA" is null
		    GROUP BY "USUARIO_PRIVADO"."COD_USUARIO"
        ''';
      Pacientes = await connection!.query(pacientes_query);
      print(Paciente);
      await connection!.close();
      return [Casa!, Pacientes!];
    } catch (e) {
      await connection!.close();
      return [];
    }
  }

  /// ***************************************************************************
  /// Funcion que devuelve la vicienda de un paciente
  ///***************************************************************************
  Future<List> DBGetDatosPacienteCuidador(COD_PACIENTE, fechaBajaCasa) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      var casa_query =
          '''
        SELECT
          "PACIENTE_CASA"."COD_USUARIO",
          "PACIENTE_CASA"."COD_CASA",
          "CASA"."DIRECCION" || ', ' || "CASA"."NUMERO" || ', ' || "CASA"."PISO" || '' || "CASA"."PUERTA" || ', ' || "CASA"."LOCALIDAD" || ', ' || "CASA"."PROVINCIA" || ', ' || "CASA"."PAIS" || ', ' || "CASA"."COD_POSTAL",
          "CASA"."LATITUD",
          "CASA"."LONGITUD"
          
        FROM
          "PACIENTE_CASA"
          INNER JOIN "CASA" ON
            "PACIENTE_CASA"."COD_CASA" = "CASA"."COD_CASA"
        WHERE
          "PACIENTE_CASA"."COD_USUARIO" = @COD_PACIENTE and "PACIENTE_CASA"."F_BAJA" IS ''' +
          fechaBajaCasa +
          '''
        ORDER BY
        "CASA"."DIRECCION" || ', ' || "CASA"."NUMERO" || ', ' || "CASA"."PISO" || '' || "CASA"."PUERTA" || ', ' || "CASA"."LOCALIDAD" || ', ' || "CASA"."PROVINCIA" || ', ' || "CASA"."PAIS" || ', ' || "CASA"."COD_POSTAL" ASC;
        ''';

      Casa = await connection!.query(
        casa_query,
        substitutionValues: {'COD_PACIENTE': COD_PACIENTE},
      );

      var habitacion_sensor_query =
          '''        select
            "HABITACION"."COD_HABITACION",
            "HABITACION"."OBSERVACIONES",
            "HABITACION"."N_PLANTA",
            "HABITACION"."COD_TIPO_HABITACION",
            "TIPO_HABITACION"."TIPO_HABITACION",
            "HABITACION"."F_ALTA",
            "HABITACION"."F_BAJA",
            "HABITACION_SENSOR"."COD_HABITACION_SENSOR",
            "HABITACION_SENSOR"."F_ALTA",
            "HABITACION_SENSOR"."F_BAJA",
            "HABITACION_SENSOR"."COD_SENSOR"
        from
            "HABITACION"
        inner join "HABITACION_SENSOR" on
            "HABITACION"."COD_HABITACION" = "HABITACION_SENSOR"."COD_HABITACION"
        inner join "TIPO_HABITACION" on
            "HABITACION"."COD_TIPO_HABITACION" = "TIPO_HABITACION"."COD_TIPO_HABITACION"
        where "HABITACION"."COD_CASA" = ${Casa![0][1]} and "HABITACION"."F_BAJA" is ''' +
          fechaBajaCasa +
          ''' and "HABITACION_SENSOR"."F_BAJA" is ''' +
          fechaBajaCasa +
          '''
        ''';
      Habitaciones = await connection!.query(habitacion_sensor_query);
      await connection!.close();
      //return [Casa!, Habitaciones!];
      return [Casa!, Habitaciones];
    } catch (e) {
      await connection!.close();
      return [];
    }
  }

  /// ***************************************************************************
  /// Funcion que devuelve la vicienda(s) de un paciente
  ///***************************************************************************
  Future<List> DBGetDatosPacienteCuidador2(COD_PACIENTE, fechaBajaCasa) async {
    List Habitaciones_Filtradas = [];
    List Habitaciones = [];
    List Sensores_Puerta = [];
    List SmartMeter = [];
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      var casa_query =
          '''
        SELECT
          "PACIENTE_CASA"."COD_USUARIO",
          "PACIENTE_CASA"."COD_CASA",
          "CASA"."DIRECCION" || ', ' || "CASA"."NUMERO" || ', ' || "CASA"."PISO" || '' || "CASA"."PUERTA" || ', ' || "CASA"."LOCALIDAD" || ', ' || "CASA"."PROVINCIA" || ', ' || "CASA"."PAIS" || ', ' || "CASA"."COD_POSTAL",
          "CASA"."LATITUD",
          "CASA"."LONGITUD"
          
        FROM
          "PACIENTE_CASA"
          INNER JOIN "CASA" ON
            "PACIENTE_CASA"."COD_CASA" = "CASA"."COD_CASA"
        WHERE
          "PACIENTE_CASA"."COD_USUARIO" = @COD_PACIENTE and "PACIENTE_CASA"."F_BAJA" IS ''' +
          fechaBajaCasa +
          '''
        ORDER BY
        "CASA"."DIRECCION" || ', ' || "CASA"."NUMERO" || ', ' || "CASA"."PISO" || '' || "CASA"."PUERTA" || ', ' || "CASA"."LOCALIDAD" || ', ' || "CASA"."PROVINCIA" || ', ' || "CASA"."PAIS" || ', ' || "CASA"."COD_POSTAL" ASC;
        ''';

      Casa = await connection!.query(
        casa_query,
        substitutionValues: {'COD_PACIENTE': COD_PACIENTE},
      );
      for (var casa in Casa!) {
        var habitacion_sensor_query =
            '''
              select
                  "HABITACION"."COD_HABITACION",
                  "HABITACION"."OBSERVACIONES",
                  "HABITACION"."N_PLANTA",
                  "HABITACION"."COD_TIPO_HABITACION",
                  "TIPO_HABITACION"."TIPO_HABITACION",
                  "HABITACION"."F_ALTA",
                  "HABITACION"."F_BAJA",
                  "HABITACION_SENSOR"."COD_HABITACION_SENSOR",
                  "HABITACION_SENSOR"."F_ALTA",
                  "HABITACION_SENSOR"."F_BAJA",
                  "HABITACION_SENSOR"."COD_SENSOR",
                  "TIPO_SENSOR"."TIPO_SENSOR",
                  "SENSOR"."DES_OTROS",
                  "SENSOR"."ID_SENSOR"
              from
                  "HABITACION"
              inner join "HABITACION_SENSOR" on
                  "HABITACION"."COD_HABITACION" = "HABITACION_SENSOR"."COD_HABITACION"
              inner join "TIPO_HABITACION" on
                  "HABITACION"."COD_TIPO_HABITACION" = "TIPO_HABITACION"."COD_TIPO_HABITACION"
              inner join "SENSOR" on
                  "HABITACION_SENSOR"."COD_SENSOR" = "SENSOR"."COD_SENSOR"
              inner join "TIPO_SENSOR" on
                  "SENSOR"."COD_TIPO_SENSOR" = "TIPO_SENSOR"."COD_TIPO_SENSOR"
              where "HABITACION"."COD_CASA" = ${casa[1]} and "HABITACION"."F_BAJA" is $fechaBajaCasa and "HABITACION_SENSOR"."F_BAJA" is $fechaBajaCasa
          ''';
        var habitaciones = await connection!.query(habitacion_sensor_query);

        // Agregar las habitaciones de esta casa a la lista total
        Habitaciones.addAll((habitaciones));
      }
      for (var j = 0; j < Habitaciones.length; j++) {
        if (Habitaciones[j][11] == 'BLE') {
          Habitaciones_Filtradas.add(Habitaciones[j]);
        }
      }
      for (var j = 0; j < Habitaciones.length; j++) {
        if (Habitaciones[j][11] == 'SENSOR DE APERTURA') {
          Sensores_Puerta.add(Habitaciones[j]);
        }
      }
      for (var j = 0; j < Habitaciones.length; j++) {
        if (Habitaciones[j][11] == 'SM') {
          SmartMeter.add(Habitaciones[j]);
        }
      }
      await connection!.close();
      //return [Casa!, Habitaciones!];
      return [Casa!, Habitaciones_Filtradas, Sensores_Puerta, SmartMeter];
    } catch (e) {
      await connection!.close();
      return [];
    }
  }

  Future<List> DBGetAlarmaParametros() async {
    try {
      await connect();

      // Consulta para ALARMA_PARAMETROS con filtro por TIPO_ALARMA
      var alarma_parametros_query = '''
      select
          "ALARMA_PARAMETROS"."COD_ALARMA_PARAMETRO",
          "ALARMA"."COD_ALARMA",
          "ALARMA"."ALARMA",
          "ALARMA"."TIPO_ALARMA",
          "ALARMA"."OBSERVACIONES",
          "PARAMETROS"."COD_PARAMETRO",
          "PARAMETROS"."PARAMETRO",
          "PARAMETROS"."MASCARA",
          "PARAMETROS"."OBSERVACIONES"
      from
          "ALARMA_PARAMETROS"
      inner join "ALARMA" on
          "ALARMA_PARAMETROS"."COD_ALARMA" = "ALARMA"."COD_ALARMA"
      inner join "PARAMETROS" on
          "ALARMA_PARAMETROS"."COD_PARAMETRO" = "PARAMETROS"."COD_PARAMETRO"
      where
          "ALARMA"."TIPO_ALARMA" != 'adl'
      ORDER BY
          "ALARMA_PARAMETROS"."COD_ALARMA_PARAMETRO" ASC;
      ''';

      AlarmaParametros = await connection!.query(alarma_parametros_query);

      // Consulta para ALARMA con filtro por TIPO_ALARMA
      var alarma_query = '''
      select
          "ALARMA"."COD_ALARMA",
          "ALARMA"."ALARMA",
          "ALARMA"."TIPO_ALARMA",
          "ALARMA"."OBSERVACIONES"
      from
          "ALARMA"
      where
          "ALARMA"."TIPO_ALARMA" != 'adl';
      ''';

      Alarma = await connection!.query(alarma_query);

      // Consulta para ALARMA_PACIENTE_CONFIG_PARAM con filtro implícito
      var AlarmaParametrosValor_query = '''
      select
          public."ALARMA_PACIENTE_CONFIG_PARAM"."COD_ALARMA_PACIENTE",
          public."ALARMA_PACIENTE_CONFIG_PARAM"."COD_ALARMA_PARAMETRO",
          public."ALARMA_PACIENTE_CONFIG_PARAM"."VALOR",
          public."PARAMETROS"."PARAMETRO"
      from
          public."ALARMA_PACIENTE_CONFIG_PARAM"
      inner join public."ALARMA_PARAMETROS" on
          public."ALARMA_PACIENTE_CONFIG_PARAM"."COD_ALARMA_PARAMETRO" = public."ALARMA_PARAMETROS"."COD_ALARMA_PARAMETRO"
      inner join public."PARAMETROS" on
          public."ALARMA_PARAMETROS"."COD_PARAMETRO" = public."PARAMETROS"."COD_PARAMETRO"
      inner join public."ALARMA" on
          public."ALARMA_PARAMETROS"."COD_ALARMA" = public."ALARMA"."COD_ALARMA"
      where
          public."ALARMA"."TIPO_ALARMA" != 'adl'
      ORDER BY
          public."ALARMA_PARAMETROS"."COD_ALARMA_PARAMETRO" ASC;
      ''';

      AlarmaParametrosValor = await connection!.query(
        AlarmaParametrosValor_query,
      );

      await connection!.close();
      return [AlarmaParametros!, Alarma!, AlarmaParametrosValor!];
    } catch (e) {
      await connection!.close();
      return [];
    }
  }

  Future<List> DBGetADLsParametros() async {
    try {
      await connect();

      // Consulta para ALARMA_PARAMETROS con filtro por TIPO_ALARMA
      var alarma_parametros_query = '''
      select
          "ALARMA_PARAMETROS"."COD_ALARMA_PARAMETRO",
          "ALARMA"."COD_ALARMA",
          "ALARMA"."ALARMA",
          "ALARMA"."TIPO_ALARMA",
          "ALARMA"."OBSERVACIONES",
          "PARAMETROS"."COD_PARAMETRO",
          "PARAMETROS"."PARAMETRO",
          "PARAMETROS"."MASCARA",
          "PARAMETROS"."OBSERVACIONES"
      from
          "ALARMA_PARAMETROS"
      inner join "ALARMA" on
          "ALARMA_PARAMETROS"."COD_ALARMA" = "ALARMA"."COD_ALARMA"
      inner join "PARAMETROS" on
          "ALARMA_PARAMETROS"."COD_PARAMETRO" = "PARAMETROS"."COD_PARAMETRO"
      where
          "ALARMA"."TIPO_ALARMA" = 'adl'
      ORDER BY
          "ALARMA_PARAMETROS"."COD_ALARMA_PARAMETRO" ASC;
      ''';

      AlarmaParametros = await connection!.query(alarma_parametros_query);

      // Consulta para ALARMA con filtro por TIPO_ALARMA
      var alarma_query = '''
      select
          "ALARMA"."COD_ALARMA",
          "ALARMA"."ALARMA",
          "ALARMA"."TIPO_ALARMA",
          "ALARMA"."OBSERVACIONES"
      from
          "ALARMA"
      where
          "ALARMA"."TIPO_ALARMA" = 'adl';
      ''';

      Alarma = await connection!.query(alarma_query);

      // Consulta para ALARMA_PACIENTE_CONFIG_PARAM con filtro implícito
      var AlarmaParametrosValor_query = '''
      select
          public."ALARMA_PACIENTE_CONFIG_PARAM"."COD_ALARMA_PACIENTE",
          public."ALARMA_PACIENTE_CONFIG_PARAM"."COD_ALARMA_PARAMETRO",
          public."ALARMA_PACIENTE_CONFIG_PARAM"."VALOR",
          public."PARAMETROS"."PARAMETRO"
      from
          public."ALARMA_PACIENTE_CONFIG_PARAM"
      inner join public."ALARMA_PARAMETROS" on
          public."ALARMA_PACIENTE_CONFIG_PARAM"."COD_ALARMA_PARAMETRO" = public."ALARMA_PARAMETROS"."COD_ALARMA_PARAMETRO"
      inner join public."PARAMETROS" on
          public."ALARMA_PARAMETROS"."COD_PARAMETRO" = public."PARAMETROS"."COD_PARAMETRO"
      inner join public."ALARMA" on
          public."ALARMA_PARAMETROS"."COD_ALARMA" = public."ALARMA"."COD_ALARMA"
      where
          public."ALARMA"."TIPO_ALARMA" = 'adl'
      ORDER BY
          public."ALARMA_PARAMETROS"."COD_ALARMA_PARAMETRO" ASC;
      ''';

      AlarmaParametrosValor = await connection!.query(
        AlarmaParametrosValor_query,
      );

      await connection!.close();
      return [AlarmaParametros!, Alarma!, AlarmaParametrosValor!];
    } catch (e) {
      await connection!.close();
      return [];
    }
  }

  Future DBAnagdirAlarmaPaciente(COD_USUARIO, COD_ALARMA, OBSERVACIONES) async {
    PostgreSQLResult NewAlarma;
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      var Insert = '''
          INSERT INTO "ALARMA_PACIENTE_CONFIG"
          ("COD_USUARIO", "COD_ALARMA", "OBSERVACIONES")
          VALUES(@COD_USUARIO, @COD_ALARMA, @OBSERVACIONES)
          RETURNING "COD_ALARMA_PACIENTE"
        ''';
      NewAlarma = await connection!.query(
        Insert,
        substitutionValues: {
          'COD_USUARIO': COD_USUARIO,
          'COD_ALARMA': COD_ALARMA,
          'OBSERVACIONES': OBSERVACIONES,
        },
      );

      await connection!.close();
      return NewAlarma.first.first;
    } catch (e) {
      return null;
    }
  }

  Future DBGetAlarmaPaciente(COD_USUARIO, fechaBaja) async {
    PostgreSQLResult GetAlarmaParametroValor;
    PostgreSQLResult GetAlarmaPaciente;
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      var AlarmasParametrosValor = '''
          select
              "ALARMA_PACIENTE_CONFIG_PARAM"."COD_ALARMA_PACIENTE",
              "ALARMA_PACIENTE_CONFIG_PARAM"."VALOR",
              "ALARMA_PARAMETROS"."COD_ALARMA_PARAMETRO",
              "PARAMETROS"."COD_PARAMETRO",
              "PARAMETROS"."PARAMETRO",
              "PARAMETROS"."MASCARA",
              "ALARMA"."COD_ALARMA",
              "ALARMA"."TIPO_ALARMA"

          from
              "ALARMA_PACIENTE_CONFIG_PARAM"
          inner join "ALARMA_PARAMETROS" on
              "ALARMA_PACIENTE_CONFIG_PARAM"."COD_ALARMA_PARAMETRO" = "ALARMA_PARAMETROS"."COD_ALARMA_PARAMETRO"
          inner join "PARAMETROS" on
              "ALARMA_PARAMETROS"."COD_PARAMETRO" = "PARAMETROS"."COD_PARAMETRO"
          inner join "ALARMA" on
              "ALARMA_PARAMETROS"."COD_ALARMA" = "ALARMA"."COD_ALARMA"
          where
              public."ALARMA"."TIPO_ALARMA" != 'adl'
          ORDER BY
              "ALARMA_PARAMETROS"."COD_ALARMA_PARAMETRO" ASC;
        ''';
      GetAlarmaParametroValor = await connection!.query(
        AlarmasParametrosValor,
        substitutionValues: {'COD_USUARIO': COD_USUARIO},
      );
      var AlarmaPaciente =
          '''
          select
              "ALARMA"."COD_ALARMA",
              "ALARMA"."ALARMA",
              "ALARMA_PACIENTE_CONFIG"."OBSERVACIONES",
              "ALARMA_PACIENTE_CONFIG"."COD_ALARMA_PACIENTE",
              "ALARMA_PACIENTE_CONFIG"."F_ALTA",
              "ALARMA_PACIENTE_CONFIG"."F_BAJA"
          from
              "ALARMA"
          inner join "ALARMA_PACIENTE_CONFIG" on
              "ALARMA"."COD_ALARMA" = "ALARMA_PACIENTE_CONFIG"."COD_ALARMA"
          where "ALARMA_PACIENTE_CONFIG"."COD_USUARIO" = @COD_USUARIO and "ALARMA_PACIENTE_CONFIG"."F_BAJA" is ''' +
          fechaBaja +
          ''' and "ALARMA"."TIPO_ALARMA" != 'adl'
        ''';
      GetAlarmaPaciente = await connection!.query(
        AlarmaPaciente,
        substitutionValues: {'COD_USUARIO': COD_USUARIO},
      );
      await connection!.close();
      return [GetAlarmaPaciente, GetAlarmaParametroValor];
    } catch (e) {
      return null;
    }
  }

  Future DBGetADLsPaciente(COD_USUARIO, fechaBaja) async {
    PostgreSQLResult GetAlarmaParametroValor;
    PostgreSQLResult GetAlarmaPaciente;
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      var AlarmasParametrosValor = '''
          select
              "ALARMA_PACIENTE_CONFIG_PARAM"."COD_ALARMA_PACIENTE",
              "ALARMA_PACIENTE_CONFIG_PARAM"."VALOR",
              "ALARMA_PARAMETROS"."COD_ALARMA_PARAMETRO",
              "PARAMETROS"."COD_PARAMETRO",
              "PARAMETROS"."PARAMETRO",
              "PARAMETROS"."MASCARA",
              "ALARMA"."COD_ALARMA",
              "ALARMA"."TIPO_ALARMA"

          from
              "ALARMA_PACIENTE_CONFIG_PARAM"
          inner join "ALARMA_PARAMETROS" on
              "ALARMA_PACIENTE_CONFIG_PARAM"."COD_ALARMA_PARAMETRO" = "ALARMA_PARAMETROS"."COD_ALARMA_PARAMETRO"
          inner join "PARAMETROS" on
              "ALARMA_PARAMETROS"."COD_PARAMETRO" = "PARAMETROS"."COD_PARAMETRO"
          inner join "ALARMA" on
              "ALARMA_PARAMETROS"."COD_ALARMA" = "ALARMA"."COD_ALARMA"
          where
              public."ALARMA"."TIPO_ALARMA" = 'adl'
          ORDER BY
              "ALARMA_PARAMETROS"."COD_ALARMA_PARAMETRO" ASC;
        ''';
      GetAlarmaParametroValor = await connection!.query(
        AlarmasParametrosValor,
        substitutionValues: {'COD_USUARIO': COD_USUARIO},
      );
      var AlarmaPaciente =
          '''
          select
              "ALARMA"."COD_ALARMA",
              "ALARMA"."ALARMA",
              "ALARMA_PACIENTE_CONFIG"."OBSERVACIONES",
              "ALARMA_PACIENTE_CONFIG"."COD_ALARMA_PACIENTE",
              "ALARMA_PACIENTE_CONFIG"."F_ALTA",
              "ALARMA_PACIENTE_CONFIG"."F_BAJA"
          from
              "ALARMA"
          inner join "ALARMA_PACIENTE_CONFIG" on
              "ALARMA"."COD_ALARMA" = "ALARMA_PACIENTE_CONFIG"."COD_ALARMA"
          where "ALARMA_PACIENTE_CONFIG"."COD_USUARIO" = @COD_USUARIO and "ALARMA_PACIENTE_CONFIG"."F_BAJA" is ''' +
          fechaBaja +
          ''' and "ALARMA"."TIPO_ALARMA" = 'adl'
        ''';
      GetAlarmaPaciente = await connection!.query(
        AlarmaPaciente,
        substitutionValues: {'COD_USUARIO': COD_USUARIO},
      );
      await connection!.close();
      return [GetAlarmaPaciente, GetAlarmaParametroValor];
    } catch (e) {
      return null;
    }
  }

  Future readADLInfo() async {
    PostgreSQLResult rows;
    try {
      await connect();
      var ADLS = '''
          select
              "ALARMA_PACIENTE_CONFIG_PARAM"."COD_ALARMA_PACIENTE",
              "ALARMA_PACIENTE_CONFIG_PARAM"."VALOR",
              "ALARMA_PARAMETROS"."COD_ALARMA_PARAMETRO",
              "PARAMETROS"."COD_PARAMETRO",
              "PARAMETROS"."PARAMETRO",
              "PARAMETROS"."MASCARA",
              "ALARMA"."COD_ALARMA",
              "ALARMA"."TIPO_ALARMA"

          from
              "ALARMA_PACIENTE_CONFIG_PARAM"
          inner join "ALARMA_PARAMETROS" on
              "ALARMA_PACIENTE_CONFIG_PARAM"."COD_ALARMA_PARAMETRO" = "ALARMA_PARAMETROS"."COD_ALARMA_PARAMETRO"
          inner join "PARAMETROS" on
              "ALARMA_PARAMETROS"."COD_PARAMETRO" = "PARAMETROS"."COD_PARAMETRO"
          inner join "ALARMA" on
              "ALARMA_PARAMETROS"."COD_ALARMA" = "ALARMA"."COD_ALARMA"
          where
              public."ALARMA"."TIPO_ALARMA" = 'adl'
          ORDER BY
              "ALARMA_PARAMETROS"."COD_ALARMA_PARAMETRO" ASC;
        ''';
      rows = await connection!.query(ADLS);
      await connection!.close();
      return rows;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future DBAnagdirAlarmaPacienteConfigParam(
    COD_ALARMA_PACIENTE,
    COD_ALARMA_PARAMETRO,
    VALOR,
  ) async {
    PostgreSQLResult NewAlarma;
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      var Insert = '''
          INSERT INTO "ALARMA_PACIENTE_CONFIG_PARAM"
            ("COD_ALARMA_PACIENTE", "COD_ALARMA_PARAMETRO", "VALOR")
            VALUES(@COD_ALARMA_PACIENTE, @COD_ALARMA_PARAMETRO, @VALOR);
        ''';
      NewAlarma = await connection!.query(
        Insert,
        substitutionValues: {
          'COD_ALARMA_PACIENTE': COD_ALARMA_PACIENTE,
          'COD_ALARMA_PARAMETRO': COD_ALARMA_PARAMETRO,
          'VALOR': VALOR,
        },
      );
      print(NewAlarma);
      await connection!.close();
      return true;
    } catch (e) {
      return null;
    }
  }

  Future DBModAlarmaPacienteConfig(COD_ALARMA_PACIENTE, OBSERVACIONES) async {
    PostgreSQLResult NewAlarma;
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      var Insert = '''
          UPDATE "ALARMA_PACIENTE_CONFIG"
          SET "OBSERVACIONES"=@OBSERVACIONES
          WHERE "COD_ALARMA_PACIENTE"=@COD_ALARMA_PACIENTE;
        ''';
      NewAlarma = await connection!.query(
        Insert,
        substitutionValues: {
          'COD_ALARMA_PACIENTE': COD_ALARMA_PACIENTE,
          'OBSERVACIONES': OBSERVACIONES,
        },
      );

      await connection!.close();
      return true;
    } catch (e) {
      return null;
    }
  }

  Future DBUpdateObservaciones(ALARMA, OBSERVACIONES) async {
    PostgreSQLResult NewAlarma;
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      var Insert = '''
          UPDATE "ALARMA"
          SET "OBSERVACIONES"= @OBSERVACIONES
          WHERE "ALARMA"=@ALARMA;
        ''';
      NewAlarma = await connection!.query(
        Insert,
        substitutionValues: {'ALARMA': ALARMA, 'OBSERVACIONES': OBSERVACIONES},
      );

      await connection!.close();
      return true;
    } catch (e) {
      return null;
    }
  }

  Future DBDefaultTime(String ALARMA) async {
    var Time;
    try {
      await connect();
      var Duracion = '''
      SELECT
        "ALARMA"."OBSERVACIONES"
      FROM
        "ALARMA_PARAMETROS"
      INNER JOIN "ALARMA" ON
        "ALARMA_PARAMETROS"."COD_ALARMA" = "ALARMA"."COD_ALARMA"
      WHERE
        "ALARMA" = @ALARMA
    ''';
      var result = await connection!.query(
        Duracion,
        substitutionValues: {'ALARMA': ALARMA},
      );

      if (result.isNotEmpty) {
        Time = result.first[0];
      }

      await connection!.close();
      return Time;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future DBDefaultParam(String ALARMA) async {
    var Param;
    try {
      await connect();
      var Duracion = '''
          SELECT
            "ALARMA_PARAMETROS"."COD_ALARMA_PARAMETRO"
          FROM
            "ALARMA_PACIENTE_CONFIG"
          INNER JOIN "ALARMA"
              ON "ALARMA_PACIENTE_CONFIG"."COD_ALARMA" = "ALARMA"."COD_ALARMA"
          INNER JOIN "ALARMA_PARAMETROS"
              ON "ALARMA"."COD_ALARMA" = "ALARMA_PARAMETROS"."COD_ALARMA"
          WHERE
            "ALARMA" = @ALARMA
            AND "ALARMA_PARAMETROS"."COD_PARAMETRO" = 7
            AND "ALARMA"."TIPO_ALARMA" = 'adl';
        ''';
      var result = await connection!.query(
        Duracion,
        substitutionValues: {'ALARMA': ALARMA},
      );

      if (result.isNotEmpty) {
        Param = result.first[0];
      }

      await connection!.close();
      return Param;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> actualizarDuracion(String ALARMA, String VALOR) async {
    PostgreSQLResult NewAlarma;
    try {
      await connect();

      // Paso 1: Obtener COD_ALARMA y COD_ALARMA_PARAMETRO
      var resultAlarma = '''
          SELECT
            "ALARMA_PARAMETROS"."COD_ALARMA_PARAMETRO"
          FROM
            "ALARMA_PACIENTE_CONFIG"
          INNER JOIN "ALARMA"
              ON "ALARMA_PACIENTE_CONFIG"."COD_ALARMA" = "ALARMA"."COD_ALARMA"
          INNER JOIN "ALARMA_PARAMETROS"
              ON "ALARMA"."COD_ALARMA" = "ALARMA_PARAMETROS"."COD_ALARMA"
          WHERE
            "ALARMA" = @ALARMA
            AND "ALARMA_PARAMETROS"."COD_PARAMETRO" = 7
            AND "ALARMA"."TIPO_ALARMA" = 'adl';
        ''';

      var rows = await connection!.query(
        resultAlarma,
        substitutionValues: {'ALARMA': ALARMA},
      );

      // Paso 2: Actualizar el VALOR en ALARMA_PACIENTE_CONFIG_PARAM
      for (var row in rows) {
        int codAlarmaParametro = row[0] as int;
        var updateQuery = '''
            UPDATE "ALARMA_PACIENTE_CONFIG_PARAM"
            SET "VALOR" = @VALOR
            WHERE "COD_ALARMA_PARAMETRO" = @COD_ALARMA_PARAMETRO;
          ''';
        NewAlarma = await connection!.query(
          updateQuery,
          substitutionValues: {
            'VALOR': VALOR,
            'COD_ALARMA_PARAMETRO': codAlarmaParametro,
          },
        );
      }

      await connection?.close();
      return true;
    } catch (e) {
      print('Error en actualizarDuracion: $e');
      return false;
    }
  }

  Future DBModAlarmaPacienteConfigParam(
    COD_ALARMA_PACIENTE,
    COD_ALARMA_PARAMETRO,
    VALOR,
  ) async {
    PostgreSQLResult NewAlarma;
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      var Insert = '''
          UPDATE "ALARMA_PACIENTE_CONFIG_PARAM"
          SET "VALOR"=@VALOR
          WHERE "COD_ALARMA_PACIENTE"=@COD_ALARMA_PACIENTE AND "COD_ALARMA_PARAMETRO"=@COD_ALARMA_PARAMETRO;
        ''';
      NewAlarma = await connection!.query(
        Insert,
        substitutionValues: {
          'COD_ALARMA_PACIENTE': COD_ALARMA_PACIENTE,
          'COD_ALARMA_PARAMETRO': COD_ALARMA_PARAMETRO,
          'VALOR': VALOR,
        },
      );
      print(NewAlarma);
      await connection!.close();
      return true;
    } catch (e) {
      return null;
    }
  }

  Future DBDeleteAlarmaPacienteConfigParam(COD_ALARMA_PACIENTE) async {
    PostgreSQLResult NewAlarma;
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      var Insert = '''
          DELETE FROM "ALARMA_PACIENTE_CONFIG_PARAM"
          WHERE "COD_ALARMA_PACIENTE"=@COD_ALARMA_PACIENTE;
        ''';
      NewAlarma = await connection!.query(
        Insert,
        substitutionValues: {'COD_ALARMA_PACIENTE': COD_ALARMA_PACIENTE},
      );
      print(NewAlarma);
      await connection!.close();
      return true;
    } catch (e) {
      return null;
    }
  }

  /// ***************************************************************************
  /// Funcion que Activar o Desactivar un usuario Administrador
  ///***************************************************************************
  Future<String> DBDesactActAlarmaPacienteConfig(
    COD_ALARMA_PACIENTE,
    F_BAJA,
  ) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      var Update = '''
          UPDATE "ALARMA_PACIENTE_CONFIG" SET "F_BAJA" = 
              CASE 
                WHEN @F_BAJA IS NULL THEN NULL 
                WHEN @F_BAJA = 'CURRENT_TIMESTAMP' THEN CURRENT_TIMESTAMP 
                
              END
          WHERE "COD_ALARMA_PACIENTE" = @COD_ALARMA_PACIENTE
        ''';
      var ActDesActAlaramPaciente = await connection!.execute(
        Update,
        substitutionValues: {
          "COD_ALARMA_PACIENTE": COD_ALARMA_PACIENTE,
          "F_BAJA": F_BAJA,
        },
      );
      await connection!.close();
      if (ActDesActAlaramPaciente != 0) {
        return 'Correcto';
      } else {
        return 'incorrecto';
      }
    } catch (e) {
      await connection!.close();
      return 'error';
    }
  }

  /*****************************************************************************
   *
   *****************************************************************************/

  /// ***************************************************************************
  /// Funcion que devuelve la vivienda de un paciente
  ///***************************************************************************
  Future<List> DBGetDatosPacientePacinete(COD_PACIENTE, fechaBajaCasa) async {
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      var casa_query =
          '''
        SELECT
          "PACIENTE_CASA"."COD_USUARIO",
          "PACIENTE_CASA"."COD_CASA",
          "CASA"."DIRECCION" || ', ' || "CASA"."NUMERO" || ', ' || "CASA"."PISO" || '' || "CASA"."PUERTA" || ', ' || "CASA"."LOCALIDAD" || ', ' || "CASA"."PROVINCIA" || ', ' || "CASA"."PAIS" || ', ' || "CASA"."COD_POSTAL",
          "CASA"."LATITUD",
          "CASA"."LONGITUD"
          
        FROM
          "PACIENTE_CASA"
          INNER JOIN "CASA" ON
            "PACIENTE_CASA"."COD_CASA" = "CASA"."COD_CASA"
        WHERE
          "PACIENTE_CASA"."COD_USUARIO" = @COD_PACIENTE and "PACIENTE_CASA"."F_BAJA" IS ''' +
          fechaBajaCasa +
          '''
        ORDER BY
        "CASA"."DIRECCION" || ', ' || "CASA"."NUMERO" || ', ' || "CASA"."PISO" || '' || "CASA"."PUERTA" || ', ' || "CASA"."LOCALIDAD" || ', ' || "CASA"."PROVINCIA" || ', ' || "CASA"."PAIS" || ', ' || "CASA"."COD_POSTAL" ASC;
        ''';

      Casa = await connection!.query(
        casa_query,
        substitutionValues: {'COD_PACIENTE': COD_PACIENTE},
      );

      var habitacion_sensor_query =
          '''        select
            "HABITACION"."COD_HABITACION",
            "HABITACION"."OBSERVACIONES",
            "HABITACION"."N_PLANTA",
            "HABITACION"."COD_TIPO_HABITACION",
            "TIPO_HABITACION"."TIPO_HABITACION",
            "HABITACION"."F_ALTA",
            "HABITACION"."F_BAJA",
            "HABITACION_SENSOR"."COD_HABITACION_SENSOR",
            "HABITACION_SENSOR"."F_ALTA",
            "HABITACION_SENSOR"."F_BAJA",
            "HABITACION_SENSOR"."COD_SENSOR"
        from
            "HABITACION"
        inner join "HABITACION_SENSOR" on
            "HABITACION"."COD_HABITACION" = "HABITACION_SENSOR"."COD_HABITACION"
        inner join "TIPO_HABITACION" on
            "HABITACION"."COD_TIPO_HABITACION" = "TIPO_HABITACION"."COD_TIPO_HABITACION"
        where "HABITACION"."COD_CASA" = ${Casa![0][1]} and "HABITACION"."F_BAJA" is ''' +
          fechaBajaCasa +
          ''' and "HABITACION_SENSOR"."F_BAJA" is ''' +
          fechaBajaCasa +
          '''
        ''';
      Habitaciones = await connection!.query(habitacion_sensor_query);
      var pacientes_query = '''
        select
            "USUARIO_PRIVADO"."COD_USUARIO",
            "USUARIO_PRIVADO"."NOMBRE",
            "USUARIO_PRIVADO"."APELLIDO1",
            "USUARIO_PRIVADO"."APELLIDO2",
            "USUARIO_PRIVADO"."F_NACIMIENTO",
            "USUARIO_PRIVADO"."TELEFONO",
            "USUARIO_PRIVADO"."MAIL",
            "USUARIO_PRIVADO"."ORGANIZACION",
            MAX("SOCIAL_PACIENTE"."DES_OTROS"), 
            string_agg(DISTINCT 
            CASE
                      WHEN "VARIABLES_SOCIALES"."VARIABLES_SOCIALES" = 'Otros' THEN "VARIABLES_SOCIALES"."VARIABLES_SOCIALES" || ' (' || "SOCIAL_PACIENTE"."DES_OTROS" || ')'
                      ELSE "VARIABLES_SOCIALES"."VARIABLES_SOCIALES"
                  END,
                  ', '
              ) AS "VARIABLES_SOCIALES",
            MAX("SANITARIA_PACIENTE"."DES_OTROS"),
              string_agg(DISTINCT 
                  CASE
                      WHEN "VARIABLES_SANITARIAS"."VARIABLES_SANITARIAS" = 'Otros' THEN "VARIABLES_SANITARIAS"."VARIABLES_SANITARIAS" || ' (' || "SANITARIA_PACIENTE"."DES_OTROS" || ')'
                      ELSE "VARIABLES_SANITARIAS"."VARIABLES_SANITARIAS"
                  END,
                  ', '
              ) as "VARIABLES_SANITARIAS",
                "USUARIO_PRIVADO"."F_ALTA",
                "USUARIO_PRIVADO"."F_BAJA",
                MAX("PACIENTE_CASA"."COD_CASA"),
                MAX("PACIENTE_WEARABLE"."COD_PACIENTE_WEARABLE")
            from
                "USUARIO_PACIENTE"
            inner join "USUARIO_PRIVADO" on
                "USUARIO_PACIENTE"."COD_USUARIO" = "USUARIO_PRIVADO"."COD_USUARIO"
            inner join "PACIENTE_CASA" on
                "USUARIO_PACIENTE"."COD_USUARIO" = "PACIENTE_CASA"."COD_USUARIO"
            inner join "CASA" on
                "PACIENTE_CASA"."COD_CASA" = "CASA"."COD_CASA"
            INNER JOIN "SOCIAL_PACIENTE" ON "USUARIO_PACIENTE"."COD_USUARIO" = "SOCIAL_PACIENTE"."COD_USUARIO" 
            INNER JOIN "VARIABLES_SOCIALES" ON "SOCIAL_PACIENTE"."COD_VARIABLES_SOCIALES" = "VARIABLES_SOCIALES"."COD_VARIABLES_SOCIALES" 
            INNER JOIN "SANITARIA_PACIENTE" ON "USUARIO_PACIENTE"."COD_USUARIO" = "SANITARIA_PACIENTE"."COD_USUARIO" 
            INNER JOIN "VARIABLES_SANITARIAS" ON "SANITARIA_PACIENTE"."COD_VARIABLES_SANITARIAS" = "VARIABLES_SANITARIAS"."COD_VARIABLES_SANITARIAS"
            inner join public."PACIENTE_WEARABLE" on
                "USUARIO_PACIENTE"."COD_USUARIO" = "PACIENTE_WEARABLE"."COD_USUARIO" 
            where "USUARIO_PRIVADO"."F_BAJA" is null and "PACIENTE_CASA"."F_BAJA" is null and "USUARIO_PRIVADO"."COD_USUARIO" = @COD_PACIENTE
		    GROUP BY "USUARIO_PRIVADO"."COD_USUARIO"
        ''';
      Pacientes = await connection!.query(
        pacientes_query,
        substitutionValues: {'COD_PACIENTE': COD_PACIENTE},
      );
      await connection!.close();
      //return [Casa!, Habitaciones!];
      return [Casa!, Habitaciones, Pacientes];
    } catch (e) {
      await connection!.close();
      return [];
    }
  }

  /// ***************************************************************************
  /// Funcion que devuelve la vivienda de un paciente
  ///***************************************************************************
  Future<List> DBGetDatosPacientePacinete2(COD_PACIENTE, fechaBajaCasa) async {
    List Habitaciones = [];
    List Habitaciones_Filtradas = [];
    List Sensores_Puerta = [];
    List SmartMeter = [];
    try {
      await connect();
      // Insert en USUARIO_PRIVADO
      var casa_query =
          '''
        SELECT
          "PACIENTE_CASA"."COD_USUARIO",
          "PACIENTE_CASA"."COD_CASA",
          "CASA"."DIRECCION" || ', ' || "CASA"."NUMERO" || ', ' || "CASA"."PISO" || '' || "CASA"."PUERTA" || ', ' || "CASA"."LOCALIDAD" || ', ' || "CASA"."PROVINCIA" || ', ' || "CASA"."PAIS" || ', ' || "CASA"."COD_POSTAL",
          "CASA"."LATITUD",
          "CASA"."LONGITUD"
          
        FROM
          "PACIENTE_CASA"
          INNER JOIN "CASA" ON
            "PACIENTE_CASA"."COD_CASA" = "CASA"."COD_CASA"
        WHERE
          "PACIENTE_CASA"."COD_USUARIO" = @COD_PACIENTE and "PACIENTE_CASA"."F_BAJA" IS ''' +
          fechaBajaCasa +
          '''
        ORDER BY
        "CASA"."DIRECCION" || ', ' || "CASA"."NUMERO" || ', ' || "CASA"."PISO" || '' || "CASA"."PUERTA" || ', ' || "CASA"."LOCALIDAD" || ', ' || "CASA"."PROVINCIA" || ', ' || "CASA"."PAIS" || ', ' || "CASA"."COD_POSTAL" ASC;
        ''';

      Casa = await connection!.query(
        casa_query,
        substitutionValues: {'COD_PACIENTE': COD_PACIENTE},
      );
      for (var casa in Casa!) {
        var habitacion_sensor_query =
            '''
              select
                  "HABITACION"."COD_HABITACION",
                  "HABITACION"."OBSERVACIONES",
                  "HABITACION"."N_PLANTA",
                  "HABITACION"."COD_TIPO_HABITACION",
                  "TIPO_HABITACION"."TIPO_HABITACION",
                  "HABITACION"."F_ALTA",
                  "HABITACION"."F_BAJA",
                  "HABITACION_SENSOR"."COD_HABITACION_SENSOR",
                  "HABITACION_SENSOR"."F_ALTA",
                  "HABITACION_SENSOR"."F_BAJA",
                  "HABITACION_SENSOR"."COD_SENSOR",
                  "TIPO_SENSOR"."TIPO_SENSOR",
                  "SENSOR"."DES_OTROS",
                  "SENSOR"."ID_SENSOR"
              from
                  "HABITACION"
              inner join "HABITACION_SENSOR" on
                  "HABITACION"."COD_HABITACION" = "HABITACION_SENSOR"."COD_HABITACION"
              inner join "TIPO_HABITACION" on
                  "HABITACION"."COD_TIPO_HABITACION" = "TIPO_HABITACION"."COD_TIPO_HABITACION"
              inner join "SENSOR" on
                  "HABITACION_SENSOR"."COD_SENSOR" = "SENSOR"."COD_SENSOR"
              inner join "TIPO_SENSOR" on
                  "SENSOR"."COD_TIPO_SENSOR" = "TIPO_SENSOR"."COD_TIPO_SENSOR"
              where "HABITACION"."COD_CASA" = ${casa[1]} and "HABITACION"."F_BAJA" is $fechaBajaCasa and "HABITACION_SENSOR"."F_BAJA" is $fechaBajaCasa
          ''';
        var habitaciones = await connection!.query(habitacion_sensor_query);

        // Agregar las habitaciones de esta casa a la lista total
        Habitaciones.addAll((habitaciones));
      }
      for (var j = 0; j < Habitaciones.length; j++) {
        if (Habitaciones[j][11] == 'BLE') {
          Habitaciones_Filtradas.add(Habitaciones[j]);
        }
      }
      for (var j = 0; j < Habitaciones.length; j++) {
        if (Habitaciones[j][11] == 'SENSOR DE APERTURA') {
          Sensores_Puerta.add(Habitaciones[j]);
        }
      }
      for (var j = 0; j < Habitaciones.length; j++) {
        if (Habitaciones[j][11] == 'SM') {
          SmartMeter.add(Habitaciones[j]);
        }
      }
      var pacientes_query = '''
        select
            "USUARIO_PRIVADO"."COD_USUARIO",
            "USUARIO_PRIVADO"."NOMBRE",
            "USUARIO_PRIVADO"."APELLIDO1",
            "USUARIO_PRIVADO"."APELLIDO2",
            "USUARIO_PRIVADO"."F_NACIMIENTO",
            "USUARIO_PRIVADO"."TELEFONO",
            "USUARIO_PRIVADO"."MAIL",
            "USUARIO_PRIVADO"."ORGANIZACION",
            MAX("SOCIAL_PACIENTE"."DES_OTROS"), 
            string_agg(DISTINCT 
            CASE
                      WHEN "VARIABLES_SOCIALES"."VARIABLES_SOCIALES" = 'Otros' THEN "VARIABLES_SOCIALES"."VARIABLES_SOCIALES" || ' (' || "SOCIAL_PACIENTE"."DES_OTROS" || ')'
                      ELSE "VARIABLES_SOCIALES"."VARIABLES_SOCIALES"
                  END,
                  ', '
              ) AS "VARIABLES_SOCIALES",
            MAX("SANITARIA_PACIENTE"."DES_OTROS"),
              string_agg(DISTINCT 
                  CASE
                      WHEN "VARIABLES_SANITARIAS"."VARIABLES_SANITARIAS" = 'Otros' THEN "VARIABLES_SANITARIAS"."VARIABLES_SANITARIAS" || ' (' || "SANITARIA_PACIENTE"."DES_OTROS" || ')'
                      ELSE "VARIABLES_SANITARIAS"."VARIABLES_SANITARIAS"
                  END,
                  ', '
              ) as "VARIABLES_SANITARIAS",
                "USUARIO_PRIVADO"."F_ALTA",
                "USUARIO_PRIVADO"."F_BAJA",
                MAX("PACIENTE_CASA"."COD_CASA"),
                MAX("PACIENTE_WEARABLE"."COD_PACIENTE_WEARABLE")
            from
                "USUARIO_PACIENTE"
            inner join "USUARIO_PRIVADO" on
                "USUARIO_PACIENTE"."COD_USUARIO" = "USUARIO_PRIVADO"."COD_USUARIO"
            inner join "PACIENTE_CASA" on
                "USUARIO_PACIENTE"."COD_USUARIO" = "PACIENTE_CASA"."COD_USUARIO"
            inner join "CASA" on
                "PACIENTE_CASA"."COD_CASA" = "CASA"."COD_CASA"
            INNER JOIN "SOCIAL_PACIENTE" ON "USUARIO_PACIENTE"."COD_USUARIO" = "SOCIAL_PACIENTE"."COD_USUARIO" 
            INNER JOIN "VARIABLES_SOCIALES" ON "SOCIAL_PACIENTE"."COD_VARIABLES_SOCIALES" = "VARIABLES_SOCIALES"."COD_VARIABLES_SOCIALES" 
            INNER JOIN "SANITARIA_PACIENTE" ON "USUARIO_PACIENTE"."COD_USUARIO" = "SANITARIA_PACIENTE"."COD_USUARIO" 
            INNER JOIN "VARIABLES_SANITARIAS" ON "SANITARIA_PACIENTE"."COD_VARIABLES_SANITARIAS" = "VARIABLES_SANITARIAS"."COD_VARIABLES_SANITARIAS"
            inner join public."PACIENTE_WEARABLE" on
                "USUARIO_PACIENTE"."COD_USUARIO" = "PACIENTE_WEARABLE"."COD_USUARIO" 
            where "USUARIO_PRIVADO"."F_BAJA" is null and "PACIENTE_CASA"."F_BAJA" is null and "USUARIO_PRIVADO"."COD_USUARIO" = @COD_PACIENTE
		    GROUP BY "USUARIO_PRIVADO"."COD_USUARIO"
        ''';
      Pacientes = await connection!.query(
        pacientes_query,
        substitutionValues: {'COD_PACIENTE': COD_PACIENTE},
      );
      await connection!.close();
      //return [Casa!, Habitaciones!];
      return [
        Casa!,
        Habitaciones_Filtradas,
        Pacientes,
        Sensores_Puerta,
        SmartMeter,
      ];
    } catch (e) {
      await connection!.close();
      return [];
    }
  }
}
