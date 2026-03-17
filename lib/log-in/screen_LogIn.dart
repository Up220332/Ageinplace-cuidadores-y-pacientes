import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/locales.dart';
import '../Cuidador/screen_Pacientes.dart';
import '../base_de_datos/postgres.dart';
import '../services/Tareas.dart';
import '../recuperar_contraseña/screen_RecuperarContrseña.dart';

// Clase para manejar la sesión en memoria
class SesionActual {
  static int? codUsuario;
  static String? rol;
  static String? email;
  static String? nombre;
  
  static void limpiar() {
    codUsuario = null;
    rol = null;
    email = null;
    nombre = null;
  }
}

List<Usuario> usuario = [];
Usuario UsuarioCuidador = Usuario(0, '', '', '', '', '', '', '', '', '', '');
int userCaregiverId = 0;

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late bool passwordVisibility = false;
  late bool circular = false;
  bool isLoading = false;
  bool errorOccurred = false;
  bool _btnActiveEmail = false;
  bool _btnActivePassword = false;
  late FlutterLocalization _flutterLocalization;
  late String _currentLocale;
  String selectedLanguage = 'es';
  
  final colorPrimario = const Color.fromARGB(255, 25, 144, 234);
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _flutterLocalization = FlutterLocalization.instance;
    _currentLocale = _flutterLocalization.currentLocale?.languageCode ?? 'es';
    selectedLanguage = _currentLocale;
    
    // Limpiar cualquier sesión anterior al iniciar
    SesionActual.limpiar();
  }

  void _setLocale(String? value) {
    if (value == null) return;
    _flutterLocalization.translate(value);
    setState(() { 
      _currentLocale = value;
      selectedLanguage = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            decoration: BoxDecoration(
              color: colorPrimario.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: colorPrimario.withOpacity(0.3)),
            ),
            child: DropdownButton<String>(
              value: selectedLanguage,
              icon: Icon(Icons.language, color: colorPrimario, size: 20),
              underline: const SizedBox(),
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black87, fontSize: 14),
              items: [
                DropdownMenuItem(
                  value: "es",
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      Text(LocaleData.es.getString(context)),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: "en",
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      Text(LocaleData.en.getString(context)),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value!;
                  _setLocale(value);
                });
              },
            ),
          ),
        ],
      ),
      key: scaffoldKey,
      body: Stack(
        children: [
          // Imagen de fondo
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: const Color.fromARGB(0, 255, 255, 255),
              image: DecorationImage(
                fit: BoxFit.fill,
                image: Image.asset('assets/images/launchScreen@3x.png').image,
              ),
            ),
          ),
          // Contenido principal
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    Image.asset(
                      'assets/images/Logo1.png',
                      width: 120,
                      height: 110,
                      fit: BoxFit.fitHeight,
                    ),
                    
                    const SizedBox(height: 10),
                    
                    Text(
                      'Imp Tracker',
                      style: GoogleFonts.poppins(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: colorPrimario,
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    Text(
                      LocaleData.body.getString(context),
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Campo E-Mail
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: emailController,
                        obscureText: false,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return LocaleData.errorField.getString(context);
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _btnActiveEmail = value.isNotEmpty;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: LocaleData.inputEmail.getString(context),
                          hintText: 'ejemplo@correo.com',
                          prefixIcon: Icon(Icons.email_outlined, color: colorPrimario, size: 22),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: colorPrimario, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.red, width: 1),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: !passwordVisibility,
                        onChanged: (value) {
                          setState(() {
                            _btnActivePassword = value.isNotEmpty;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: LocaleData.inputPassword.getString(context),
                          hintText: '••••••••',
                          prefixIcon: Icon(Icons.lock_outline, color: colorPrimario, size: 22),
                          suffixIcon: IconButton(
                            icon: Icon(
                              passwordVisibility ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: Colors.grey.shade500,
                              size: 22,
                            ),
                            onPressed: () => setState(() => passwordVisibility = !passwordVisibility),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: colorPrimario, width: 2),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Olvido contraseña
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RecuperarContrasegnaScreen()),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: colorPrimario,
                        ),
                        child: Text(
                          LocaleData.passwordForgotten.getString(context),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Botón de login 
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () {
                          if (emailController.text.isNotEmpty) {
                            LoginButton(emailController.text, passwordController.text);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _currentLocale == 'es' 
                                      ? 'Por favor ingresa tu email' 
                                      : 'Please enter your email'
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorPrimario,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    LocaleData.logging.getString(context),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                LocaleData.inputLogIn.getString(context),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
          
          if (isLoading || (!isLoading && errorOccurred))
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: isLoading ? Colors.green : Colors.red,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isLoading ? Icons.info_outline : Icons.error_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isLoading 
                          ? LocaleData.logging.getString(context)
                          : LocaleData.errorOccurredLog.getString(context),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> LoginButton(String email, String password) async {
    setState(() {
      isLoading = true;
      errorOccurred = false;
    });

    try {
      var userResponse = await DBPostgres().DBLogIn(email, password);
      
      if (userResponse == null || userResponse[1] == null || userResponse[1].isEmpty) {
        _showErrorDialog("Usuario o contraseña incorrectos.");
        setState(() {
          isLoading = false;
          errorOccurred = true;
        });
        return;
      }

      String userTypeFromDB = userResponse[0].toString().trim().toLowerCase();

      usuario.clear();
      for (var p in userResponse[1]) {
        usuario.add(Usuario(
          p[0], p[1], p[2], p[3], p[4], 
          p[5], p[6], p[7], p[8], userTypeFromDB, password
        ));
      }

      if (userTypeFromDB == 'cuidador') {
        SesionActual.codUsuario = usuario[0].CodUsuario;
        SesionActual.rol = usuario[0].TipoUsuario;
        SesionActual.email = usuario[0].Email;
        SesionActual.nombre = usuario[0].Nombre;

        // await saveLoginStatus(usuario[0].TipoUsuario, usuario[0].CodUsuario);
        
        if (Platform.isAndroid || Platform.isIOS) {
          int codUser = usuario[0].CodUsuario;
          await saveIntegerToMemory(codUser);
          FlutterBackgroundService().invoke("setAsBackground");
        }
        
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PacientesCuidadorScreen()),
          );
        }
      } else {
        _showUnauthorizedDialog(userTypeFromDB);
        setState(() {
          isLoading = false;
          errorOccurred = true;
        });
      }
    } catch (e) {
      print("Error Login: $e");
      setState(() {
        errorOccurred = true;
        isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 10),
            const Text('Error', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: colorPrimario,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Aceptar',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUnauthorizedDialog(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.block, color: Colors.red),
            const SizedBox(width: 10),
            const Text('Acceso Denegado', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Esta aplicación es exclusiva para Cuidadores.'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tu cuenta fue detectada como: "$type".',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: colorPrimario,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Entendido',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> saveLoginStatus(String rol, int userId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // await prefs.setBool('isLoggedIn', true);
  // await prefs.setString('rol', rol);
  // await prefs.setInt('CodUsuario', userId);
}

Future<void> saveIntegerToMemory(int cod) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('CodUsuarioCuidador', cod);
}

class Usuario {
  final int CodUsuario;
  final String Nombre;
  final String Apellido1;
  final String Apellido2;
  final String FechaNacimiento;
  final String Telefono;
  final String Email;
  final String Password;
  final String Organizacion;
  final String TipoUsuario;
  final String PasswordValidator;

  Usuario(
    this.CodUsuario,
    this.Nombre,
    this.Apellido1,
    this.Apellido2,
    this.FechaNacimiento,
    this.Telefono,
    this.Email,
    this.Password,
    this.Organizacion,
    this.TipoUsuario,
    this.PasswordValidator,
  );
}