import 'package:shared_preferences/shared_preferences.dart';
import 'package:yummy/model/payment/bank_card_model.dart';
import 'package:yummy/model/payment/transfer_model.dart';
import 'package:yummy/services/card_payment_service.dart';

class TransferService {
  static const String _transfersKey = 'saved_transfers';
  final CardPaymentService _cardService = CardPaymentService();

  bool isMirCard(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\s+'), '');
    return cleaned.startsWith('2');
  }

  bool validateRecipientCard(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.length < 16 || cleaned.length > 19) return false;
    
    int sum = 0;
    bool isEven = false;
    
    for (int i = cleaned.length - 1; i >= 0; i--) {
      int digit = int.parse(cleaned[i]);
      
      if (isEven) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }
      
      sum += digit;
      isEven = !isEven;
    }
    
    return sum % 10 == 0;
  }

  bool areCardsDifferent(String card1, String card2) {
    final cleaned1 = card1.replaceAll(RegExp(r'\s+'), '');
    final cleaned2 = card2.replaceAll(RegExp(r'\s+'), '');
    return cleaned1 != cleaned2;
  }

  bool hasSufficientFunds(String fromCard, double amount) {
    // В реальном приложении здесь будет запрос к API банка
    // Для демо считаем, что на всех картах достаточно средств
    return amount > 0 && amount <= 50000;
  }

  Future<TransferModel> processTransfer({
    required BankCardModel fromCard,
    required String toCardNumber,
    required double amount,
    required String description,
  }) async {
    try {
      if (!isMirCard(fromCard.cardNumber)) {
        throw Exception('Карта отправителя должна быть картой МИР');
      }

      if (!isMirCard(toCardNumber)) {
        throw Exception('Карта получателя должна быть картой МИР');
      }

      if (!validateRecipientCard(toCardNumber)) {
        throw Exception('Неверный номер карты получателя');
      }

      if (!areCardsDifferent(fromCard.cardNumber, toCardNumber)) {
        throw Exception('Нельзя переводить на ту же карту');
      }

      if (!hasSufficientFunds(fromCard.cardNumber, amount)) {
        throw Exception('Недостаточно средств на карте');
      }

      final transfer = TransferModel(
        id: 'transfer_${DateTime.now().millisecondsSinceEpoch}',
        fromCard: fromCard.maskedCardNumber,
        toCard: toCardNumber,
        amount: amount,
        description: description,
        createdAt: DateTime.now(),
        status: 'pending',
      );

      await Future.delayed(const Duration(seconds: 2));

      final isSuccess = DateTime.now().millisecond % 10 != 0;
      
      final completedTransfer = TransferModel(
        id: transfer.id,
        fromCard: transfer.fromCard,
        toCard: transfer.toCard,
        amount: transfer.amount,
        description: transfer.description,
        createdAt: transfer.createdAt,
        status: isSuccess ? 'completed' : 'failed',
      );

      await _saveTransfer(completedTransfer);

      if (!isSuccess) {
        throw Exception('Перевод не прошел. Попробуйте позже.');
      }

      return completedTransfer;

    } catch (e) {
      rethrow;
    }
  }

  Future<void> _saveTransfer(TransferModel transfer) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTransfers = await getTransferHistory();
      
      savedTransfers.add(transfer);
      
      final transfersJson = savedTransfers.map((t) => t.toJson()).toList();
      await prefs.setString(_transfersKey, transfersJson.toString());
    } catch (e) {
      throw Exception('Ошибка сохранения перевода: $e');
    }
  }

  Future<List<TransferModel>> getTransferHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transfersString = prefs.getString(_transfersKey);
      
      if (transfersString == null) return [];
      
      final List<dynamic> transfersJson = transfersString as List<dynamic>;
      return transfersJson.map((json) => TransferModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  double getTransferCommission(double amount) {
    return 0.0;
  }

  double getTotalAmount(double amount) {
    return amount + getTransferCommission(amount);
  }
}