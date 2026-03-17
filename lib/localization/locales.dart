import 'package:flutter_localization/flutter_localization.dart';

const List<MapLocale> locales = [
  MapLocale("es", LocaleData.ES),
  MapLocale("en", LocaleData.EN),
];

mixin LocaleData {
  static const String titleCaregiver = "titleCaregiver";
  static const String body = "body";
  static const String inputEmail = "inputEmail";
  static const String inputPassword = "inputPassword";
  static const String inputLogIn = "inputLogIn";
  static const String passwordForgotten = "passwordForgotten";
  static const String es = "es";
  static const String en = "en";
  static const String passwordForgottenText1 = "passwordForgottenText1";
  static const String passwordForgottenText2 = "passwordForgottenText2";
  static const String inputSend = "inputSend";
  static const String errorField = "errorField";
  static const String logging = "logging";
  static const String errorOccurredLog = "errorOccurredLog";
  static const String errorOccurredPas = "errorOccurredPas";
  static const String sendingPassword = "sendingPassword";
  static const String pacientes = "pacientes";
  static const String configuracion = "configuracion";
  static const String cambiarContrasena = "cambiarContrasena"; 
  static const String editarTelefono = "editarTelefono";
  static const String idioma = "idioma";
  static const String seleccionarIdioma = "seleccionarIdioma";
  static const String espanol = "espanol"; 
  static const String ingles = "ingles";
  static const String cerrarSesion = "cerrarSesion";
  static const String cerrarSesionPregunta = "cerrarSesionPregunta";
  static const String cancelar = "cancelar";
  static const String si = "si";

  static const Map<String, dynamic> ES = {
    titleCaregiver: 'Pacientes',
    body: 'Bienvenido! Es un gusto volver a verte',
    inputEmail: 'Correo electrónico',
    inputPassword: 'Contraseña',
    inputLogIn: 'Iniciar sesión',
    passwordForgotten: '¿Ha olvidado su contraseña?',
    es: 'Español',
    en: 'Inglés',
    passwordForgottenText1: 'Introduzca su correo electrónico',
    passwordForgottenText2: 'Se le enviará un correo con su contraseña',
    inputSend: 'Enviar',
    errorField: 'El campo no puede estar vacío',
    logging: 'Iniciando sesión...',
    errorOccurredLog: 'Correo o contraseña incorrecta. Intenta de nuevo',
    sendingPassword: 'Enviando contraseña al correo...',
    errorOccurredPas: 'Correo incorrecto. Intenta de nuevo',
    pacientes: 'Pacientes',
    configuracion: 'Configuración',
    cambiarContrasena: 'Cambiar contraseña',
    editarTelefono: 'Editar teléfono',
    idioma: 'Idioma',
    seleccionarIdioma: 'Seleccionar idioma',
    espanol: 'Español',
    ingles: 'English',
    cerrarSesion: 'Cerrar sesión',
    cerrarSesionPregunta: '¿Estás seguro de que deseas cerrar sesión?',
    cancelar: 'Cancelar',
    si: 'Sí',
  };

  static const Map<String, dynamic> EN = {
    titleCaregiver: 'Patients',
    body: 'Welcome back! Nice to see you again',
    inputEmail: 'Email',
    inputPassword: 'Password',
    inputLogIn: 'Sign in',
    passwordForgotten: 'Forgot your password?',
    es: 'Spanish',
    en: 'English',
    passwordForgottenText1: 'Enter your email address',
    passwordForgottenText2: 'An email will be sent to you with your password',
    inputSend: 'Send',
    errorField: 'The field cannot be empty',
    logging: 'Logging in...',
    errorOccurredLog: 'Incorrect email or password. Please try again',
    sendingPassword: 'Sending password to email...',
    errorOccurredPas: 'Incorrect email. Please try again',
    pacientes: 'Patients',
    configuracion: 'Settings',
    cambiarContrasena: 'Change password',
    editarTelefono: 'Edit phone',
    idioma: 'Language',
    seleccionarIdioma: 'Select language',
    espanol: 'Spanish',
    ingles: 'English',
    cerrarSesion: 'Logout',
    cerrarSesionPregunta: 'Are you sure you want to logout?',
    cancelar: 'Cancel',
    si: 'Yes',
  };
}