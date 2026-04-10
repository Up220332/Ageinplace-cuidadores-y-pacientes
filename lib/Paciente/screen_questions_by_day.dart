import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../base_de_datos/influx.dart';
import '../base_de_datos/postgres.dart';
import '../notifications/noti_service.dart';

class PreguntasDelDiaScreen extends StatefulWidget {
  final int pacienteId;

  const PreguntasDelDiaScreen({super.key, required this.pacienteId});

  @override
  State<PreguntasDelDiaScreen> createState() => _PreguntasDelDiaScreenState();
}

class _PreguntasDelDiaScreenState extends State<PreguntasDelDiaScreen> {
  List<Question> questionsList = [];
  bool loading = true;
  bool alreadyAnswered = false;
  Map<int, int> answers = {};

  Timer? _timer;

  final colorPrimario = const Color.fromARGB(255, 25, 144, 234);

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    // Solo inicializar notificaciones en plataformas móviles
    if (Platform.isAndroid || Platform.isIOS) {
      final notiService = NotiService();
      await notiService.initNotification();

      // Iniciar timer que revisa cada minuto si es 8:00 PM y hay preguntas pendientes
      _timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
        final now = DateTime.now();
        if (now.hour == 20 && now.minute == 00) {
          final disponible = await hayPreguntasDisponibles();
          if (disponible) {
            await notiService.scheduleNotification(
              id: 0,
              title: '¡Recuerda!',
              body: 'Ya puedes contestar tus preguntas de hoy',
              hour: 20,
              minute: 00,
            );
            timer.cancel();
          }
        }
      });
    }

    await getData();
  }

  Future<bool> hayPreguntasDisponibles() async {
    DateTime currentDate = DateTime.now();
    int weekDay = currentDate.weekday;

    final data = await DBPostgres().DBGetQuestionsByPatientAndDate(
      patientId: widget.pacienteId,
      weekDay: weekDay,
    );

    List<Question> preguntas = data.map((row) {
      return Question(row[0], row[1], row[2], row[3]);
    }).toList();

    for (var pregunta in preguntas) {
      final respondida = await InfluxDBService().checkIfAnswered(
        widget.pacienteId,
        pregunta.codQuestion,
      );
      if (!respondida) {
        return true;
      }
    }
    return false;
  }

  Future<void> getData() async {
    DateTime currentDate = DateTime.now();
    int weekDay = currentDate.weekday;

    final data = await DBPostgres().DBGetQuestionsByPatientAndDate(
      patientId: widget.pacienteId,
      weekDay: weekDay,
    );

    List<Question> preguntas = data.map((row) {
      return Question(row[0], row[1], row[2], row[3]);
    }).toList();

    bool todasRespondidas = true;
    for (var pregunta in preguntas) {
      final respondida = await InfluxDBService().checkIfAnswered(
        widget.pacienteId,
        pregunta.codQuestion,
      );
      if (!respondida) {
        todasRespondidas = false;
        break;
      }
    }

    if (todasRespondidas) {
      // Cancelar notificación solo en móviles
      if (Platform.isAndroid || Platform.isIOS) {
        final notiService = NotiService();
        await notiService.cancelDailyNotification();
      }
      setState(() {
        alreadyAnswered = true;
        loading = false;
      });
      return;
    }

    setState(() {
      questionsList = preguntas;
      loading = false;
    });
  }

  void saveQuestions() {
    if (answers.isEmpty) {
      final isSpanish = FlutterLocalization.instance.currentLocale?.languageCode == 'es';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isSpanish ? 'Selecciona al menos una respuesta' : 'Select at least one answer'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final influxService = InfluxDBService();

    Future.wait(
          answers.entries.map((entry) {
            return influxService.answerQuestion(
              widget.pacienteId,
              entry.key,
              entry.value,
            );
          }),
        )
        .then((_) async {
          if (Platform.isAndroid || Platform.isIOS) {
            final notiService = NotiService();
            await notiService.cancelDailyNotification();
          }
          
          final isSpanish = FlutterLocalization.instance.currentLocale?.languageCode == 'es';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isSpanish ? 'Respuestas enviadas exitosamente' : 'Answers submitted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            questionsList.clear();
            answers.clear();
            alreadyAnswered = true;
          });
        })
        .catchError((error) {
          final isSpanish = FlutterLocalization.instance.currentLocale?.languageCode == 'es';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isSpanish ? 'Error al enviar respuestas: $error' : 'Error submitting answers: $error'),
              backgroundColor: Colors.red,
            ),
          );
        });
  }

  bool isWithinAllowedTime() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, 20);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return now.isAfter(start) && now.isBefore(end);
  }

  @override
  Widget build(BuildContext context) {
    final bool isSpanish = FlutterLocalization.instance.currentLocale?.languageCode == 'es';
    final bool inHorarioPermitido = isWithinAllowedTime();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: loading
            ? Center(
                child: CircularProgressIndicator(color: colorPrimario),
              )
            : alreadyAnswered
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_circle, size: 50, color: Colors.green),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isSpanish
                          ? 'Ya has contestado tus preguntas de hoy.'
                          : 'You have already answered today\'s questions.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )
            : !inHorarioPermitido
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.access_time, size: 50, color: Colors.orange),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isSpanish
                          ? 'Aún no puede contestar sus preguntas. A partir de las 20:00 horas puede hacerlo.'
                          : 'You cannot answer your questions yet. You can do so from 8:00 PM.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )
            : questionsList.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.help_outline, size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      isSpanish
                          ? 'Aún no tienes preguntas para hoy.'
                          : 'You don\'t have any questions for today.',
                      style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
            : buildQuestionsContent(isSpanish),
      ),
    );
  }

  Widget buildQuestionsContent(bool isSpanish) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: questionsList.length,
            itemBuilder: (context, index) {
              final question = questionsList[index];
              final answer = answers[question.codQuestion];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colorPrimario.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colorPrimario,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              question.desQuestion,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _buildAnswerOption(
                            value: 1,
                            currentAnswer: answer,
                            label: isSpanish ? 'Sí' : 'Yes',
                            color: Colors.green,
                            onTap: () {
                              setState(() {
                                answers[question.codQuestion] = 1;
                              });
                            },
                          ),
                          const SizedBox(width: 20),
                          _buildAnswerOption(
                            value: 0,
                            currentAnswer: answer,
                            label: isSpanish ? 'No' : 'No',
                            color: Colors.red,
                            onTap: () {
                              setState(() {
                                answers[question.codQuestion] = 0;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: saveQuestions,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorPrimario,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              child: Text(
                isSpanish ? 'Guardar respuestas' : 'Save answers',
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
    );
  }

  Widget _buildAnswerOption({
    required int value,
    required int? currentAnswer,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isSelected = currentAnswer == value;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? color : Colors.white,
                  border: Border.all(
                    color: isSelected ? color : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? color : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
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