import 'dart:math';

import 'package:ageinplace/log-in/screen_LogIn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';

import '../E-MailSender/E-MailSend.dart';
import '../base_de_datos/postgres.dart';
import '../localization/locales.dart';

class RecuperarContrasegnaScreen extends StatefulWidget {
  const RecuperarContrasegnaScreen({super.key});

  @override
  State<RecuperarContrasegnaScreen> createState() =>
      _RecuperarContrasegnaScreenSate();
}

class _RecuperarContrasegnaScreenSate
    extends State<RecuperarContrasegnaScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _EmailController = TextEditingController();
  bool _btnActiveEmail = false;
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();
  bool isLoading = false;
  bool errorOccurred = false;
  String errorMessage = "";
  late FlutterLocalization _flutterLocalization;
  late String _currentLocale;

  final colorPrimario = const Color.fromARGB(255, 25, 144, 234);

  @override
  void initState() {
    super.initState();
    _flutterLocalization = FlutterLocalization.instance;
    _currentLocale = _flutterLocalization.currentLocale!.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    final isSpanish = _currentLocale == 'es';

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          // Fondo con gradiente sutil (como en tus pantallas)
          Container(
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
          ),
          
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
          
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Botón de retroceso (como en ModPaciente)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: colorPrimario,
                            size: 24,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    Image.asset(
                      'assets/images/Logo1.png',
                      width: 120,
                      height: 110,
                      fit: BoxFit.fitHeight,
                    ),
                    
                    // Título
                    Text(
                      'Imp Tracker',
                      style: GoogleFonts.lato(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: colorPrimario,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorPrimario.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorPrimario.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            LocaleData.passwordForgottenText1.getString(context),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            LocaleData.passwordForgottenText2.getString(context),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Campo de email
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _EmailController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) => value == null || value.isEmpty
                            ? (isSpanish ? 'Campo requerido' : 'Required field')
                            : null,
                        onChanged: (value) {
                          setState(() {
                            _btnActiveEmail = value.isNotEmpty;
                          });
                        },
                        style: GoogleFonts.lato(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: LocaleData.inputEmail.getString(context),
                          labelStyle: GoogleFonts.lato(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          hintText: isSpanish ? 'ejemplo@correo.com' : 'example@email.com',
                          hintStyle: GoogleFonts.lato(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: colorPrimario,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Botón de enviar
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: _btnActiveEmail ? EnviaButton : null,
                        icon: Icon(
                          Icons.send_rounded,
                          color: _btnActiveEmail ? Colors.white : Colors.grey.shade400,
                          size: 20,
                        ),
                        label: Text(
                          LocaleData.inputSend.getString(context),
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _btnActiveEmail ? Colors.white : Colors.grey.shade400,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _btnActiveEmail ? colorPrimario : Colors.grey.shade200,
                          foregroundColor: _btnActiveEmail ? Colors.white : Colors.grey.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: _btnActiveEmail ? 4 : 0,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Texto de ayuda 
                    TextButton(
                      onPressed: () => _mostrarDialogoAyuda(context, isSpanish),
                      child: Text(
                        isSpanish ? '¿Necesitas ayuda?' : 'Need help?',
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
          
          // Barra de notificación
          if (isLoading || errorOccurred)
            Positioned(
              left: 20,
              right: 20,
              bottom: 30,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isLoading ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (isLoading ? Colors.green : Colors.red).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      isLoading ? Icons.hourglass_top : Icons.error_outline,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isLoading
                            ? LocaleData.sendingPassword.getString(context)
                            : errorMessage,
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
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

  void _mostrarDialogoAyuda(BuildContext context, bool isSpanish) {
    showDialog(
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
                isSpanish ? 'Ayuda' : 'Help',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isSpanish
                    ? 'Si no recibes el correo de recuperación:'
                    : "If you don't receive the recovery email:",
                style: GoogleFonts.lato(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _buildAyudaItem(
                Icons.check_circle,
                isSpanish ? 'Revisa tu carpeta de spam' : 'Check your spam folder',
              ),
              const SizedBox(height: 8),
              _buildAyudaItem(
                Icons.check_circle,
                isSpanish ? 'Verifica que el email sea correcto' : 'Verify the email is correct',
              ),
              const SizedBox(height: 8),
              _buildAyudaItem(
                Icons.check_circle,
                isSpanish ? 'Espera unos minutos y reintenta' : 'Wait a few minutes and retry',
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
                child: Text(
                  isSpanish ? 'Aceptar' : 'OK',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAyudaItem(IconData icon, String texto) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.green),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            style: GoogleFonts.lato(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Future<void> EnviaButton() async {
    setState(() {
      isLoading = true;
      errorOccurred = false;
      errorMessage = "";
    });

    var NewPassword = getRandomString(15);
    var newuserOk = await DBPostgres().DBNewPassword(
      _EmailController.text,
      NewPassword.toString(),
    );

    setState(() {
      isLoading = false;
      if (newuserOk == 'correcto') {
        SendNewPassword(_EmailController.text, NewPassword.toString());
        
        final isSpanish = _currentLocale == 'es';
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 10),
                Text(isSpanish ? 'Éxito' : 'Success'),
              ],
            ),
            content: Text(
              isSpanish
                  ? 'Se ha enviado una nueva contraseña a tu correo'
                  : 'A new password has been sent to your email',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LogInScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: colorPrimario,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isSpanish ? 'Aceptar' : 'OK',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        errorOccurred = true;
        errorMessage = LocaleData.errorOccurredPas.getString(context);
      }
    });
  }

  String getRandomString(int length) => String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length)),
    ),
  );
}