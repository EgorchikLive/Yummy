// // lib/widgets/yookassa_payment_dialog.dart
// import 'package:flutter/material.dart';
// import 'package:yummy/services/yookassa_service.dart';

// class YooKassaPaymentDialog extends StatefulWidget {
//   final double amount;
//   final String description;
//   final VoidCallback onSuccess;
//   final VoidCallback onFailure;

//   const YooKassaPaymentDialog({
//     super.key,
//     required this.amount,
//     required this.description,
//     required this.onSuccess,
//     required this.onFailure,
//   });

//   @override
//   State<YooKassaPaymentDialog> createState() => _YooKassaPaymentDialogState();
// }

// class _YooKassaPaymentDialogState extends State<YooKassaPaymentDialog> {
//   final YooKassaService _yooKassaService = YooKassaService();
//   bool _isProcessing = false;
//   String _status = '';

//   @override
//   void initState() {
//     super.initState();
//     _processPayment();
//   }

//   Future<void> _processPayment() async {
//     setState(() {
//       _isProcessing = true;
//       _status = 'Создание платежа...';
//     });

//     try {
//       _status = 'Обработка через YooKassa...';
      
//       final success = await _yooKassaService.processYooKassaPayment(
//         amount: widget.amount,
//         description: widget.description,
//         metadata: {
//           'source': 'yummy_app',
//           'timestamp': DateTime.now().toIso8601String(),
//         },
//       );

//       if (success) {
//         _status = 'Платеж успешно завершен!';
//         await Future.delayed(const Duration(seconds: 1));
        
//         if (mounted) {
//           Navigator.pop(context);
//           widget.onSuccess();
//         }
//       } else {
//         _status = 'Платеж не прошел';
//         await Future.delayed(const Duration(seconds: 1));
        
//         if (mounted) {
//           Navigator.pop(context);
//           widget.onFailure();
//         }
//       }
//     } catch (e) {
//       _status = 'Ошибка: $e';
//       await Future.delayed(const Duration(seconds: 2));
      
//       if (mounted) {
//         Navigator.pop(context);
//         widget.onFailure();
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isProcessing = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Логотип YooKassa
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF00BFFF),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Icon(
//                 Icons.payment,
//                 color: Colors.white,
//                 size: 48,
//               ),
//             ),
            
//             const SizedBox(height: 20),
            
//             Text(
//               'Оплата через YooKassa',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
            
//             const SizedBox(height: 8),
            
//             Text(
//               '${widget.amount.toStringAsFixed(2)} ₽',
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.green,
//               ),
//             ),
            
//             const SizedBox(height: 20),
            
//             // Индикатор загрузки
//             if (_isProcessing) ...[
//               const CircularProgressIndicator(),
//               const SizedBox(height: 16),
//             ],
            
//             // Статус
//             Text(
//               _status,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: _status.contains('Ошибка') ? Colors.red : Colors.grey[700],
//                 fontSize: 16,
//               ),
//             ),
            
//             const SizedBox(height: 20),
            
//             // Демо-информация
//             if (YooKassaService.isDemoMode) ...[
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.orange.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.orange.shade200),
//                 ),
//                 child: const Column(
//                   children: [
//                     Icon(Icons.info, color: Colors.orange, size: 24),
//                     SizedBox(height: 8),
//                     Text(
//                       'Демо-режим\nПлатеж будет симулирован',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.orange,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//             ],
            
//             // Кнопка отмены
//             if (_isProcessing) 
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   widget.onFailure();
//                 },
//                 child: const Text('Отменить'),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }