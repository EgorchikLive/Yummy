// lib/config/sbp_config.dart
class SbpConfig {
  // Банковские реквизиты для СБП
  static const String receiverAccount = '40817810090159463613'; // Расчетный счет
  static const String bankBik = '044525745'; // БИК банка
  static const String receiverName = 'Yummy App'; // Наименование получателя
  static const String receiverInn = '7702070139'; // ИНН получателя

  // static const String receiverAccount = '40817810777030752341'; // Расчетный счет
  // static const String bankBik = '042908612'; // БИК банка
  // static const String receiverName = 'YummyApp'; // Наименование получателя
  // static const String receiverInn = '7707083893'; // ИНН получателя
  
  // URL для бэкенда (если есть)
  static const String apiUrl = 'https://api.yourdomain.com/sbp';
  
  // Настройки QR-кодов
  static const int qrCodeSize = 300;
}