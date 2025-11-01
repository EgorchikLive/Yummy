// lib/services/yookassa_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yummy/model/payment/yookassa_payment_model.dart';

class YooKassaService {
  static const String _baseUrl = 'https://api.yookassa.ru/v3';
  static const String _paymentsKey = 'yookassa_payments';
  
  // Замените на реальные данные после регистрации
  static const String _shopId = 'your_shop_id_here';
  static const String _secretKey = 'your_secret_key_here';
  
  // Для демо-режима
  static bool _demoMode = true;

  // Базовые заголовки для API
  Map<String, String> get _headers {
    final auth = 'Basic ${base64Encode(utf8.encode('$_shopId:$_secretKey'))}';
    return {
      'Authorization': auth,
      'Content-Type': 'application/json',
      'Idempotence-Key': DateTime.now().millisecondsSinceEpoch.toString(),
    };
  }

  // Создание платежа
  Future<YooKassaPaymentModel> createPayment({
    required double amount,
    required String description,
    required bool savePaymentMethod,
    Map<String, dynamic>? metadata,
  }) async {
    if (_demoMode) {
      // Симуляция создания платежа для демо
      return _simulateCreatePayment(
        amount: amount,
        description: description,
        savePaymentMethod: savePaymentMethod,
        metadata: metadata,
      );
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payments'),
        headers: _headers,
        body: jsonEncode({
          'amount': {
            'value': amount.toStringAsFixed(2),
            'currency': 'RUB',
          },
          'confirmation': {
            'type': 'redirect',
            'return_url': 'yummyapp://payment/return',
          },
          'capture': true,
          'description': description,
          'save_payment_method': savePaymentMethod,
          'metadata': metadata ?? {},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final payment = YooKassaPaymentModel.fromJson(data);
        await _savePayment(payment);
        return payment;
      } else {
        throw Exception('Ошибка создания платежа: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка сети: $e');
    }
  }

  // Получение информации о платеже
  Future<YooKassaPaymentModel> getPayment(String paymentId) async {
    if (_demoMode) {
      return _simulateGetPayment(paymentId);
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payments/$paymentId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return YooKassaPaymentModel.fromJson(data);
      } else {
        throw Exception('Ошибка получения платежа: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка сети: $e');
    }
  }

  // Подтверждение платежа
  Future<bool> capturePayment(String paymentId) async {
    if (_demoMode) {
      await Future.delayed(const Duration(seconds: 2));
      return true; // Всегда успешно в демо-режиме
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payments/$paymentId/capture'),
        headers: _headers,
        body: jsonEncode({}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Отмена платежа
  Future<bool> cancelPayment(String paymentId) async {
    if (_demoMode) {
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payments/$paymentId/cancel'),
        headers: _headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Симуляция для демо-режима
  Future<YooKassaPaymentModel> _simulateCreatePayment({
    required double amount,
    required String description,
    required bool savePaymentMethod,
    Map<String, dynamic>? metadata,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final payment = YooKassaPaymentModel(
      id: 'demo_${DateTime.now().millisecondsSinceEpoch}',
      status: 'pending',
      amount: amount,
      description: description,
      confirmationUrl: 'https://yookassa.ru/demo/confirmation',
      createdAt: DateTime.now(),
      metadata: metadata,
    );

    await _savePayment(payment);
    return payment;
  }

  Future<YooKassaPaymentModel> _simulateGetPayment(String paymentId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Имитируем успешный платеж через 3 секунды
    final isSuccess = !paymentId.contains('fail');
    final status = isSuccess ? 'succeeded' : 'canceled';

    return YooKassaPaymentModel(
      id: paymentId,
      status: status,
      amount: 1000.0, // Демо сумма
      createdAt: DateTime.now().subtract(const Duration(seconds: 5)),
      description: 'Демо платеж',
    );
  }

  // Локальное сохранение платежей
  Future<void> _savePayment(YooKassaPaymentModel payment) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPayments = await getPaymentHistory();
      
      // Удаляем старую версию если есть
      savedPayments.removeWhere((p) => p.id == payment.id);
      savedPayments.add(payment);
      
      final paymentsJson = savedPayments.map((p) => p.toJson()).toList();
      await prefs.setString(_paymentsKey, jsonEncode(paymentsJson));
    } catch (e) {
      print('Ошибка сохранения платежа: $e');
    }
  }

  Future<List<YooKassaPaymentModel>> getPaymentHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final paymentsString = prefs.getString(_paymentsKey);
      
      if (paymentsString == null) return [];
      
      final List<dynamic> paymentsJson = jsonDecode(paymentsString);
      return paymentsJson.map((json) => YooKassaPaymentModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Включение/выключение демо-режима
  static void setDemoMode(bool enabled) {
    _demoMode = enabled;
  }

  static bool get isDemoMode => _demoMode;
}