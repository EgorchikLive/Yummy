// // lib/widgets/payment_selection_dialog.dart
// import 'package:flutter/material.dart';
// import 'package:yummy/widgets/payment_dialog.dart';
// import 'package:yummy/widgets/yookassa_payment_dialog.dart';

// class PaymentSelectionDialog extends StatelessWidget {
//   final double amount;
//   final String description;
//   final VoidCallback onSuccess;
//   final VoidCallback onFailure;

//   const PaymentSelectionDialog({
//     super.key,
//     required this.amount,
//     required this.description,
//     required this.onSuccess,
//     required this.onFailure,
//   });

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
//             Text(
//               'Выберите способ оплаты',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
            
//             const SizedBox(height: 24),
            
//             // Кнопка оплаты картой
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   showDialog(
//                     context: context,
//                     barrierDismissible: false,
//                     builder: (context) => PaymentDialog(
//                       amount: amount,
//                       description: description,
//                       onSuccess: onSuccess,
//                       onFailure: onFailure,
//                     ),
//                   );
//                 },
//                 icon: const Icon(Icons.credit_card),
//                 label: const Text('Банковская карта'),
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   backgroundColor: Colors.blue,
//                 ),
//               ),
//             ),
            
//             const SizedBox(height: 12),
            
//             // Кнопка оплаты через YooKassa
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   showDialog(
//                     context: context,
//                     barrierDismissible: false,
//                     builder: (context) => YooKassaPaymentDialog(
//                       amount: amount,
//                       description: description,
//                       onSuccess: onSuccess,
//                       onFailure: onFailure,
//                     ),
//                   );
//                 },
//                 icon: Image.asset(
//                   'assets/yookassa_logo.png',
//                   width: 24,
//                   height: 24,
//                   errorBuilder: (_, __, ___) => 
//                       const Icon(Icons.payment, color: Colors.white),
//                 ),
//                 label: const Text('YooKassa'),
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   backgroundColor: const Color(0xFF00BFFF),
//                 ),
//               ),
//             ),
            
//             const SizedBox(height: 16),
            
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 onFailure();
//               },
//               child: const Text('Отмена'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }