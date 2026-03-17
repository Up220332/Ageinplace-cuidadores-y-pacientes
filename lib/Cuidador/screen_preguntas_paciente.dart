import 'package:ageinplace/Cuidador/screen_question_stadistics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:intl/intl.dart';

import '../BarraLateral/NavBar_caregiver.dart';
import '../base_de_datos/influx.dart';
import '../base_de_datos/postgres.dart';

class PreguntasPacienteScreen extends StatefulWidget {
  final int pacienteId;

  const PreguntasPacienteScreen({super.key, required this.pacienteId});

  @override
  _PreguntasPacienteScreenState createState() =>
      _PreguntasPacienteScreenState();
}

class _PreguntasPacienteScreenState extends State<PreguntasPacienteScreen> {
  DateTime? selectedDate;
  List<Question>? questionsList;
  bool loading = false;
  List<Question>? questionsByDateList;
  Map<int, bool> answeredQuestionsMap = {};
  Map<int, String> questionAnswersMap = {};

  bool showAllQuestions = false;

  Map<int, Map<String, dynamic>> uniqueQuestionsMap = {};

  final colorPrimario = const Color.fromARGB(255, 25, 144, 234);

  final List<Map<String, dynamic>> weekDays = [
    {'id': 1, 'name_es': 'Lunes', 'name_en': 'Monday'},
    {'id': 2, 'name_es': 'Martes', 'name_en': 'Tuesday'},
    {'id': 3, 'name_es': 'Miércoles', 'name_en': 'Wednesday'},
    {'id': 4, 'name_es': 'Jueves', 'name_en': 'Thursday'},
    {'id': 5, 'name_es': 'Viernes', 'name_en': 'Friday'},
    {'id': 6, 'name_es': 'Sábado', 'name_en': 'Saturday'},
    {'id': 7, 'name_es': 'Domingo', 'name_en': 'Sunday'},
  ];

  Future<String> getData() async {
    final data = await DBPostgres().DBGetQuestions();

    if (data is List) {
      setState(() {
        questionsList = data.map((row) {
          return Question(row[0], row[1], row[2], row[3]);
        }).toList();
      });
    } else {
      print('Error al obtener las preguntas: $data');
    }
    return 'Successfully Fetched data';
  }

  Future<String> getQuestionsByDate(DateTime date) async {
    final int weekDay = date.weekday;
    print('=== getQuestionsByDate para fecha: $date, día: $weekDay ===');

    final dataQuestionsByDate = await DBPostgres().DBGetQuestionsByAssignment(
      patientId: widget.pacienteId,
      weekDay: weekDay,
    );

    print('Datos recibidos: $dataQuestionsByDate');
    print('Cantidad de preguntas: ${dataQuestionsByDate.length}');

    final List<Question> tempList = [];

    for (final row in dataQuestionsByDate) {
      print('Row: $row');
      final question = Question(row[0], row[1], row[2], row[3]);

      final wasAnswered = await InfluxDBService().checkIfAnswered(
        widget.pacienteId,
        question.codQuestion,
      );

      answeredQuestionsMap[question.codQuestion] = wasAnswered;

      tempList.add(question);

      if (question.dateLeavingQuestion == null) {
        if (!uniqueQuestionsMap.containsKey(question.codQuestion)) {
          uniqueQuestionsMap[question.codQuestion] = {
            'codQuestion': question.codQuestion,
            'desQuestion': question.desQuestion,
            'dischargeDateQuestion': question.dischargeDateQuestion,
            'dateLeavingQuestion': question.dateLeavingQuestion,
            'days': <int>{weekDay},
          };
        } else {
          (uniqueQuestionsMap[question.codQuestion]!['days'] as Set<int>).add(
            weekDay,
          );
        }
      }
    }

    setState(() {
      questionsByDateList = tempList;
    });

    return 'Successfully Fetched dataQuestionsByDate';
  }

