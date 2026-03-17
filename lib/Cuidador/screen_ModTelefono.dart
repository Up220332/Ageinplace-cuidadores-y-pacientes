import 'package:ageinplace/log-in/screen_LogIn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../../base_de_datos/postgres.dart';
import '../Cuidador/screen_Pacientes.dart';

class ModTlfnCuidadorScreen extends StatefulWidget {
  const ModTlfnCuidadorScreen({super.key});

  @override
  State<ModTlfnCuidadorScreen> createState() => _ModTlfnCuidadorScreenState();
}

class _ModTlfnCuidadorScreenState extends State<ModTlfnCuidadorScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _phoneNumberController = TextEditingController();
  late bool passwordVisibility = false;
  String? phoneNumber;

  final colorPrimario = const Color.fromARGB(255, 25, 144, 234);
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  void _mostrarDialogo(BuildContext context, String titulo, String mensaje, Color color, {VoidCallback? onAccept}) {
    final isSpanish = FlutterLocalization.instance.currentLocale?.languageCode == 'es';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                color == Colors.red ? Icons.error : Icons.check_circle,
                color: color == Colors.red ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 10),
              Text(
                titulo,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onAccept != null) {
                  onAccept();
                }
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSpanish = FlutterLocalization.instance.currentLocale?.languageCode == 'es';
    
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
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
          isSpanish ? 'Modificar Teléfono' : 'Edit Phone',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header informativo
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
                  child: Row(
                    children: [
                      Icon(
                        Icons.phone_android,
                        color: colorPrimario,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isSpanish
                              ? 'Actualice su número de teléfono'
                              : 'Update your phone number',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Campo de teléfono
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
                  child: IntlPhoneField(
                    invalidNumberMessage: isSpanish ? 'Número inválido' : 'Invalid number',
                    controller: _phoneNumberController,
                    searchText: isSpanish ? 'Buscar' : 'Search',
                    textAlignVertical: TextAlignVertical.bottom,
                    decoration: InputDecoration(
                      labelText: isSpanish ? 'Número de teléfono *' : 'Phone number *',
                      labelStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      prefixIcon: Icon(Icons.phone, size: 20, color: colorPrimario),
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
                    initialCountryCode: 'ES',
                    onChanged: (phone) {
                      setState(() {
                        phoneNumber = phone.completeNumber;
                      });
                    },
                    validator: (phone) {
                      if (phone == null || phone.number.isEmpty) {
                        return isSpanish ? 'Campo obligatorio' : 'Required field';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 30),

                // Botón de guardar
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _continuaButton();
                      }
                    },
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: Text(
                      isSpanish ? 'Actualizar Teléfono' : 'Update Phone',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 1.1,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorPrimario,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Texto informativo
                Center(
                  child: Text(
                    isSpanish
                        ? 'Ingrese su nuevo número de teléfono'
                        : 'Enter your new phone number',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ********************************************************************
  /// Funcion que actualiza el teléfono en la base de datos
  ///*******************************************************************
  Future<void> _continuaButton() async {
    final isSpanish = FlutterLocalization.instance.currentLocale?.languageCode == 'es';
    
    if (phoneNumber == null || phoneNumber!.isEmpty) {
      _mostrarDialogo(
        context,
        isSpanish ? 'Error' : 'Error',
        isSpanish ? 'Por favor ingrese un número de teléfono' : 'Please enter a phone number',
        Colors.red,
      );
      return;
    }
    
    try {
      var result = await DBPostgres().DBModTlfnCuidador(
        usuario[0].CodUsuario,
        phoneNumber!,
      );
      
      if (result == true) {
        _mostrarDialogo(
          context,
          isSpanish ? 'Éxito' : 'Success',
          isSpanish ? 'Teléfono actualizado correctamente' : 'Phone updated successfully',
          Colors.green,
          onAccept: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PacientesCuidadorScreen()),
            );
          },
        );
      } else {
        String errorMsg = result.toString().toLowerCase();
        if (errorMsg.contains('ya existe') || errorMsg.contains('duplicate') || errorMsg.contains('unique')) {
          _mostrarDialogo(
            context,
            isSpanish ? 'Error' : 'Error',
            isSpanish ? 'El número de teléfono ya está registrado' : 'Phone number already registered',
            Colors.red,
          );
        } else {
          _mostrarDialogo(
            context,
            isSpanish ? 'Error' : 'Error',
            isSpanish ? 'Error al actualizar el teléfono' : 'Error updating phone',
            Colors.red,
          );
        }
      }
    } catch (e) {
      _mostrarDialogo(
        context,
        isSpanish ? 'Error' : 'Error',
        isSpanish ? 'Error al conectar con el servidor' : 'Error connecting to server',
        Colors.red,
      );
    }
  }
}