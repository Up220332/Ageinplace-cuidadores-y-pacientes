class Wearable {
  final int CodWearable;
  final String IdWearable;
  final int? CodUsuario;
  final String CodPacienteWearable;
  final String TipoWeareable;
  final DateTime? F_ALTA;
  final DateTime? F_BAJA;
  final String DesOtros;
  final int CodTipoWearable;
  final String Estado;

  Wearable(
    this.CodWearable,
    this.IdWearable,
    this.CodUsuario,
    this.CodPacienteWearable,
    this.TipoWeareable,
    this.F_ALTA,
    this.F_BAJA,
    this.DesOtros,
    this.CodTipoWearable,
    this.Estado,
  );

  factory Wearable.fromJson(Map<String, dynamic> json) => Wearable(
    json['CodWearable'],
    json['IdWearable'],
    json['CodUsuario'],
    json['CodPacienteWearable'],
    json['TipoWeareable'],
    json['F_ALTA'] != null ? DateTime.parse(json['F_ALTA']) : null,
    json['F_BAJA'] != null ? DateTime.parse(json['F_BAJA']) : null,
    json['DesOtros'],
    json['CodTipoWearable'],
    json['Estado'],
  );

  Map<String, dynamic> toJson() => {
    'CodWearable': CodWearable,
    'IdWearable': IdWearable,
    'CodUsuario': CodUsuario,
    'CodPacienteWearable': CodPacienteWearable,
    'TipoWeareable': TipoWeareable,
    'F_ALTA': F_ALTA?.toIso8601String(),
    'F_BAJA': F_BAJA?.toIso8601String(),
    'DesOtros': DesOtros,
    'CodTipoWearable': CodTipoWearable,
    'Estado': Estado,
  };
}

class TipoWearable {
  final int CodTipoWearable;
  final String TipoWearableTabla;

  TipoWearable(this.CodTipoWearable, this.TipoWearableTabla);
}