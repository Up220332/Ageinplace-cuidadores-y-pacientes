import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:intl/intl.dart';

import '../base_de_datos/influx.dart';
import '../base_de_datos/postgres.dart';

class ScreenQuestionStatisticsScreen extends StatefulWidget {
  final int patientId;

  const ScreenQuestionStatisticsScreen({super.key, required this.patientId});

  @override
  _ScreenQuestionStatisticsScreen createState() =>
      _ScreenQuestionStatisticsScreen();
}

class _ScreenQuestionStatisticsScreen
    extends State<ScreenQuestionStatisticsScreen> {
  List<Question>? allPatientQuestions; 
  Map<int, List<Question>> questionsByDay = {}; 
  Map<String, Map<int, int>> answersByDay = {}; 
  DateTime? selectedDate;
  DateTime? weekStart;
  DateTime? weekEnd;
  bool loading = false;
  
  final colorPrimario = const Color.fromARGB(255, 25, 144, 234);

  // Cargar todas las preguntas activas del paciente y agruparlas por día
  Future<void> loadPatientActiveQuestions() async {
    setState(() {
      loading = true;
    });

    try {
      final Map<int, Question> uniqueQuestions = {};
      final Map<int, List<Question>> tempQuestionsByDay = {
        1: [], 
        2: [], 
        3: [], 
        4: [],
        5: [], 
        6: [], 
        7: [], 
      };

      final now = DateTime.now();
      for (int i = 1; i <= 7; i++) {
        final testDate = DateTime(now.year, now.month, i);
        final weekDay = testDate.weekday;
        
        final data = await DBPostgres().DBGetQuestionsByAssignment(
          patientId: widget.patientId,
          weekDay: weekDay,
        );

        for (final row in data) {
          final question = Question(
            row[0],
            row[1],
            row[2],
            row[3],
          );
          
          if (question.dateLeavingQuestion == null) {
            if (!uniqueQuestions.containsKey(question.codQuestion)) {
              uniqueQuestions[question.codQuestion] = question;
            }

            tempQuestionsByDay[weekDay]!.add(question);
          }
        }
      }

      tempQuestionsByDay.forEach((day, questions) {
        final Map<int, Question> uniqueInDay = {};
        for (var q in questions) {
          uniqueInDay[q.codQuestion] = q;
        }
        tempQuestionsByDay[day] = uniqueInDay.values.toList()
          ..sort((a, b) => a.desQuestion.compareTo(b.desQuestion));
      });

      setState(() {
        allPatientQuestions = uniqueQuestions.values.toList()
          ..sort((a, b) => a.desQuestion.compareTo(b.desQuestion));
        questionsByDay = tempQuestionsByDay;
      });

      print('Preguntas activas del paciente: ${allPatientQuestions?.length}');
      print('Preguntas por día: ${questionsByDay.length}');
      
    } catch (e) {
      print('Error cargando preguntas activas: $e');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _loadAnswers(DateTime startDate, DateTime endDate) async {
    setState(() {
      loading = true;
    });

    try {
      answersByDay.clear();

      if (allPatientQuestions == null || allPatientQuestions!.isEmpty) {
        setState(() {
          loading = false;
        });
        return;
      }

      for (int i = 0; i < 7; i++) {
        final currentDay = startDate.add(Duration(days: i));
        final dayKey = DateFormat('yyyy-MM-dd').format(currentDay);
        final weekDay = currentDay.weekday; 
        final dayQuestions = questionsByDay[weekDay] ?? [];
        final dayAnswers = await InfluxDBService().getPatientAnswers(
          widget.patientId,
          currentDay,
        );

        final Map<int, int> answersForDay = {};
        
        for (final question in dayQuestions) {
          answersForDay[question.codQuestion] = -1;
        }

        dayAnswers.forEach((questionId, answer) {
          if (answersForDay.containsKey(questionId)) { 
            if (answer == '1') {
              answersForDay[questionId] = 1;
            } else if (answer == '0') {
              answersForDay[questionId] = 0;
            }
          }
        });

        answersByDay[dayKey] = answersForDay;
      }

      print('Respuestas cargadas para ${answersByDay.length} días');
      
    } catch (e) {
      print('Error cargando respuestas: $e');
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
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

    if (date != null && mounted) {
      final monday = date.subtract(Duration(days: date.weekday - 1));
      final sunday = monday.add(const Duration(days: 6));

      setState(() {
        selectedDate = date;
        weekStart = monday;
        weekEnd = sunday;
      });

      await _loadAnswers(monday, sunday);
    }
  }

  List<ScatterSpot> _buildScatterSpots() {
    if (allPatientQuestions == null || 
        allPatientQuestions!.isEmpty || 
        answersByDay.isEmpty) {
      return [];
    }

    List<ScatterSpot> spots = [];
    
    // Mapa para llevar el índice Y de cada pregunta en cada día
    Map<int, Map<int, int>> questionIndexByDay = {};

    // Inicializar el mapa de índices
    for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
      final currentDay = weekStart!.add(Duration(days: dayIndex));
      final weekDay = currentDay.weekday;
      final dayQuestions = questionsByDay[weekDay] ?? [];
      
      questionIndexByDay[dayIndex] = {};
      for (int qIndex = 0; qIndex < dayQuestions.length; qIndex++) {
        final question = dayQuestions[qIndex];
        questionIndexByDay[dayIndex]![question.codQuestion] = qIndex;
      }
    }

    for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
      final currentDay = weekStart!.add(Duration(days: dayIndex));
      final dayKey = DateFormat('yyyy-MM-dd').format(currentDay);
      final weekDay = currentDay.weekday;
      final dayQuestions = questionsByDay[weekDay] ?? [];
      final dayAnswers = answersByDay[dayKey] ?? {};

      for (int qIndex = 0; qIndex < dayQuestions.length; qIndex++) {
        final question = dayQuestions[qIndex];
        final answer = dayAnswers[question.codQuestion] ?? -1;

        Color color;
        if (answer == 1) {
          color = Colors.green;
        } else if (answer == 0) {
          color = Colors.red;
        } else {
          color = Colors.grey;
        }

        spots.add(
          ScatterSpot(
            dayIndex.toDouble(),
            qIndex.toDouble(),
            dotPainter: FlDotCirclePainter(
              color: color,
              radius: answer == -1 ? 6 : 8,
              strokeWidth: answer == -1 ? 1 : 0,
              strokeColor: Colors.grey.shade400,
            ),
          ),
        );
      }
    }

    return spots;
  }

  int _getMaxQuestionsForDay(int dayIndex) {
    final currentDay = weekStart!.add(Duration(days: dayIndex));
    final weekDay = currentDay.weekday;
    return questionsByDay[weekDay]?.length ?? 0;
  }

  Question? _getQuestionForDayAndIndex(int dayIndex, int qIndex) {
    final currentDay = weekStart!.add(Duration(days: dayIndex));
    final weekDay = currentDay.weekday;
    final dayQuestions = questionsByDay[weekDay] ?? [];
    if (qIndex >= 0 && qIndex < dayQuestions.length) {
      return dayQuestions[qIndex];
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    
    loadPatientActiveQuestions().then((_) {
      final now = DateTime.now();
      selectedDate = now;
      weekStart = now.subtract(Duration(days: now.weekday - 1));
      weekEnd = weekStart!.add(const Duration(days: 6));
      
      if (allPatientQuestions != null && allPatientQuestions!.isNotEmpty) {
        _loadAnswers(weekStart!, weekEnd!);
      }
    });
  }

  String _getDayNameShort(int dayIndex, bool isSpanish) {
    if (isSpanish) {
      const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      return days[dayIndex];
    } else {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dayIndex];
    }
  }

  String _getDayName(int dayIndex, bool isSpanish) {
    if (isSpanish) {
      const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
      return days[dayIndex];
    } else {
      const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return days[dayIndex];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSpanish = FlutterLocalization.instance.currentLocale?.languageCode == 'es';
    final formatoFecha = DateFormat('dd/MM/yyyy');
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: colorPrimario,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.5),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isSpanish ? 'Estadísticas de Preguntas' : 'Question Statistics',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
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
                        Icon(Icons.assessment, color: colorPrimario, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          isSpanish 
                            ? 'Estadísticas por semana'
                            : 'Weekly statistics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  
                    GestureDetector(
                      onTap: _selectedDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_month, color: colorPrimario, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                weekStart != null && weekEnd != null
                                    ? '${formatoFecha.format(weekStart!)} - ${formatoFecha.format(weekEnd!)}'
                                    : isSpanish ? 'Seleccionar semana' : 'Select week',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (allPatientQuestions == null || allPatientQuestions!.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: colorPrimario.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.info_outline, size: 40, color: colorPrimario),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isSpanish 
                          ? 'Este paciente no tiene preguntas activas'
                          : 'This patient has no active questions',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isSpanish
                          ? 'Asigne preguntas desde la pantalla anterior'
                          : 'Assign questions from the previous screen',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                // Gráfico
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
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
                          Icon(Icons.scatter_plot, color: colorPrimario, size: 24),
                          const SizedBox(width: 10),
                          Text(
                            isSpanish 
                              ? 'Distribución de respuestas por día'
                              : 'Response distribution by day',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 400,
                        child: Stack(
                          children: [
                            ScatterChart(
                              ScatterChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: true,
                                  drawHorizontalLine: true,
                                  horizontalInterval: 1,
                                  verticalInterval: 1,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: Colors.grey.shade300,
                                      strokeWidth: 1,
                                    );
                                  },
                                  getDrawingVerticalLine: (value) {
                                    return FlLine(
                                      color: Colors.grey.shade300,
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(color: Colors.grey.shade400),
                                ),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 1,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        int index = value.toInt();
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: Text(
                                            'P${index + 1}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade700,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 1,
                                      reservedSize: 30,
                                      getTitlesWidget: (value, meta) {
                                        int dayIndex = value.toInt();
                                        if (dayIndex >= 0 && dayIndex < 7) {
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text(
                                              _getDayNameShort(dayIndex, isSpanish),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          );
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                scatterSpots: _buildScatterSpots(),
                                minX: -0.5,
                                maxX: 6.5,
                                minY: -0.5,
                                maxY: _getMaxY(),
                              ),
                            ),
                            if (loading)
                              Container(
                                color: Colors.white.withOpacity(0.7),
                                child: const Center(
                                  child: CircularProgressIndicator(color: Color.fromARGB(255, 25, 144, 234)),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Leyenda de colores
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegendItem(Colors.green, isSpanish ? 'Sí' : 'Yes'),
                          const SizedBox(width: 20),
                          _buildLegendItem(Colors.red, isSpanish ? 'No' : 'No'),
                          const SizedBox(width: 20),
                          _buildLegendItem(Colors.grey, isSpanish ? 'Sin respuesta' : 'No answer', true),
                        ],
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Información de preguntas por día
              if (allPatientQuestions != null && allPatientQuestions!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
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
                          Icon(Icons.info_outline, color: colorPrimario, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            isSpanish ? 'Preguntas por día' : 'Questions by day',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Lista de días con sus preguntas
                      ...List.generate(7, (dayIndex) {
                        final currentDay = weekStart!.add(Duration(days: dayIndex));
                        final weekDay = currentDay.weekday;
                        final dayQuestions = questionsByDay[weekDay] ?? [];
                        
                        if (dayQuestions.isEmpty) return const SizedBox.shrink();
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: colorPrimario.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _getDayName(dayIndex, isSpanish),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: colorPrimario,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${dayQuestions.length} ${isSpanish ? 'preguntas' : 'questions'}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ...dayQuestions.asMap().entries.map((qEntry) {
                                final qIndex = qEntry.key;
                                final question = qEntry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: colorPrimario.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${qIndex + 1}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: colorPrimario,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          question.desQuestion,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Calcular el máximo valor Y para el gráfico
  double _getMaxY() {
    double max = 0;
    for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
      final currentDay = weekStart!.add(Duration(days: dayIndex));
      final weekDay = currentDay.weekday;
      final count = questionsByDay[weekDay]?.length ?? 0;
      if (count > max) max = count.toDouble();
    }
    return max - 0.5;
  }

  Widget _buildLegendItem(Color color, String label, [bool isGrey = false]) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: isGrey
                ? Border.all(color: Colors.grey.shade400, width: 1.5)
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
          ),
        ),
      ],
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