  Future<void> _selectedDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
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
        child: child!,
      ),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
        questionsByDateList = null;
        loading = true;
        showAllQuestions = false;
      });

      await getQuestionsByDate(date);
      await loadAnswers();

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> loadAnswers() async {
    questionAnswersMap = await InfluxDBService().getPatientAnswers(
      widget.pacienteId,
      selectedDate!,
    );
    setState(() {});
  }

  Future<void> loadAllQuestions() async {
    setState(() {
      showAllQuestions = true;
      loading = true;
      uniqueQuestionsMap.clear();
    });

    try {
      final now = DateTime.now();
      for (int i = 0; i < 30; i++) {
        final date = now.subtract(Duration(days: i));
        await getQuestionsByDate(date);
      }

      for (int i = 1; i <= 7; i++) {
        final date = now.add(Duration(days: i));
        await getQuestionsByDate(date);
      }

      final inactiveResult = await DBPostgres().DBGetInactiveQuestions();

      if (inactiveResult is List) {
        for (var row in inactiveResult) {
          final codQuestion = row[0];
          final desQuestion = row[1];
          final dischargeDate = row[2];
          final dateLeaving = row[3];

          if (!uniqueQuestionsMap.containsKey(codQuestion)) {
            uniqueQuestionsMap[codQuestion] = {
              'codQuestion': codQuestion,
              'desQuestion': desQuestion,
              'dischargeDateQuestion': dischargeDate,
              'dateLeavingQuestion': dateLeaving,
              'days': <int>{}, 
            };
          } else {
            uniqueQuestionsMap[codQuestion]!['dateLeavingQuestion'] =
                dateLeaving;
          }
        }
      }
    } catch (e) {
      print('Error cargando todas las preguntas: $e');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _activarPregunta(
    BuildContext context,
    bool isSpanish,
    Map<String, dynamic> question,
  ) async {
    try {
      await DBPostgres().DBActivateQuestion(question['codQuestion']);

      // Recargar datos
      await loadAllQuestions();
      await getQuestionsByDate(selectedDate!);

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            isSpanish
                ? 'Pregunta activada correctamente'
                : 'Question successfully activated',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            isSpanish
                ? 'Error al activar la pregunta'
                : 'Error activating question',
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    getData();
    getQuestionsByDate(selectedDate!).then((_) {
      loadAnswers();
    });
  }

  String _getDayName(int day, bool isSpanish) {
    if (isSpanish) {
      const dias = [
        'Lunes',
        'Martes',
        'Miércoles',
        'Jueves',
        'Viernes',
        'Sábado',
        'Domingo',
      ];
      return dias[day - 1];
    } else {
      const days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      return days[day - 1];
    }
  }

  String _getDayNameShort(int day, bool isSpanish) {
    if (isSpanish) {
      const dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      return dias[day - 1];
    } else {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[day - 1];
    }
  }

  String _getDaysList(Set<int> days, bool isSpanish) {
    if (days.isEmpty)
      return isSpanish ? 'Sin días asignados' : 'No days assigned';

    List<String> dayNames = days
        .map((d) => _getDayNameShort(d, isSpanish))
        .toList();
    dayNames.sort();

    if (dayNames.length > 3) {
      return '${dayNames.sublist(0, 3).join(', ')}...';
    }
    return dayNames.join(', ');
  }

  @override
Widget build(BuildContext context) {
  final isSpanish =
      FlutterLocalization.instance.currentLocale?.languageCode == 'es';
  final formatoFecha = DateFormat('dd/MM/yyyy');

  return WillPopScope(
    onWillPop: () async {
      Navigator.pop(context);
      return false;
    },
    child: Scaffold(
      endDrawer: const NavBarCaregiver(),
      
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
          isSpanish ? 'Preguntas' : 'Questions',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          // Botón de estadísticas
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.query_stats_rounded, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScreenQuestionStatisticsScreen(
                      patientId: widget.pacienteId,
                    ),
                  ),
                );
              },
            ),
          ),
          // Botón de menú 
          Builder(
            builder: (context) => Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            ),
          ),
        ],
      ),
      
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton.extended(
          heroTag: "btn",
          backgroundColor: colorPrimario,
          label: Text(
            isSpanish ? 'Agregar pregunta' : 'Add question',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          icon: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            _addQuestion(context, isSpanish);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showAllQuestions = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !showAllQuestions
                                ? colorPrimario
                                : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              isSpanish ? 'Por fecha' : 'By date',
                              style: TextStyle(
                                color: !showAllQuestions
                                    ? Colors.white
                                    : Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (!showAllQuestions) {
                            loadAllQuestions();
                          } else {
                            setState(() {
                              showAllQuestions = true;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: showAllQuestions
                                ? colorPrimario
                                : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              isSpanish ? 'Todas' : 'All',
                              style: TextStyle(
                                color: showAllQuestions
                                    ? Colors.white
                                    : Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              if (!showAllQuestions) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: colorPrimario,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isSpanish ? 'Seleccionar fecha' : 'Select date',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _selectedDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_month,
                                color: colorPrimario,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                formatoFecha.format(selectedDate!),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorPrimario.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    '${isSpanish ? 'Preguntas del' : 'Questions for'}: ${formatoFecha.format(selectedDate!)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorPrimario,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (showAllQuestions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorPrimario.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      isSpanish ? 'Todas las preguntas' : 'All questions',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colorPrimario,
                      ),
                    ),
                  ),
                ),

              if (loading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 25, 144, 234),
                    ),
                  ),
                )
              else if (showAllQuestions)
                _buildAllQuestionsView(isSpanish)
              else if (questionsByDateList == null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isSpanish
                              ? 'No hay preguntas para esta fecha'
                              : 'No questions for this date',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: questionsByDateList!.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 60,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isSpanish
                                    ? 'No hay preguntas para esta fecha'
                                    : 'No questions for this date',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: questionsByDateList!.length,
                          itemBuilder: (context, index) {
                            final question = questionsByDateList![index];
                            final answer =
                                questionAnswersMap[question.codQuestion];

                            Color answerColor;
                            String answerText;

                            if (answer == '1') {
                              answerColor = Colors.green;
                              answerText = isSpanish ? 'Sí' : 'Yes';
                            } else if (answer == '0') {
                              answerColor = Colors.red;
                              answerText = isSpanish ? 'No' : 'No';
                            } else {
                              answerColor = Colors.grey.shade600;
                              answerText = isSpanish
                                  ? 'Sin respuesta'
                                  : 'No answer';
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    final opcion = await showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          title: Row(
                                            children: [
                                              Icon(
                                                Icons.warning_amber_rounded,
                                                color: Colors.orange,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                isSpanish
                                                    ? '¿Qué deseas hacer?'
                                                    : 'What do you want to do?',
                                              ),
                                            ],
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                leading: Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    Icons.today,
                                                    color: Colors.orange,
                                                  ),
                                                ),
                                                title: Text(
                                                  isSpanish
                                                      ? 'Desactivar solo para hoy'
                                                      : 'Deactivate only for today',
                                                ),
                                                subtitle: Text(
                                                  isSpanish
                                                      ? 'La pregunta no aparecerá el día ${_getDayName(selectedDate!.weekday, isSpanish)}'
                                                      : 'The question will not appear on ${_getDayName(selectedDate!.weekday, isSpanish)}',
                                                ),
                                                onTap: () {
                                                  Navigator.pop(context, 'day');
                                                },
                                              ),
                                              const Divider(),
                                              ListTile(
                                                leading: Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    Icons.block,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                title: Text(
                                                  isSpanish
                                                      ? 'Desactivar permanentemente'
                                                      : 'Deactivate permanently',
                                                ),
                                                subtitle: Text(
                                                  isSpanish
                                                      ? 'La pregunta se desactivará para todos los días'
                                                      : 'The question will be deactivated for all days',
                                                ),
                                                onTap: () {
                                                  Navigator.pop(
                                                    context,
                                                    'permanent',
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                context,
                                                'cancel',
                                              ),
                                              child: Text(
                                                isSpanish
                                                    ? 'Cancelar'
                                                    : 'Cancel',
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (opcion == 'day') {
                                      // Desactivar solo para hoy
                                      await DBPostgres()
                                          .dbDeactivateQuestionForDay(
                                            codUsuario: widget.pacienteId,
                                            codPregunta: question.codQuestion,
                                            diaSemana: selectedDate!.weekday,
                                          );

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isSpanish
                                                ? 'Pregunta desactivada para el día ${_getDayName(selectedDate!.weekday, isSpanish)}'
                                                : 'Question deactivated for ${_getDayName(selectedDate!.weekday, isSpanish)}',
                                          ),
                                          backgroundColor: Colors.orange,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    } else if (opcion == 'permanent') {
                                      // Desactivar permanentemente
                                      await DBPostgres().DBDeactivateQuestion(
                                        question.codQuestion,
                                      );

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isSpanish
                                                ? 'Pregunta desactivada permanentemente'
                                                : 'Question permanently deactivated',
                                          ),
                                          backgroundColor: Colors.red,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }

                                    // Recargar datos
                                    await getQuestionsByDate(selectedDate!);
                                    await loadAllQuestions();
                                    setState(() {});
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: answerColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            answer == '1'
                                                ? Icons.check_circle
                                                : answer == '0'
                                                ? Icons.cancel
                                                : Icons.help_outline,
                                            color: answerColor,
                                            size: 30,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                question.desQuestion,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${isSpanish ? 'Respuesta' : 'Answer'}: $answerText',
                                                style: TextStyle(
                                                  color: answerColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildAllQuestionsView(bool isSpanish) {
    if (uniqueQuestionsMap.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: colorPrimario.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.help_outline, size: 50, color: colorPrimario),
              ),
              const SizedBox(height: 16),
              Text(
                isSpanish
                    ? 'No hay preguntas configuradas'
                    : 'No questions configured',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isSpanish
                    ? 'Prueba a seleccionar diferentes fechas'
                    : 'Try selecting different dates',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final questionsList = uniqueQuestionsMap.values.toList()
      ..sort((a, b) {
        // Primero las activas, luego las inactivas
        bool aActive = a['dateLeavingQuestion'] == null;
        bool bActive = b['dateLeavingQuestion'] == null;
        if (aActive && !bActive) return -1;
        if (!aActive && bActive) return 1;
        return (a['desQuestion'] as String).compareTo(
          b['desQuestion'] as String,
        );
      });

    return Expanded(
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: questionsList.length,
        itemBuilder: (context, index) {
          final question = questionsList[index];
          final days = question['days'] as Set<int>;

          // Determinar si la pregunta está activa o inactiva
          final isActive = question['dateLeavingQuestion'] == null;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            question['desQuestion'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? Colors.black
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isActive ? Colors.green : Colors.red,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            isActive
                                ? (isSpanish ? 'Activa' : 'Active')
                                : (isSpanish ? 'Inactiva' : 'Inactive'),
                            style: TextStyle(
                              color: isActive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isActive
                                ? colorPrimario.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              if (isActive) {
                                // Si está activa, la editamos
                                _editQuestion(
                                  context,
                                  isSpanish,
                                  question,
                                  days,
                                );
                              } else {
                                // Si está inactiva, la activamos
                                _activarPregunta(context, isSpanish, question);
                              }
                            },
                            child: Icon(
                              isActive ? Icons.edit : Icons.refresh,
                              size: 16,
                              color: isActive ? colorPrimario : Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: isActive
                              ? colorPrimario
                              : Colors.grey.shade400,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${isSpanish ? 'Días' : 'Days'}:',
                          style: TextStyle(
                            fontSize: 13,
                            color: isActive
                                ? Colors.grey.shade700
                                : Colors.grey.shade400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: days.isEmpty
                              ? Text(
                                  isSpanish
                                      ? 'Sin días asignados'
                                      : 'No days assigned',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isActive
                                        ? Colors.grey.shade500
                                        : Colors.grey.shade400,
                                    fontStyle: FontStyle.italic,
                                  ),
                                )
                              : Text(
                                  _getDaysList(days, isSpanish),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isActive
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade400,
                                  ),
                                ),
                        ),
                      ],
                    ),
                    if (days.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: days.map((day) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? colorPrimario.withOpacity(0.1)
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getDayNameShort(day, isSpanish),
                              style: TextStyle(
                                fontSize: 11,
                                color: isActive
                                    ? colorPrimario
                                    : Colors.grey.shade500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    // Si está inactiva, mostrar la fecha de desactivación
                    if (!isActive &&
                        question['dateLeavingQuestion'] != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 14,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${isSpanish ? 'Desactivada el' : 'Deactivated on'}: ${DateFormat('dd/MM/yyyy').format(question['dateLeavingQuestion'])}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _editQuestion(
    BuildContext context,
    bool isSpanish,
    Map<String, dynamic> question,
    Set<int> currentDays,
  ) async {
    await getData();

    List<int> selectedDays = currentDays.toList();
    String editedDescription = question['desQuestion'];

    TextEditingController descriptionController = TextEditingController(
      text: editedDescription,
    );

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título (fijo)
                    Row(
                      children: [
                        Icon(Icons.edit, color: colorPrimario, size: 28),
                        const SizedBox(width: 10),
                        Text(
                          isSpanish ? 'Editar pregunta' : 'Edit question',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Contenido desplazable
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Campo de texto
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: TextFormField(
                                controller: descriptionController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  labelText: isSpanish
                                      ? 'Descripción de la pregunta'
                                      : 'Question description',
                                  labelStyle: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                onChanged: (value) {
                                  editedDescription = value;
                                },
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Selector de días
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8,
                                        top: 8,
                                        bottom: 8,
                                      ),
                                      child: Text(
                                        isSpanish
                                            ? 'Selecciona los días de la semana:'
                                            : 'Select week days:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                    ...weekDays.map((day) {
                                      bool isSelected = selectedDays.contains(
                                        day['id'],
                                      );
                                      return CheckboxListTile(
                                        title: Text(
                                          isSpanish
                                              ? day['name_es']
                                              : day['name_en'],
                                        ),
                                        value: isSelected,
                                        activeColor: colorPrimario,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            if (value == true) {
                                              selectedDays.add(day['id']);
                                            } else {
                                              selectedDays.remove(day['id']);
                                            }
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Botones (fijos al final)
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                isSpanish ? 'Cancelar' : 'Cancel',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (editedDescription.isNotEmpty &&
                                    selectedDays.isNotEmpty) {
                                  await DBPostgres()
                                      .DBUpdateQuestionDescription(
                                        question['codQuestion'],
                                        editedDescription,
                                      );

                                  for (int dia in currentDays) {
                                    await DBPostgres()
                                        .dbDeactivateQuestionForDay(
                                          codUsuario: widget.pacienteId,
                                          codPregunta: question['codQuestion'],
                                          diaSemana: dia,
                                        );
                                  }

                                  await DBPostgres().dbAssignQuestionPatient(
                                    codUsuario: widget.pacienteId,
                                    codPregunta: question['codQuestion'],
                                    diasSeleccionados: selectedDays,
                                  );

                                  await loadAllQuestions();
                                  await getQuestionsByDate(selectedDate!);

                                  setState(() {});
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.green,
                                      content: Text(
                                        isSpanish
                                            ? 'Pregunta actualizada correctamente'
                                            : 'Question successfully updated',
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(
                                        isSpanish
                                            ? 'Por favor completa todos los campos.'
                                            : 'Please fill all fields.',
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorPrimario,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                isSpanish ? 'Guardar' : 'Save',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addQuestion(BuildContext context, bool isSpanish) async {
    await getData();

    // Variables para el modo "Crear nueva"
    bool isCreatingNew = false;
    String newQuestionText = '';
    List<int> selectedDays = [];
    Question? selectQuestion;

    // Controlador para el campo de texto de nueva pregunta
    TextEditingController newQuestionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título (fijo)
                      Row(
                        children: [
                          Icon(Icons.add_task, color: colorPrimario, size: 28),
                          const SizedBox(width: 10),
                          Text(
                            isSpanish ? 'Asignar pregunta' : 'Assign question',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Switch (fijo)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isCreatingNew = false;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: !isCreatingNew
                                        ? colorPrimario
                                        : Colors.transparent,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      bottomLeft: Radius.circular(16),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      isSpanish ? 'Existente' : 'Existing',
                                      style: TextStyle(
                                        color: !isCreatingNew
                                            ? Colors.white
                                            : Colors.grey.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isCreatingNew = true;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isCreatingNew
                                        ? colorPrimario
                                        : Colors.transparent,
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(16),
                                      bottomRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      isSpanish ? 'Nueva' : 'New',
                                      style: TextStyle(
                                        color: isCreatingNew
                                            ? Colors.white
                                            : Colors.grey.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Contenido desplazable
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!isCreatingNew) ...[
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: DropdownButtonFormField<Question>(
                                    value: selectQuestion,
                                    items: questionsList?.map((question) {
                                      return DropdownMenuItem(
                                        value: question,
                                        child: SizedBox(
                                          width: 200,
                                          child: Text(
                                            question.desQuestion,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (valor) {
                                      selectQuestion = valor;
                                    },
                                    decoration: InputDecoration(
                                      labelText: isSpanish
                                          ? 'Selecciona una pregunta'
                                          : 'Select a question',
                                      labelStyle: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                    ),
                                  ),
                                ),
                              ] else ...[
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: TextFormField(
                                    controller: newQuestionController,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      labelText: isSpanish
                                          ? 'Escribe la nueva pregunta'
                                          : 'Write the new question',
                                      labelStyle: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                    ),
                                    onChanged: (value) {
                                      newQuestionText = value;
                                    },
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),

                              // Selector de días
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8,
                                          top: 8,
                                          bottom: 8,
                                        ),
                                        child: Text(
                                          isSpanish
                                              ? 'Selecciona los días de la semana:'
                                              : 'Select week days:',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                      ...weekDays.map((day) {
                                        bool isSelected = selectedDays.contains(
                                          day['id'],
                                        );
                                        return CheckboxListTile(
                                          title: Text(
                                            isSpanish
                                                ? day['name_es']
                                                : day['name_en'],
                                          ),
                                          value: isSelected,
                                          activeColor: colorPrimario,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              if (value == true) {
                                                selectedDays.add(day['id']);
                                              } else {
                                                selectedDays.remove(day['id']);
                                              }
                                            });
                                          },
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),

                      // Botones fijos
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  isSpanish ? 'Cancelar' : 'Cancel',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () async {
                                  // Aquí va tu código de guardado
                                  // (el mismo que tenías antes)
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorPrimario,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  isSpanish ? 'Guardar' : 'Save',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class Question {
  final int codQuestion;
  final String desQuestion;
  final DateTime dischargeDateQuestion;
  final DateTime? dateLeavingQuestion;

  Question(
    this.codQuestion,
    this.desQuestion,
    this.dischargeDateQuestion,
    this.dateLeavingQuestion,
  );
}
