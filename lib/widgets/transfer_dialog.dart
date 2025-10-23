// lib/widgets/transfer_dialog.dart
import 'package:flutter/material.dart';
import 'package:yummy/model/payment/bank_card_model.dart';
import 'package:yummy/model/payment/transfer_model.dart';
import 'package:yummy/services/transfer_service.dart';

class TransferDialog extends StatefulWidget {
  final List<BankCardModel> savedCards;

  const TransferDialog({
    super.key,
    required this.savedCards,
  });

  @override
  State<TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends State<TransferDialog> {
  final TransferService _transferService = TransferService();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _toCardController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  bool _isProcessing = false;
  BankCardModel? _selectedFromCard;
  List<BankCardModel> _mirCards = [];

  @override
  void initState() {
    super.initState();
    _loadMirCards();
  }

  void _loadMirCards() {
    _mirCards = widget.savedCards.where((card) {
      return _transferService.isMirCard(card.cardNumber);
    }).toList();
    
    if (_mirCards.isNotEmpty) {
      _selectedFromCard = _mirCards.first;
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _amountController.clear();
    _toCardController.clear();
    _descriptionController.clear();
  }

  Future<void> _processTransfer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFromCard == null) {
      _showError('Выберите карту для списания');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      
      final transfer = await _transferService.processTransfer(
        fromCard: _selectedFromCard!,
        toCardNumber: _toCardController.text.replaceAll(RegExp(r'\s+'), ''),
        amount: amount,
        description: _descriptionController.text.isNotEmpty 
            ? _descriptionController.text 
            : 'Перевод между картами МИР',
      );

      if (transfer.status == 'completed') {
        _showSuccess(transfer);
      } else {
        _showError('Перевод не выполнен');
      }
    } catch (e) {
      _showError('Ошибка перевода: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showSuccess(TransferModel transfer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Перевод выполнен'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Сумма: ${transfer.amount.toStringAsFixed(2)} ₽'),
            const SizedBox(height: 8),
            Text('С карты: ${transfer.fromCard}'),
            const SizedBox(height: 8),
            Text('На карту: ${_maskCardNumber(transfer.toCard)}'),
            const SizedBox(height: 8),
            Text('Комиссия: 0 ₽'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Закрыть алерт
              Navigator.pop(context); // Закрыть диалог перевода
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
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

  String _maskCardNumber(String cardNumber) {
    if (cardNumber.length < 16) return cardNumber;
    return '${cardNumber.substring(0, 4)} **** **** ${cardNumber.substring(12)}';
  }

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
    
    _toCardController.value = _toCardController.value.copyWith(
      text: groups.join(' '),
      selection: TextSelection.collapsed(offset: groups.join(' ').length),
    );
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите сумму';
    }
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Сумма должна быть больше 0';
    }
    if (amount > 50000) {
      return 'Максимальная сумма перевода 50,000 ₽';
    }
    return null;
  }

  String? _validateToCard(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите номер карты получателя';
    }
    final cleaned = value.replaceAll(RegExp(r'\s+'), '');
    if (!_transferService.validateRecipientCard(cleaned)) {
      return 'Неверный номер карты';
    }
    if (!_transferService.isMirCard(cleaned)) {
      return 'Карта получателя должна быть картой МИР';
    }
    if (_selectedFromCard != null && 
        !_transferService.areCardsDifferent(_selectedFromCard!.cardNumber, cleaned)) {
      return 'Нельзя переводить на ту же карту';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Перевод между картами МИР',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _isProcessing ? null : () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              const Text(
                'Бесплатные переводы между картами платежной системы МИР',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 24),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Выбор карты списания
                    if (_mirCards.isNotEmpty) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Списать с карты:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<BankCardModel>(
                            value: _selectedFromCard,
                            items: _mirCards.map((card) {
                              return DropdownMenuItem(
                                value: card,
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/mir_logo.png', // Добавьте логотип МИР
                                      width: 24,
                                      height: 24,
                                      errorBuilder: (_, __, ___) => 
                                          const Icon(Icons.credit_card, color: Colors.red),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(card.maskedCardNumber),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: _isProcessing ? null : (card) {
                              setState(() {
                                _selectedFromCard = card;
                              });
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.credit_card),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Карта получателя
                    TextFormField(
                      controller: _toCardController,
                      decoration: const InputDecoration(
                        labelText: 'Карта получателя *',
                        hintText: '0000 0000 0000 0000',
                        prefixIcon: Icon(Icons.credit_card),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: _validateToCard,
                      onChanged: _formatCardNumber,
                      maxLength: 19,
                      enabled: !_isProcessing,
                    ),
                    const SizedBox(height: 16),

                    // Сумма перевода
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Сумма перевода *',
                        hintText: '1000',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                        suffixText: '₽',
                      ),
                      keyboardType: TextInputType.number,
                      validator: _validateAmount,
                      enabled: !_isProcessing,
                    ),
                    const SizedBox(height: 8),
                    
                    // Информация о комиссии
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade100),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info, color: Colors.green, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Переводы между картами МИР бесплатны',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Описание перевода
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Описание перевода',
                        hintText: 'Например: Перевод другу',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                      ),
                      maxLength: 50,
                      enabled: !_isProcessing,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Кнопки действий
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isProcessing ? null : () {
                        Navigator.pop(context);
                      },
                      child: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _processTransfer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007BFF), // Синий цвет МИР
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
                          : const Text(
                              'Перевести',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
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
  }

  @override
  void dispose() {
    _amountController.dispose();
    _toCardController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}