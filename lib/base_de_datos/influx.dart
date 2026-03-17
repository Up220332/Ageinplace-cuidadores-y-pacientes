import 'package:influxdb_client/api.dart';

import '../Cuidador/screen_Paciente.dart';

class InfluxDBService {
  late InfluxDBClient client;

  //var url = 'http://192.168.72.11:8086'; // PC POM
  //var url = 'http://212.128.71.211:8086'; // PC POM
  var url = 'http://192.168.75.94:8086'; // QNAP NAS

  // var token =
  //     '6zGGpPkuyQSZNhAFqIgSmWi7uDGP2I6T_NekZ8ATaaZsJCx1MY7fkEnzTKydWdYzh-Mo039cwnlUNJWNrldH8A==';
  var token =
      'ZMdXfp4gxpyeQ_a4mcQa2VBdvyrFFkv6Qpm72OX2D6H2DelI14H5YNp40rYF_u4Lb1uj_ea9qJemv9ZEYJp0TQ==';
  var org = 'GEINTRA_USRF';

  // var bucket = 'IMP_Tracker_prueba';
  var bucket = 'IMP_TRACKER';
  var bucket_SM = 'POM';

  InfluxDBService() {
    //PC POM
    client = InfluxDBClient(
      url: url, // PC POM
      token: token,
      org: org,
      bucket: bucket,
    );
  }

  Future<void> answerQuestion(
    int pacienteId,
    int codPregunta,
    int respuesta,
  ) async {
    final writeService = client.getWriteService();

    final point = Point('respuestas_paciente')
        .addTag('paciente_id', pacienteId.toString())
        .addTag('pregunta_id', codPregunta.toString())
        .addField('respuesta', respuesta)
        .time(DateTime.now());

    try {
      await writeService.write(point);
    } catch (e) {
      print('Error al guardar respuestas: $e');
    }
  }

  Future<bool> checkIfAnswered(int pacienteId, int codPregunta) async {
    final queryService = client.getQueryService();

    final now = DateTime.now().toUtc();
    final startOfDay = DateTime(now.year, now.month, now.day).toUtc();

    final startIso = startOfDay.toIso8601String();
    final nowIso = now.toIso8601String();

    final query =
        '''
  from(bucket: "$bucket")
    |> range(start: time(v: "$startIso"), stop: time(v: "$nowIso"))
    |> filter(fn: (r) => r["_measurement"] == "respuestas_paciente")
    |> filter(fn: (r) => r["_field"] == "respuesta")
    |> filter(fn: (r) => r["paciente_id"] == "$pacienteId")
    |> filter(fn: (r) => r["pregunta_id"] == "$codPregunta")
  ''';

    print(query);

    final result = await queryService.query(query);
    final records = await result.toList();

    return records.isNotEmpty;
  }

  Future<Map<int, String>> getPatientAnswers(
    int pacienteId,
    DateTime selectedDate,
  ) async {
    final queryService = client.getQueryService();

    // Definir rango basado en la fecha seleccionada
    String dateStr = selectedDate.toIso8601String().split('T')[0];
    String start = "${dateStr}T00:00:00Z";
    String stop = "${dateStr}T23:59:59Z";

    final query =
        '''
    from(bucket: "$bucket")
      |> range(start: time(v: "$start"), stop: time(v: "$stop"))
      |> filter(fn: (r) => r["_measurement"] == "respuestas_paciente")
      |> filter(fn: (r) => r["_field"] == "respuesta")
      |> filter(fn: (r) => r["paciente_id"] == "$pacienteId")
  ''';

    final result = await queryService.query(query);
    final records = await result.toList();

    final Map<int, String> questionAnswersMap = {};

    for (var record in records) {
      final questionCode = int.tryParse(
        record['pregunta_id']?.toString() ?? '',
      );
      final answer = record['_value']?.toString();

      print("Registro: $record");

      if (questionCode != null && answer != null) {
        questionAnswersMap[questionCode] = answer;
      }
    }

    print("Respuestas obtenidas: $questionAnswersMap");
    return questionAnswersMap;
  }

