import 'package:shared_preferences/shared_preferences.dart';
import 'package:yummy/model/payment/bank_card_model.dart';

class CardPaymentService {
  static const String _cardsKey = 'saved_bank_cards';

  Future<void> saveCard(BankCardModel card) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCards = await getSavedCards();
      
      final filteredCards = savedCards.where((c) => c.id != card.id).toList();
      filteredCards.add(card);
      
      final cardsJson = filteredCards.map((c) => c.toJson()).toList();
      await prefs.setString(_cardsKey, cardsJson.toString());
    } catch (e) {
      throw Exception('Ошибка сохранения карты: $e');
    }
  }

  Future<List<BankCardModel>> getSavedCards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cardsString = prefs.getString(_cardsKey);
      
      if (cardsString == null) return [];
      
      final List<dynamic> cardsJson = cardsString as List<dynamic>;
      return cardsJson.map((json) => BankCardModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteCard(String cardId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCards = await getSavedCards();
      final filteredCards = savedCards.where((c) => c.id != cardId).toList();
      
      final cardsJson = filteredCards.map((c) => c.toJson()).toList();
      await prefs.setString(_cardsKey, cardsJson.toString());
    } catch (e) {
      throw Exception('Ошибка удаления карты: $e');
    }
  }

  bool validateCardNumber(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.length < 13 || cleaned.length > 19) return false;
    
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

  bool validateExpiryDate(String expiryDate) {
    final regExp = RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$');
    if (!regExp.hasMatch(expiryDate)) return false;
    
    final parts = expiryDate.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse('20${parts[1]}');
    
    final now = DateTime.now();
    final cardDate = DateTime(year, month + 1, 0);
    
    return cardDate.isAfter(now);
  }

  bool validateCvv(String cvv) {
    return RegExp(r'^[0-9]{3,4}$').hasMatch(cvv);
  }

  bool validateCardHolder(String cardHolder) {
    return cardHolder.length >= 2 && cardHolder.length <= 50;
  }

  Future<bool> processPayment({
    required BankCardModel card,
    required double amount,
    required String description,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    
    final random = DateTime.now().millisecond % 10;
    return random > 2;
  }
}