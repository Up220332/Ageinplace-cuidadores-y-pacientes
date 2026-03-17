import 'dart:async';
import 'package:ageinplace/log-in/screen_LogIn.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Cuidador/screen_Pacientes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    await Future.delayed(const Duration(seconds: 3));

    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? rol = prefs.getString('rol');

    if (isLoggedIn && rol != null) {
      await loadUserFromPrefs();

      String normalizedRol = rol.trim().toLowerCase();

      if (normalizedRol == 'cuidador') {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PacientesCuidadorScreen()),
        );
        return;
      }
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LogInScreen()),
    );
  }

  Future<void> loadUserFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? codUsuario = prefs.getInt('CodUsuario');
    String? rol = prefs.getString('rol');

    if (codUsuario != null && rol != null) {
      usuario.clear();
      usuario.add(
        Usuario(
          codUsuario,
          '', // Nombre
          '', // Apellido1
          '', // Apellido2
          '', // FechaNacimiento
          '', // Telefono
          '', // Email
          '', // Password (en el modelo que pasaste va aquí)
          '', // Organizacion
          rol, // TipoUsuario
          '', // PasswordValidator
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          Center(
            child: Image.asset(
              'assets/images/Logo1.png', 
              width: 200,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.apps, size: 100, color: Color.fromARGB(255, 25, 144, 234));
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Imp Tracker',
            style: GoogleFonts.poppins(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 25, 144, 234),
            ),
          ),
        ],
      ),
    );
  }
}