  Future<Map<int, int>> getPatientAnswersByDate(
    int pacienteId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final queryService = client.getQueryService();

    final startIso = startDate.toUtc().toIso8601String();
    final endIso = endDate.toUtc().toIso8601String();

    final query =
        '''
  from(bucket: "$bucket")
    |> range(start: time(v: "$startIso"), stop: time(v: "$endIso"))
    |> filter(fn: (r) => r["_measurement"] == "respuestas_paciente")
    |> filter(fn: (r) => r["_field"] == "respuesta")
    |> filter(fn: (r) => r["paciente_id"] == "$pacienteId")
  ''';

    final result = await queryService.query(query);
    final records = await result.toList();

    final Map<int, int> questionAnswersMap = {};

    for (var record in records) {
      final questionCode = record['pregunta_id'];
      final answer = record['_value'];

      print("Registro: $record");

      if (questionCode != null && answer != null) {
        final answerInt = (answer is int)
            ? answer
            : int.tryParse(answer.toString()) ?? 0;

        questionAnswersMap[questionCode] = answerInt;
      }
    }

    print("Registros obtenidos: $records");
    return questionAnswersMap;
  }

  Future GetHumTempBat(
    codPaceinteWearable,
    deviceId,
    startDateString,
    endDateString,
    every,
  ) async {
    var startDate = DateTime.parse(startDateString);
    var endDate = DateTime.parse(endDateString);
    // Configura el cliente de InfluxDB
    var BatteryLevel = 0;
    var HumidityLevel = 0;
    var TemperatureLevel = 0;
    var BaterryList = <BaterryData>[];
    // Realiza una consulta para obtener el nivel de la batería
    // Lectura de los datos
    var queryService = client.getQueryService();
    var BateriaQuery =
        '''
      from(bucket: "$bucket")
        |> range(start: ${startDate.toIso8601String()}, stop: ${endDate.toIso8601String()})
        |> filter(fn: (r) => r["_measurement"] == "$codPaceinteWearable")
        |> filter(fn: (r) => r["Data_type"] == "MISC")
        |> filter(fn: (r) => r["Device_ID"] == "$deviceId")
        |> filter(fn: (r) => r["Sensor_type"] == "Device_info")
        |> filter(fn: (r) => r["_field"] == "Battery")
        |> aggregateWindow(every: $every, fn: last, createEmpty: false)
        
    ''';
    var BateriaResponse = await queryService.query(BateriaQuery);

    // Convertir el Stream en una lista
    var BateriaRecords = await BateriaResponse.toList();

    for (var record in BateriaRecords) {
      var Baterry = record["_value"];
      var timestampString = record["_time"];
      var timestamp = DateTime.parse(timestampString).toLocal();

      BaterryList.add(BaterryData(Baterry, timestamp));
    }
    BaterryList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    // Obtener el último registro de la lista
    if (BateriaRecords.isNotEmpty) {
      var lastRecord = BateriaRecords.last;
      var batteryValue = double.parse(lastRecord['_value'].toString());
      var roundedBatteryValue = batteryValue.floor();
      BatteryLevel = roundedBatteryValue.toInt();
    }
    var HumedadQuery =
        '''
      from(bucket: "$bucket")
        |> range(start: ${startDate.toIso8601String()}, stop: ${endDate.toIso8601String()})
        |> filter(fn: (r) => r["_measurement"] == "$codPaceinteWearable")
        |> filter(fn: (r) => r["Data_type"] == "measurement")
        |> filter(fn: (r) => r["Device_ID"] == "$deviceId")
        |> filter(fn: (r) => r["Sensor_type"] == "Ambient")
        |> filter(fn: (r) => r["_field"] == "Humidity")
        |> aggregateWindow(every: $every, fn: last, createEmpty: false)
    ''';
    var HumedadResponse = await queryService.query(HumedadQuery);

    // Convertir el Stream en una lista
    var HumedadRecords = await HumedadResponse.toList();

    // Obtener el último registro de la lista
    if (HumedadRecords.isNotEmpty) {
      var lastRecord = HumedadRecords.last;
      var HumidityValue = double.parse(lastRecord['_value'].toString());
      var roundedHumidityValue = HumidityValue.floor();
      HumidityLevel = roundedHumidityValue.toInt();
    }
    var TemperatureQuery =
        '''
      from(bucket: "$bucket")
        |> range(start: ${startDate.toIso8601String()}, stop: ${endDate.toIso8601String()})
        |> filter(fn: (r) => r["_measurement"] == "$codPaceinteWearable")
        |> filter(fn: (r) => r["Data_type"] == "measurement")
        |> filter(fn: (r) => r["Device_ID"] == "$deviceId")
        |> filter(fn: (r) => r["Sensor_type"] == "Ambient")
        |> filter(fn: (r) => r["_field"] == "Temperature")
        |> aggregateWindow(every: $every, fn: last, createEmpty: false)
    ''';
    var TemperatureResponse = await queryService.query(TemperatureQuery);

    // Convertir el Stream en una lista
    var TemperatureRecords = await TemperatureResponse.toList();

    // Obtener el último registro de la lista
    if (TemperatureRecords.isNotEmpty) {
      var lastRecord = TemperatureRecords.last;
      var TemperatureValue = double.parse(lastRecord['_value'].toString());
      var roundedTemperatureValue = TemperatureValue.floor();
      TemperatureLevel = roundedTemperatureValue.toInt();
    }
    client.close();
    // Procesa los resultados y devuelve el nivel de la batería
    return [BatteryLevel, HumidityLevel, TemperatureLevel, BaterryList];

    // Si no se pudo obtener el nivel de la batería, devuelve un valor predeterminado
    //return -1;
  }

  Future GetRoom(
    codPacienteWearable,
    deviceId,
    startDateString,
    endDateString,
    every,
  ) async {
    var startDate = DateTime.parse(startDateString);
    var endDate = DateTime.parse(endDateString);
    var queryService = client.getQueryService();
    var RoomQuery =
        '''
      from(bucket: "$bucket")
        |> range(start: ${startDate.toIso8601String()}, stop: ${endDate.toIso8601String()})
        |> filter(fn: (r) => r["_measurement"] == "$codPacienteWearable")
        |> filter(fn: (r) => r["Data_type"] == "MISC")
        |> filter(fn: (r) => r["Device_ID"] == "$deviceId")
        |> filter(fn: (r) => r["Sensor_type"] == "Indoor_Pos")
        |> filter(fn: (r) => r["_field"] == "Room")
        |> aggregateWindow(every: $every, fn: last, createEmpty: false)
    ''';
    var RoomResponse = await queryService.query(RoomQuery);
    // Convertir el Stream en una lista
    var RoomRecords = await RoomResponse.toList();
    client.close();
    // Procesa los resultados y devuelve el nivel de la batería
    // Procesar los resultados
    var roomList = <RoomData>[];
    for (var record in RoomRecords) {
      var CodHabitacionSensor = record["_value"].toInt();
      var room = 'HS${record["_value"].toInt()}';
      var timestampString = record["_time"];
      var timestamp = DateTime.parse(timestampString).toLocal();

      roomList.add(RoomData(room, timestamp, CodHabitacionSensor));
    }
    roomList.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return roomList;
  }

  Future GetSteps(
    codPacienteWearable,
    deviceId,
    startDateString,
    endDateString,
    every,
  ) async {
    var startDate = DateTime.parse(startDateString);
    var endDate = DateTime.parse(endDateString);
    var queryService = client.getQueryService();
    var StepsQuery =
        '''
      from(bucket: "$bucket")
        |> range(start: ${startDate.toIso8601String()}, stop: ${endDate.toIso8601String()})
        |> filter(fn: (r) => r["_measurement"] == "$codPacienteWearable")
        |> filter(fn: (r) => r["Data_type"] == "MISC")
        |> filter(fn: (r) => r["Device_ID"] == "$deviceId")
        |> filter(fn: (r) => r["Sensor_type"] == "Movement")
        |> filter(fn: (r) => r["_field"] == "Steps")     
        |> aggregateWindow(every: $every, fn: last, createEmpty: false)
    ''';
    var StepsResponse = await queryService.query(StepsQuery);
    // Convertir el Stream en una lista
    var StepsRecords = await StepsResponse.toList();
    client.close();
    // Procesar los resultados
    var StepList = <StepData>[];
    for (var record in StepsRecords) {
      var Step = record["_value"];
      var timestampString = record["_time"];
      var timestamp = DateTime.parse(timestampString).toLocal();

      StepList.add(StepData(Step, timestamp));
      print('object');
    }
    print('object');

    return StepList;
  }

