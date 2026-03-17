import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../../base_de_datos/postgres.dart';
import '../../models/wearable.dart';
import '../Cuidador/screen_Paciente.dart';
import '../Cuidador/screen_Pacientes.dart';

class ModPacienteScreen extends StatefulWidget {
  final Pacientes paciente;
  final Wearable wearable;

  const ModPacienteScreen({
    super.key,
    required this.paciente,
    required this.wearable,
  });

  @override
  State<ModPacienteScreen> createState() => _ModPacienteScreenState();
}

class _ModPacienteScreenState extends State<ModPacienteScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surname1Controller = TextEditingController();
  final TextEditingController _surname2Controller = TextEditingController();
  final TextEditingController _dateBirthController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _organitationController = TextEditingController();
  final TextEditingController _desOtrosSanitariaController = TextEditingController();
  final TextEditingController _desOtrosSocialController = TextEditingController();
  
  List<int> CodVarSanitariaList = [];
  List<int> CodVarSocialList = [];
  final listaVariablesSociales = <int>[];
  final listaVariablesSanitaria = <int>[];

  late String phoneNumber = '';
  bool _btnActiveName = true;
  bool _btnActiveSurname1 = true;
  bool _btnActiveDateBirth = true;
  bool _btnActiveEmail = true;

  List<VariablesSociales> variableSocialList = [];
  List<VariablesSanitarias> variableSanitariaList = [];

  final colorPrimario = const Color.fromARGB(255, 25, 144, 234);
  final _formKey = GlobalKey<FormState>();
  
  // Variable para idioma
  late bool isSpanish;

  Map<String, String> translationsVarSocial = {
    "Autónomo": "Autonomous",
    "Dependiente grave": "Severely Dependent",
    "Dependiente leve": "Mildly Dependent",
    "Riesgo aislamiento": "Isolation Risk",
    "Tensiones económicas": "Economic Tensions",
    "Con red social de apoyo": "With Social Support Network",
    "Red social apoyo reducida": "Reduced Social Support Network",
    "Sin red social de apoyo": "Without Social Support Network",
    "Otros": "Others",
  };

  Map<String, String> translationsVarSanitaria = {
    "Adicciones": "Addictions",
    "Alzheimer": "Alzheimer",
    "Anemia": "Anemia",
    "Ansiedad": "Anxiety",
    "Artrosis": "Osteoarthritis",
    "Cáncer": "Cancer",
    "Demencia": "Dementia",
    "Depresion": "Depression",
    "Diabetes": "Diabetes",
    "Esquizofrenia": "Schizophrenia",
    "Fragilidad": "Frailty",
    "Hipertensión": "Hypertension",
    "Ictus": "Stroke",
    "Incontinencia Urinaria": "Urinary Incontinence",
    "Infarto": "Heart Attack",
    "Osteoporosis": "Osteoporosis",
    "Parkinson": "Parkinson's",
    "Problemas auditivos": "Hearing Problems",
    "Problemas visuales": "Visual Problems",
    "Sano": "Healthy",
    "Trastornos de sueño": "Sleep Disorders",
    "Trastornos mentales": "Mental Disorders",
    "Otros": "Others",
  };

  Future<String> getVariableSanitaria() async {
    var Dbdata = await DBPostgres().DBGetVariableSanitarias();
    setState(() {
      for (var p in Dbdata) {
        variableSanitariaList.add(VariablesSanitarias(p[0], p[1]));
      }
    });
    return 'Successfully Fetched data';
  }

  Future<String> getVariableSocial() async {
    var Dbdata = await DBPostgres().DBGetVariableSocial();
    setState(() {
      for (var p in Dbdata) {
        variableSocialList.add(VariablesSociales(p[0], p[1]));
      }
    });
    return 'Successfully Fetched data';
  }

  Future<String> getVariablesPaciente() async {
    var Dbdata = await DBPostgres().DBGetVariablePaciente(
      widget.paciente.CodPaciente,
    );
    setState(() {
      for (final row in Dbdata[0]) {
        final codVariableSocial = row[0] as int;
        listaVariablesSociales.add(codVariableSocial);
      }
      for (final row in Dbdata[1]) {
        final codVariableSanitaria = row[0] as int;
        listaVariablesSanitaria.add(codVariableSanitaria);
      }
    });
    return 'Successfully Fetched data';
  }

  @override
  void initState() {
    super.initState();
    
    // Inicializar idioma y listener
    FlutterLocalization.instance.onTranslatedLanguage = _onLanguageChanged;
    isSpanish = FlutterLocalization.instance.currentLocale?.languageCode == 'es';
    
    getVariableSanitaria();
    getVariableSocial();
    getVariablesPaciente();
    _nameController.text = widget.paciente.Nombre;
    _surname1Controller.text = widget.paciente.Apellido1;
    _surname2Controller.text = widget.paciente.Apellido2;
    _dateBirthController.text = widget.paciente.FechaNacimiento;
    _phoneNumberController.text = widget.paciente.Telefono;
    _emailController.text = widget.paciente.Email;
    _organitationController.text = widget.paciente.Organizacion;
    _desOtrosSanitariaController.text = widget.paciente.DesVarSanitaria;
    _desOtrosSocialController.text = widget.paciente.DesVarSocial;
    CodVarSocialList = listaVariablesSociales;
    CodVarSanitariaList = listaVariablesSanitaria;
  }

  void _onLanguageChanged(Locale? locale) {
    if (mounted) {
      setState(() {
        isSpanish = locale?.languageCode == 'es';
      });
    }
  }

  @override
  void dispose() {
    FlutterLocalization.instance.onTranslatedLanguage = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PacienteCuidadorScreen(
              paciente: widget.paciente,
              wearable: widget.wearable,
            ),
          ),
        );
        return false;
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          backgroundColor: colorPrimario,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.5),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            isSpanish ? 'Modificar Paciente' : 'Edit Patient',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
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
                            Icons.elderly,
                            color: colorPrimario,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isSpanish
                                  ? 'Modifique los datos del paciente'
                                  : 'Edit patient information',
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

                    const SizedBox(height: 24),

                    // Información personal
                    _buildSectionTitle(
                      isSpanish ? 'INFORMACIÓN PERSONAL' : 'PERSONAL INFORMATION',
                      Icons.person,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _nameController,
                      label: isSpanish ? 'Nombre' : 'First Name',
                      icon: Icons.badge,
                      required: true,
                      onChanged: (value) => setState(() => _btnActiveName = value.isNotEmpty),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          _btnActiveName = false;
                          return isSpanish ? 'Campo obligatorio' : 'Required field';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _surname1Controller,
                            label: isSpanish ? 'Primer Apellido' : 'First Surname',
                            icon: Icons.family_restroom,
                            required: true,
                            onChanged: (value) => setState(() => _btnActiveSurname1 = value.isNotEmpty),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                _btnActiveSurname1 = false;
                                return isSpanish ? 'Obligatorio' : 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _surname2Controller,
                            label: isSpanish ? 'Segundo Apellido' : 'Second Surname',
                            icon: Icons.family_restroom,
                            onChanged: (value) {},
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Fecha de nacimiento
                    _buildDateField(),

                    const SizedBox(height: 24),

                    // Información de contacto
                    _buildSectionTitle(
                      isSpanish ? 'INFORMACIÓN DE CONTACTO' : 'CONTACT INFORMATION',
                      Icons.contact_mail,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _emailController,
                      label: isSpanish ? 'Correo electrónico' : 'Email',
                      icon: Icons.email,
                      required: true,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) => setState(() => _btnActiveEmail = value.isNotEmpty),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          _btnActiveEmail = false;
                          return isSpanish ? 'Campo obligatorio' : 'Required field';
                        } else if (!value.contains('@')) {
                          _btnActiveEmail = false;
                          return isSpanish ? 'Email inválido' : 'Invalid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildPhoneField(),

                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _organitationController,
                      label: isSpanish ? 'Organización' : 'Organization',
                      icon: Icons.business,
                      onChanged: (value) {},
                    ),

                    const SizedBox(height: 24),

                    // Variables del paciente
                    _buildSectionTitle(
                      isSpanish ? 'VARIABLES DEL PACIENTE' : 'PATIENT VARIABLES',
                      Icons.health_and_safety,
                    ),
                    const SizedBox(height: 16),

                    // Variables Sociales
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
                      child: MultiSelectDialogField<int>(
                        initialValue: CodVarSocialList.toList(),
                        items: variableSocialList.map((item) {
                          return MultiSelectItem<int>(
                            item.CodVariableSocial,
                            isSpanish
                                ? item.VariableSocial
                                : (translationsVarSocial[item.VariableSocial] ?? item.VariableSocial),
                          );
                        }).toList(),
                        title: Text(isSpanish ? 'Variables Sociales' : 'Social Variables'),
                        selectedColor: colorPrimario,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        buttonText: Text(
                          isSpanish ? 'Variables Sociales *' : 'Social Variables *',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        buttonIcon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey.shade600,
                        ),
                        onConfirm: (results) {
                          if (results.isEmpty) {
                            _showErrorDialog(
                              context,
                              isSpanish 
                                  ? 'Debe seleccionar al menos una variable.'
                                  : 'You must select at least one variable.',
                            );
                          } else {
                            setState(() {
                              CodVarSocialList = results.cast<int>();
                            });
                            if (CodVarSocialList.contains(0)) {
                              _showOtrosSocialValuePopup(context);
                            }
                          }
                        },
                        chipDisplay: MultiSelectChipDisplay.none(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Variables Sanitarias
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
                      child: MultiSelectDialogField<int>(
                        listType: MultiSelectListType.LIST,
                        initialValue: CodVarSanitariaList.toList(),
                        items: variableSanitariaList.map((item) {
                          return MultiSelectItem<int>(
                            item.CodVariableSanitaria,
                            isSpanish
                                ? item.VariableSanitaria
                                : (translationsVarSanitaria[item.VariableSanitaria] ?? item.VariableSanitaria),
                          );
                        }).toList(),
                        title: Text(isSpanish ? 'Variables Sanitarias' : 'Health Variables'),
                        selectedColor: colorPrimario,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        buttonText: Text(
                          isSpanish ? 'Variables Sanitarias *' : 'Health Variables *',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        buttonIcon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey.shade600,
                        ),
                        onConfirm: (results) {
                          if (results.isEmpty) {
                            _showErrorDialog(
                              context,
                              isSpanish 
                                  ? 'Debe seleccionar al menos una variable.'
                                  : 'You must select at least one variable.',
                            );
                          } else {
                            setState(() {
                              CodVarSanitariaList = results.cast<int>();
                            });
                            if (CodVarSanitariaList.contains(0)) {
                              _showOtrosSanitarioValuePopup(context);
                            }
                          }
                        },
                        chipDisplay: MultiSelectChipDisplay.none(),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Botón de guardar
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (_btnActiveName && _btnActiveSurname1 && 
                                _btnActiveEmail && _btnActiveDateBirth) {
                              _continuaButton();
                            }
                          }
                        },
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: Text(
                          isSpanish ? 'Guardar Cambios' : 'Save Changes',
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

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorPrimario),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey[800],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Divider(
            color: Colors.grey.shade300,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
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
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          labelStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          prefixIcon: Icon(icon, size: 20, color: colorPrimario),
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
    );
  }

  Widget _buildDateField() {
    return Container(
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
        controller: _dateBirthController,
        readOnly: true,
        onTap: () => _selectDateBirth(context),
        validator: (value) {
          if (value == null || value.isEmpty) {
            _btnActiveDateBirth = false;
            return isSpanish ? 'Campo obligatorio' : 'Required field';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: isSpanish ? 'Fecha de nacimiento *' : 'Birth date *',
          labelStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          prefixIcon: Icon(Icons.cake, size: 20, color: colorPrimario),
          suffixIcon: Icon(Icons.calendar_today, size: 18, color: colorPrimario),
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
    );
  }

  Widget _buildPhoneField() {
    return Container(
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
        controller: _phoneNumberController,
        invalidNumberMessage: isSpanish ? 'Número inválido' : 'Invalid number',
        searchText: isSpanish ? 'Buscar' : 'Search',
        textAlignVertical: TextAlignVertical.bottom,
        decoration: InputDecoration(
          labelText: isSpanish ? 'Teléfono' : 'Phone',
          labelStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
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
        initialCountryCode: 'ES',
        onChanged: (phone) {
          phoneNumber = phone.completeNumber;
        },
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 10),
            Text(isSpanish ? 'Error' : 'Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isSpanish ? 'Aceptar' : 'OK',
              style: TextStyle(color: colorPrimario, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
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
              ? 'Paciente modificado correctamente'
              : 'Patient updated successfully',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PacientesCuidadorScreen()),
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
  }

  Future<void> _continuaButton() async {
    var newpacienteOk = await DBPostgres().DBModPaciente(
      widget.paciente.CodPaciente,
      _nameController.text,
      _surname1Controller.text,
      _surname2Controller.text,
      _dateBirthController.text,
      _phoneNumberController.text,
      _emailController.text,
      _organitationController.text,
      CodVarSanitariaList,
      CodVarSocialList,
      _desOtrosSanitariaController.text,
      _desOtrosSocialController.text,
    );
    
    if (newpacienteOk == true) {
      _showSuccessDialog();
    } else if (newpacienteOk.toString().contains('Ya existe') || 
               newpacienteOk.toString().contains('duplicate')) {
      _showErrorDialog(
        context,
        isSpanish 
            ? 'El correo electrónico ya está registrado'
            : 'Email already registered',
      );
    } else {
      _showErrorDialog(
        context,
        isSpanish 
            ? 'Error al actualizar el paciente'
            : 'Error updating patient',
      );
    }
  }

  Future<void> _selectDateBirth(BuildContext context) async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(DateTime.now().year - 100),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: colorPrimario,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
          dialogBackgroundColor: Colors.white,
        ),
        child: child ?? const Text(''),
      ),
    );

    if (newDate != null) {
      setState(() {
        _dateBirthController.text = DateFormat('dd/MM/yyyy').format(newDate);
      });
    }
  }

  void _showOtrosSanitarioValuePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: colorPrimario),
              const SizedBox(width: 10),
              Text(isSpanish ? 'Patología' : 'Pathology'),
            ],
          ),
          content: TextField(
            decoration: InputDecoration(
              labelText: isSpanish ? 'Especifique la patología' : 'Specify pathology',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              _desOtrosSanitariaController.text = value;
            },
          ),
          actions: [
            TextButton(
              child: Text(
                isSpanish ? 'Aceptar' : 'OK',
                style: TextStyle(color: colorPrimario, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showOtrosSocialValuePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: colorPrimario),
              const SizedBox(width: 10),
              Text(isSpanish ? 'Variable Social' : 'Social Variable'),
            ],
          ),
          content: TextField(
            decoration: InputDecoration(
              labelText: isSpanish ? 'Especifique la variable social' : 'Specify social variable',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              _desOtrosSocialController.text = value;
            },
          ),
          actions: [
            TextButton(
              child: Text(
                isSpanish ? 'Aceptar' : 'OK',
                style: TextStyle(color: colorPrimario, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class VariablesSociales {
  final int CodVariableSocial;
  final String VariableSocial;

  VariablesSociales(this.CodVariableSocial, this.VariableSocial);
}

class VariablesSanitarias {
  final int CodVariableSanitaria;
  final String VariableSanitaria;

  VariablesSanitarias(this.CodVariableSanitaria, this.VariableSanitaria);
}