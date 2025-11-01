// lib/model/payment/yookassa_payment_model.dart
class YooKassaPaymentModel {
  final String id;
  final String status;
  final double amount;
  final String currency;
  final String? paymentMethodId;
  final String? confirmationUrl;
  final DateTime createdAt;
  final String? description;
  final Map<String, dynamic>? metadata;

  YooKassaPaymentModel({
    required this.id,
    required this.status,
    required this.amount,
    this.currency = 'RUB',
    this.paymentMethodId,
    this.confirmationUrl,
    required this.createdAt,
    this.description,
    this.metadata,
  });

  factory YooKassaPaymentModel.fromJson(Map<String, dynamic> json) {
    return YooKassaPaymentModel(
      id: json['id'],
      status: json['status'],
      amount: double.parse(json['amount']['value'].toString()),
      currency: json['amount']['currency'],
      paymentMethodId: json['payment_method_id'],
      confirmationUrl: json['confirmation']?['confirmation_url'],
      createdAt: DateTime.parse(json['created_at']),
      description: json['description'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'amount': {
        'value': amount.toStringAsFixed(2),
        'currency': currency,
      },
      'payment_method_id': paymentMethodId,
      'confirmation': confirmationUrl != null
          ? {'confirmation_url': confirmationUrl}
          : null,
      'created_at': createdAt.toIso8601String(),
      'description': description,
      'metadata': metadata,
    };
  }
}