  Future<List<DoorSensorData>> GetDS(
    List SensoresPuerta,
    startDateString,
    endDateString,
    every,
  ) async {
    var startDate = DateTime.parse(startDateString);
    var endDate = DateTime.parse(endDateString);
    var DSList = <DoorSensorData>[];
    var queryService = client.getQueryService();

    // Itera sobre cada sensor de puerta
    for (var sensor in SensoresPuerta) {
      var codDs = sensor
          .CodHabitacionSensor; // Obtén el código del sensor de la habitación
      var deviceId = sensor.IDSensor; // Obtén el ID del dispositivo
      var DSQuery =
          '''
        from(bucket: "$bucket")
          |> range(start: ${startDate.toIso8601String()}, stop: ${endDate.toIso8601String()})
          |> filter(fn: (r) => r["_measurement"] == "$codDs")
          |> filter(fn: (r) => r["Data_type"] == "MISC")
          |> filter(fn: (r) => r["Device_ID"] == "$deviceId")
          |> filter(fn: (r) => r["Sensor_type"] == "Door")
          |> filter(fn: (r) => r["_field"] == "Open")
          |> aggregateWindow(every: $every, fn: last, createEmpty: false)
      ''';

      var DSResponse = await queryService.query(DSQuery);
      // Convertir el Stream en una lista
      var DSRecords = await DSResponse.toList();

      if (DSRecords.isNotEmpty) {
        for (var i = 0; i < DSRecords.length; i++) {
          var DS = DSRecords[i]["_value"].toInt();
          var timestampStringDS = DSRecords[i]["_time"];
          var timestampDS = DateTime.parse(timestampStringDS).toLocal();

          DoorSensorData DSData = DoorSensorData(
            timestampDS,
            DS,
            codDs,
          ); // Ajusta el orden de los parámetros
          DSList.add(DSData);
        }
      }
    }

    DSList.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return DSList;
  }

  Future GetAlarmStats(
    codPaceinteWearable,
    deviceId,
    List AlarmPaciente,
    startDateString,
    endDateString,
    every,
  ) async {
    var startDate = DateTime.parse(startDateString);
    var endDate = DateTime.parse(endDateString);
    var AlarmsList = <AlarmaData2>[];
    var queryService = client.getQueryService();
    var CaidaQuery =
        '''
      from(bucket: "$bucket")
        |> range(start: ${startDate.toIso8601String()}, stop: ${endDate.toIso8601String()})
        |> filter(fn: (r) => r["_measurement"] == "$codPaceinteWearable")
        |> filter(fn: (r) => r["Data_type"] == "alarm")
        |> filter(fn: (r) => r["Device_ID"] == "$deviceId")
        |> aggregateWindow(every: $every, fn: last, createEmpty: false)
    ''';
    var CaidaResponse = await queryService.query(CaidaQuery);
    // Convertir el Stream en una lista
    var CaidaRecords = await CaidaResponse.toList();
    print('object');
    client.close();

    if (CaidaRecords.isNotEmpty) {
      for (var i = 0; i < CaidaRecords.length; i++) {
        print('object');
        var Alarm = CaidaRecords[i]["Sensor_type"].toString();
        var Valor = CaidaRecords[i]["_value"].toInt();
        // var boton = BotonRecords[i]["_value"].toInt();
        var timestampString = CaidaRecords[i]["_time"];
        var timestampStringBoton = CaidaRecords[i]["_time"];
        var timestamp = DateTime.parse(timestampString).toLocal();
        var timestampBoton = DateTime.parse(timestampStringBoton).toLocal();

        AlarmaData2 alarmsData = AlarmaData2(Alarm, Valor, timestamp);
        AlarmsList.add(alarmsData);
      }
      print('object');
    }
    print('object');

    AlarmsList.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    print('object');
    return AlarmsList;
  }

  Future GetAlarm(
    codPaceinteWearable,
    deviceId,
    startDateString,
    endDateString,
    every,
  ) async {
    var startDate = DateTime.parse(startDateString);
    var endDate = DateTime.parse(endDateString);
    var AlarmsList = <AlarmaData>[];
    var queryService = client.getQueryService();
    var CaidaQuery =
        '''
      from(bucket: "$bucket")
        |> range(start: ${startDate.toIso8601String()}, stop: ${endDate.toIso8601String()})
        |> filter(fn: (r) => r["_measurement"] == "$codPaceinteWearable")
        |> filter(fn: (r) => r["Data_type"] == "alarm")
        |> filter(fn: (r) => r["Device_ID"] == "$deviceId")
        |> filter(fn: (r) => r["Sensor_type"] == "fall")
        |> filter(fn: (r) => r["_field"] == "Activation")
        |> aggregateWindow(every: $every, fn: last, createEmpty: false)
    ''';
    var CaidaResponse = await queryService.query(CaidaQuery);
    // Convertir el Stream en una lista
    var CaidaRecords = await CaidaResponse.toList();
    var BotonQuery =
        '''
      from(bucket: "$bucket")
        |> range(start: ${startDate.toIso8601String()}, stop: ${endDate.toIso8601String()})
        |> filter(fn: (r) => r["_measurement"] == "$codPaceinteWearable")
        |> filter(fn: (r) => r["Data_type"] == "alarm")
        |> filter(fn: (r) => r["Device_ID"] == "$deviceId")
        |> filter(fn: (r) => r["Sensor_type"] == "panic_button")
        |> filter(fn: (r) => r["_field"] == "Activation")
        |> aggregateWindow(every: $every, fn: last, createEmpty: false)
    ''';
    var BotonResponse = await queryService.query(BotonQuery);
    // Convertir el Stream en una lista
    var BotonRecords = await BotonResponse.toList();
    client.close();

    if (CaidaRecords.isNotEmpty && BotonRecords.isNotEmpty) {
      for (var i = 0; i < BotonRecords.length; i++) {
        var caida = CaidaRecords[i]["_value"].toInt();
        var boton = BotonRecords[i]["_value"].toInt();
        var timestampStringCaida = CaidaRecords[i]["_time"];
        var timestampStringBoton = CaidaRecords[i]["_time"];
        var timestampCaida = DateTime.parse(timestampStringCaida).toLocal();
        var timestampBoton = DateTime.parse(timestampStringBoton).toLocal();

        AlarmaData alarmsData = AlarmaData(
          caida,
          boton,
          timestampCaida,
          timestampBoton,
        );
        AlarmsList.add(alarmsData);
      }
    }
    AlarmsList.sort((a, b) => a.timestampCaida.compareTo(b.timestampCaida));
    return AlarmsList;
  }

