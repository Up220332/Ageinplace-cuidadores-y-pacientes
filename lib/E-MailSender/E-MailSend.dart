import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

// void Send_mail(Name, Surname1, Surname2, DateBirth, PhoneNumber, Email) {
//   var Service_id = 'service_3yiyns3',
//       Template_id = 'template_pr1v8n8',
//       User_id = '3dcvc-p-UdpxH7NwQ';
//   var s = http.post(
//     Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
//     headers: {'origin': 'http:localhost', 'Content-Type': 'application/json'},
//     body: jsonEncode(
//       {
//         'service_id': Service_id,
//         'user_id': User_id,
//         'template_id': Template_id,
//         'template_params': {
//           'Name': '$Name',
//           'Surname1': '$Surname1',
//           'Surname2': '$Surname2',
//           'DateBirth': '$DateBirth',
//           'PhoneNumber': '$PhoneNumber',
//           'Email': '$Email',
//         }
//       },
//     ),
//   );
// }

/*******************************************************************************
 * Enviar correo con la nueva contraseña
 ******************************************************************************/
// void SendNewPassword(Email, NewPassword) {
//   var Service_id = 'service_3yiyns3',
//       Template_id = 'template_blk4it5',
//       User_id = '3dcvc-p-UdpxH7NwQ';
//   var s = http.post(
//     Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
//     headers: {'origin': 'http:localhost', 'Content-Type': 'application/json'},
//     body: jsonEncode(
//       {
//         'service_id': Service_id,
//         'user_id': User_id,
//         'template_id': Template_id,
//         'template_params': {
//           'NewPassword': '$NewPassword',
//           'Email': '$Email',
//         }
//       },
//     ),
//   );
// }
/// *****************************************************************************
/// Enviar correo con la nueva contraseña
///****************************************************************************
Future<void> SendNewPassword(Email, NewPassword) async {
  try {
    var smtpServer = gmail('geintra.af@gmail.com', 'lhukgaeoubehsero');
    var message = Message();
    message.from = Address('geintra.af@gmail.com');
    message.recipients.add(Email);
    message.subject = 'Recuperación de contraseña';
    message.text =
        'Su nueva contraseña es: "$NewPassword".'
        '\n Por favor, cambie su contraseña en la sección de configuración de su cuenta.';
    send(message, smtpServer);
    var sendResult = await send(message, smtpServer);
    print("Correo enviado con éxito: $sendResult");
  } on MailerException catch (e) {
    print('Message not sent.');
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  }
}

/// *****************************************************************************
/// Enviar correo de confirmación de registro con la contraseña
///****************************************************************************
Future<void> SendRegistConfirm(Email, Password) async {
  try {
    var smtpServer = gmail('geintra.af@gmail.com', 'lhukgaeoubehsero');
    var message = Message();
    message.from = Address('geintra.af@gmail.com');
    message.recipients.add(Email);
    message.subject = 'Confirmacion de Registro';
    message.text =
        'Enhorabuena por registrarse en la aplicación IMP Tracker.'
        'Su contraseña es: "$Password".'
        '\n Por favor, cambie su contraseña en la sección de configuración de su cuenta.';
    send(message, smtpServer);
  } on MailerException catch (e) {
    print('Message not sent.');
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  }
}

/// *****************************************************************************
/// Enviar Confirmacion de Alta tras haber sido desactivado
///****************************************************************************
Future<void> SendAlta(Email) async {
  try {
    var smtpServer = gmail('geintra.af@gmail.com', 'lhukgaeoubehsero');
    var message = Message();
    message.from = Address('geintra.af@gmail.com');
    message.recipients.add(Email);
    message.subject = 'Alta en impTracker';
    message.text =
        'Se ha dado de alta en la aplicación IMP Tracker. Ya puede acceder a la aplicación con su usuario y contraseña.';
    send(message, smtpServer);
  } on MailerException catch (e) {
    print('Message not sent.');
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  }
}

/// *****************************************************************************
/// Enviar Confirmacion de baja tras haber sido desactivado
///****************************************************************************
Future<void> SendBaja(Email) async {
  try {
    var smtpServer = gmail('geintra.af@gmail.com', 'lhukgaeoubehsero');
    var message = Message();
    message.from = Address('geintra.af@gmail.com');
    message.recipients.add(Email);
    message.subject = 'Baja en impTracker';
    message.text =
        'Se ha dado de baja en la aplicación IMP Tracker. pongase en contacto con el administrador para más información: geintra.af@gmail.com.';
    send(message, smtpServer);
  } on MailerException catch (e) {
    print('Message not sent.');
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  }
}
