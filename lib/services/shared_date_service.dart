import 'package:intl/intl.dart';

class SharedDateService {
  static DateTime? _fechaInicio;
  static DateTime? _fechaFin;
  
  // Getters
  static DateTime? get fechaInicio => _fechaInicio;
  static DateTime? get fechaFin => _fechaFin;
  
  // Setters
  static set fechaInicio(DateTime? fecha) {
    _fechaInicio = fecha;
  }
  
  static set fechaFin(DateTime? fecha) {
    _fechaFin = fecha;
  }
  
  // Método para actualizar ambas fechas
  static void setRango(DateTime? inicio, DateTime? fin) {
    _fechaInicio = inicio;
    _fechaFin = fin;
  }
  
  // Formateadores útiles
  static String getRangoFormateado({bool isSpanish = true}) {
    if (_fechaInicio == null || _fechaFin == null) {
      return isSpanish ? 'Seleccionar rango' : 'Select range';
    }
    return '${DateFormat('dd/MM/yyyy').format(_fechaInicio!)} - ${DateFormat('dd/MM/yyyy').format(_fechaFin!)}';
  }
  
  // Valores por defecto (últimos 7 días)
  static void setDefaultRange() {
    final ahora = DateTime.now();
    _fechaInicio = DateTime(
      ahora.year,
      ahora.month,
      ahora.day,
      0, 0,
    ).subtract(const Duration(days: 7));
    _fechaFin = DateTime(
      ahora.year,
      ahora.month,
      ahora.day,
      23, 59,
    );
  }
  
  // Limpiar fechas
  static void clear() {
    _fechaInicio = null;
    _fechaFin = null;
  }
}