  Future GetAlarm2(
    codPaceinteWearable,
    startDateString,
    endDateString,
    every,
  ) async {
    var startDate = DateTime.parse(startDateString);
    var endDate = DateTime.parse(endDateString);
    var AlarmsList = <AlarmaData>[];
    var queryService = client.getQueryService();
    var CaidaQuery =
        '''
      from(bucket: "$bucket")
        |> range(start: ${startDate.toIso8601String()}, stop: ${endDate.toIso8601String()})
        |> filter(fn: (r) => r["_measurement"] == "$codPaceinteWearable")
        |> filter(fn: (r) => r["Data_type"] == "alarm")
        |> filter(fn: (r) => r["Sensor_type"] == "fall")
        |> filter(fn: (r) => r["_field"] == "Activation")
        |> aggregateWindow(every: $every, fn: last, createEmpty: false)
    ''';
    var CaidaResponse = await queryService.query(CaidaQuery);
    // Convertir el Stream en una lista
    var CaidaRecords = await CaidaResponse.toList();
    var BotonQuery =
        '''
      from(bucket: "$bucket")
        |> range(start: ${startDate.toIso8601String()}, stop: ${endDate.toIso8601String()})
        |> filter(fn: (r) => r["_measurement"] == "$codPaceinteWearable")
        |> filter(fn: (r) => r["Data_type"] == "alarm")
        |> filter(fn: (r) => r["Sensor_type"] == "panic_button")
        |> filter(fn: (r) => r["_field"] == "Activation")
        |> aggregateWindow(every: $every, fn: last, createEmpty: false)
    ''';
    var BotonResponse = await queryService.query(BotonQuery);
    // Convertir el Stream en una lista
    var BotonRecords = await BotonResponse.toList();
    client.close();

    if (CaidaRecords.isNotEmpty && BotonRecords.isNotEmpty) {
      for (var i = 0; i < BotonRecords.length; i++) {
        var caida = CaidaRecords[i]["_value"].toInt();
        var boton = BotonRecords[i]["_value"].toInt();
        var timestampStringCaida = CaidaRecords[i]["_time"];
        var timestampStringBoton = CaidaRecords[i]["_time"];
        var timestampCaida = DateTime.parse(timestampStringCaida).toLocal();
        var timestampBoton = DateTime.parse(timestampStringBoton).toLocal();

        AlarmaData alarmsData = AlarmaData(
          caida,
          boton,
          timestampCaida,
          timestampBoton,
        );
        AlarmsList.add(alarmsData);
      }
    }
    AlarmsList.sort((a, b) => a.timestampCaida.compareTo(b.timestampCaida));
    return AlarmsList;
  }

  Future GetGPS(
    codPaceinteWearable,
    deviceId,
    startDateString,
    endDateString,
    every,
  ) async {
    var startDate = DateTime.parse(startDateString);
    var endDate = DateTime.parse(endDateString);
    var queryService = client.getQueryService();
    var LatQuery =
        '''
      from(bucket: "$bucket")
        |> range(start: ${startDate.toIso8601String()}, stop: ${endDate.toIso8601String()})
        |> filter(fn: (r) => r["_measurement"] == "$codPaceinteWearable")
        |> filter(fn: (r) => r["Data_type"] == "measurement")
        |> filter(fn: (r) => r["Device_ID"] == "$deviceId")
        |> filter(fn: (r) => r["Sensor_type"] == "GPS")
        |> filter(fn: (r) => r["_field"] == "Lat")
        |> aggregateWindow(every: $every, fn: last, createEmpty: false)
    ''';
    var LatResponse = await queryService.query(LatQuery);
    // Convertir el Stream en una lista
    var LatRecords = await LatResponse.toList();

    var LatList = <LatData>[];
    for (var record in LatRecords) {
      var Lat = record["_value"];
      var timestampString = record["_time"];
      var timestamp = DateTime.parse(timestampString).toLocal();

      LatList.add(LatData(Lat, timestamp));
    }
    LatList.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    var LongQuery =
        '''
      from(bucket: "$bucket")
        |> range(start: ${startDate.toIso8601String()}, stop: ${endDate.toIso8601String()})
        |> filter(fn: (r) => r["_measurement"] == "$codPaceinteWearable")
        |> filter(fn: (r) => r["Data_type"] == "measurement")
        |> filter(fn: (r) => r["Device_ID"] == "$deviceId")
        |> filter(fn: (r) => r["Sensor_type"] == "GPS")
        |> filter(fn: (r) => r["_field"] == "Long")
        |> aggregateWindow(every: $every, fn: last, createEmpty: false)
    ''';
    var LongResponse = await queryService.query(LongQuery);
    // Convertir el Stream en una lista
    var LongRecords = await LongResponse.toList();
    client.close();
    var LongList = <LongData>[];
    for (var record in LongRecords) {
      var Long = record["_value"];
      var timestampString = record["_time"];
      var timestamp = DateTime.parse(timestampString).toLocal();

      LongList.add(LongData(Long, timestamp));
    }
    LongList.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return [LatList, LongList];
  }

  Future GetLTSM(deviceId, startDateString, endDateString, every) async {
    var startDate = DateTime.parse(startDateString);
    var endDate = DateTime.parse(endDateString);
    var queryService = client.getQueryService();
    var consumedEnergyquery =
        '''
      from(bucket: "$bucket_SM")
        |> range(start: ${startDate.toIso8601String()}, stop: ${endDate.toIso8601String()})
        |> filter(fn: (r) => r["_measurement"] == "UAH-GT0002")
        |> filter(fn: (r) => r["_field"] == "consumed_energy")
        |> filter(fn: (r) => r["location"] == "Alcala")  
        |> aggregateWindow(every: $every, fn: mean, createEmpty: false)
    ''';
    var consumedResponse = await queryService.query(consumedEnergyquery);
    // Convertir el Stream en una lista
    var ConsumeRecords = await consumedResponse.toList();

    // Procesar los resultados
    var ConsumedEnergy = <LTSMData>[];
    for (var record in ConsumeRecords) {
      var consumedEnergy = record["_value"];
      var timestampString = record["_time"];
      var timestamp = DateTime.parse(timestampString).toLocal();
      var name = record["_field"];

      ConsumedEnergy.add(LTSMData(consumedEnergy, timestamp, name));
      print('object');
    }
    var predictedEnergyquery =
        '''
      from(bucket: "$bucket_SM")
        |> range(start: ${startDate.toIso8601String()}, stop: ${endDate.toIso8601String()})
        |> filter(fn: (r) => r["_measurement"] == "UAH-GT0002")
        |> filter(fn: (r) => r["_field"] == "predicted_energy")
        |> filter(fn: (r) => r["location"] == "Alcala")  
        |> aggregateWindow(every: $every, fn: mean, createEmpty: false)
    ''';
    var predictedResponse = await queryService.query(predictedEnergyquery);
    // Convertir el Stream en una lista
    var PredictedRecords = await predictedResponse.toList();
    client.close();
    // Procesar los resultados
    var PredictedEnergy = <LTSMData>[];
    for (var record in PredictedRecords) {
      var predictedEnergy = record["_value"];
      var timestampString = record["_time"];
      var timestamp = DateTime.parse(timestampString).toLocal();
      var name = record["_field"];

      PredictedEnergy.add(LTSMData(predictedEnergy, timestamp, name));
      print('object');
    }
    return [ConsumedEnergy, PredictedEnergy];
  }

  Future GetLTSMAlarms(deviceId, startDateString, endDateString, every) async {
    var startDate = DateTime.parse(startDateString);
    var endDate = DateTime.parse(endDateString);
    var queryService = client.getQueryService();
    var AlarmQuery =
        '''
      from(bucket: "$bucket_SM")
        |> range(start: ${startDate.toIso8601String()}, stop: ${endDate.toIso8601String()})
        |> filter(fn: (r) => r["_measurement"] == "UAH-GT0002")
        |> filter(fn: (r) => r["_field"] == "lunch_alarm" or r["_field"] == "dinner_alarm" or r["_field"] == "breakfast_alarm" or r["_field"] == "sleeping_alarm")
        |> filter(fn: (r) => r["location"] == "Alcala")
        |> aggregateWindow(every: $every, fn: mean, createEmpty: false)
    ''';
    var alarmResponse = await queryService.query(AlarmQuery);
    // Convertir el Stream en una lista
    var AlarmRecords = await alarmResponse.toList();
    client.close();
    // Procesar los resultados
    var Alarm = <AlarmaData2>[];
    for (var record in AlarmRecords) {
      var AlarmValue = record["_value"];
      var timestampString = record["_time"];
      var timestamp = DateTime.parse(timestampString).toLocal();
      var name = record["_field"];

      Alarm.add(AlarmaData2(name, AlarmValue, timestamp));
      print('object');
    }
    return Alarm;
  }

