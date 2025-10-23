import 'package:flutter/material.dart';
import 'package:yummy/model/payment/bank_card_model.dart';
import 'package:yummy/services/card_payment_service.dart';

class CardPaymentForm extends StatefulWidget {
  final double amount;
  final String description;
  final VoidCallback onSuccess;
  final VoidCallback onFailure;

  const CardPaymentForm({
    super.key,
    required this.amount,
    required this.description,
    required this.onSuccess,
    required this.onFailure,
  });

  @override
  State<CardPaymentForm> createState() => _CardPaymentFormState();
}

class _CardPaymentFormState extends State<CardPaymentForm> {
  final CardPaymentService _paymentService = CardPaymentService();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  
  bool _isProcessing = false;
  bool _saveCard = false;
  List<BankCardModel> _savedCards = [];
  BankCardModel? _selectedCard;

  @override
  void initState() {
    super.initState();
    _loadSavedCards();
  }

  Future<void> _loadSavedCards() async {
    final cards = await _paymentService.getSavedCards();
    setState(() {
      _savedCards = cards;
    });
  }

  void _selectCard(BankCardModel card) {
    setState(() {
      _selectedCard = card;
      _cardNumberController.text = card.cardNumber;
      _expiryDateController.text = card.expiryDate;
      _cardHolderController.text = card.cardHolder;
      // CVV не заполняем для безопасности
    });
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _cardNumberController.clear();
    _expiryDateController.clear();
    _cvvController.clear();
    _cardHolderController.clear();
    setState(() {
      _selectedCard = null;
      _saveCard = false;
    });
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final card = BankCardModel(
        id: _selectedCard?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        cardNumber: _cardNumberController.text.replaceAll(RegExp(r'\s+'), ''),
        expiryDate: _expiryDateController.text,
        cvv: _cvvController.text,
        cardHolder: _cardHolderController.text,
        isSaved: _saveCard,
        createdAt: DateTime.now(),
      );

      // Сохраняем карту если нужно
      if (_saveCard) {
        await _paymentService.saveCard(card);
      }

      // Обрабатываем платеж
      final success = await _paymentService.processPayment(
        card: card,
        amount: widget.amount,
        description: widget.description,
      );

      if (success) {
        widget.onSuccess();
      } else {
        widget.onFailure();
      }
    } catch (e) {
      _showErrorDialog('Ошибка оплаты: $e');
      widget.onFailure();
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ошибка'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите номер карты';
    }
    final cleaned = value.replaceAll(RegExp(r'\s+'), '');
    if (!_paymentService.validateCardNumber(cleaned)) {
      return 'Неверный номер карты';
    }
    return null;
  }

  String? _validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите срок действия';
    }
    if (!_paymentService.validateExpiryDate(value)) {
      return 'Неверный срок действия';
    }
    return null;
  }

  String? _validateCvv(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите CVV';
    }
    if (!_paymentService.validateCvv(value)) {
      return 'Неверный CVV';
    }
    return null;
  }

  String? _validateCardHolder(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите имя держателя карты';
    }
    if (!_paymentService.validateCardHolder(value)) {
      return 'Неверное имя держателя';
    }
    return null;
  }

  // Форматирование номера карты (группы по 4 цифры)
  void _formatCardNumber(String value) {
    final cleaned = value.replaceAll(RegExp(r'\s+'), '');
    final groups = <String>[];
    
    for (int i = 0; i < cleaned.length; i += 4) {
      final end = i + 4;
      if (end <= cleaned.length) {
        groups.add(cleaned.substring(i, end));
      } else {
        groups.add(cleaned.substring(i));
      }
    }
    
    _cardNumberController.value = _cardNumberController.value.copyWith(
      text: groups.join(' '),
      selection: TextSelection.collapsed(offset: groups.join(' ').length),
    );
  }

  // Форматирование срока действия (MM/YY)
  void _formatExpiryDate(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleaned.length >= 2) {
      final month = cleaned.substring(0, 2);
      final year = cleaned.length > 2 ? cleaned.substring(2, 4) : '';
      
      _expiryDateController.value = _expiryDateController.value.copyWith(
        text: year.isEmpty ? month : '$month/$year',
        selection: TextSelection.collapsed(
          offset: year.isEmpty ? month.length : '$month/$year'.length,
        ),
      );
    } else {
      _expiryDateController.text = cleaned;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Список сохраненных карт
        if (_savedCards.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Сохраненные карты:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ..._savedCards.map((card) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.credit_card, color: Colors.blue),
                    title: Text(card.maskedCardNumber),
                    subtitle: Text('Действует до: ${card.expiryDate}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _paymentService.deleteCard(card.id);
                            _loadSavedCards();
                            _clearForm();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _selectCard(card),
                        ),
                      ],
                    ),
                    onTap: () => _selectCard(card),
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
        ],

        // Форма ввода карты
        Form(
          key: _formKey,
          child: Column(
            children: [
              // Номер карты
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Номер карты *',
                  hintText: '0000 0000 0000 0000',
                  prefixIcon: Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                validator: _validateCardNumber,
                onChanged: _formatCardNumber,
                maxLength: 19, // 16 цифр + 3 пробела
              ),
              const SizedBox(height: 16),

              // Срок действия и CVV в одной строке
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _expiryDateController,
                      decoration: const InputDecoration(
                        labelText: 'Срок действия *',
                        hintText: 'MM/ГГ',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                      validator: _validateExpiryDate,
                      onChanged: _formatExpiryDate,
                      maxLength: 5,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: const InputDecoration(
                        labelText: 'CVV *',
                        hintText: '123',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      validator: _validateCvv,
                      maxLength: 4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Имя держателя карты
              TextFormField(
                controller: _cardHolderController,
                decoration: const InputDecoration(
                  labelText: 'Имя держателя карты *',
                  hintText: 'IVAN IVANOV',
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: _validateCardHolder,
              ),
              const SizedBox(height: 16),

              // Сохранить карту
              CheckboxListTile(
                title: const Text('Сохранить карту для будущих платежей'),
                value: _saveCard,
                onChanged: (value) {
                  setState(() {
                    _saveCard = value ?? false;
                  });
                },
                secondary: const Icon(Icons.save),
              ),
              const SizedBox(height: 24),

              // Кнопка оплаты
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Оплатить ${widget.amount.toStringAsFixed(2)} ₽',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              // Кнопка очистки
              TextButton(
                onPressed: _clearForm,
                child: const Text('Очистить форму'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }
}