  Future GetADLs(deviceId, startDateString, endDateString, every) async {
    var startDate = DateTime.parse(startDateString);
    var endDate = DateTime.parse(endDateString);
    var queryService = client.getQueryService();
    var ADLsQuery =
        '''
      from(bucket: "$bucket_SM")
        |> range(start: ${startDate.toIso8601String()}, stop: ${endDate.toIso8601String()})
        |> filter(fn: (r) => r["_measurement"] == "UAH-GT0002")
        |> filter(fn: (r) => r["_field"] == "breakfast" or r["_field"] == "sleeping" or r["_field"] == "lunch" or r["_field"] == "dinner" or r["_field"] == "housekeeping" or r["_field"] == "leisure" or r["_field"] == "unoccupied")
        |> filter(fn: (r) => r["location"] == "Alcala")
        |> aggregateWindow(every: $every, fn: mean, createEmpty: false)
    ''';
    var adlsResponse = await queryService.query(ADLsQuery);
    // Convertir el Stream en una lista
    var ADLsRecords = await adlsResponse.toList();
    client.close();
    // Procesar los resultados
    var ADLs = <AlarmaData2>[];
    for (var record in ADLsRecords) {
      var ADLsValue = record["_value"];
      var timestampString = record["_time"];
      var timestamp = DateTime.parse(timestampString).toLocal();
      var name = record["_field"];

      ADLs.add(AlarmaData2(name, ADLsValue, timestamp));
      print('object');
    }
    return ADLs;
  }

  Future GetEvADLs(deviceId, startDateString, endDateString, every) async {
    var startDate = DateTime.parse(startDateString);
    var endDate = DateTime.parse(endDateString);
    var queryService = client.getQueryService();
    var EvADLsQuery =
        '''
      from(bucket: "$bucket_SM")
        |> range(start: ${startDate.toIso8601String()}, stop: ${endDate.toIso8601String()})
        |> filter(fn: (r) => r["_measurement"] == "UAH-GT0002")
        |> filter(fn: (r) => r["_field"] == "breakfastscore" or r["_field"] == "dinnerscore" or r["_field"] == "housekeepingscore" or r["_field"] == "leisurescore" or r["_field"] == "lunchscore" or r["_field"] == "sleepingscore" or r["_field"] == "unoccupiedscore")
        |> filter(fn: (r) => r["location"] == "Alcala")
        |> aggregateWindow(every: $every, fn: mean, createEmpty: false)
    ''';
    var evadlsResponse = await queryService.query(EvADLsQuery);
    // Convertir el Stream en una lista
    var EvADLsRecords = await evadlsResponse.toList();
    client.close();
    // Procesar los resultados
    var EvADLs = <AlarmaData2>[];
    for (var record in EvADLsRecords) {
      var EvADLsValue = record["_value"];
      var timestampString = record["_time"];
      var timestamp = DateTime.parse(timestampString).toLocal();
      var name = record["_field"];

      EvADLs.add(AlarmaData2(name, EvADLsValue, timestamp));
      print('object');
    }
    return EvADLs;
  }

  Future GetConsumo(deviceId, startDateString, endDateString, every) async {
    var startDate = DateTime.parse(startDateString);
    var endDate = DateTime.parse(endDateString);
    var queryService = client.getQueryService();
    var ConsumoQuery =
        '''
      from(bucket: "$bucket_SM")
        |> range(start: ${startDate.toIso8601String()}, stop: ${endDate.toIso8601String()})
        |> filter(fn: (r) => r["_measurement"] == "UAH-GT0002")
        |> filter(fn: (r) => r["_field"] == "general" or r["_field"] == "fridge" or r["_field"] == "dishwasher" or r["_field"] == "kettle" or r["_field"] == "microwave" or r["_field"] == "oven" or r["_field"] == "tv" or r["_field"] == "washing_Machine" or r["_field"] == "airconditioning" or r["_field"] == "lighting" or r["_field"] == "blanket" or r["_field"] == "mains")
        |> filter(fn: (r) => r["location"] == "Alcala")
        |> aggregateWindow(every: $every, fn: mean, createEmpty: false)
    ''';
    var consumoResponse = await queryService.query(ConsumoQuery);
    // Convertir el Stream en una lista
    var ConsumoRecords = await consumoResponse.toList();
    client.close();
    // Procesar los resultados
    var Consumo = <LTSMData>[];
    for (var record in ConsumoRecords) {
      var ConsumoValue = record["_value"];
      var timestampString = record["_time"];
      var timestamp = DateTime.parse(timestampString).toLocal();
      var name = record["_field"];

      Consumo.add(LTSMData(ConsumoValue, timestamp, name));
      print('object');
    }
    return Consumo;
  }
}
