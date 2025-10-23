class TransferModel {
  final String id;
  final String fromCard;
  final String toCard;
  final double amount;
  final String description;
  final DateTime createdAt;
  final String status;

  TransferModel({
    required this.id,
    required this.fromCard,
    required this.toCard,
    required this.amount,
    required this.description,
    required this.createdAt,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromCard': fromCard,
      'toCard': toCard,
      'amount': amount,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  factory TransferModel.fromJson(Map<String, dynamic> json) {
    return TransferModel(
      id: json['id'],
      fromCard: json['fromCard'],
      toCard: json['toCard'],
      amount: json['amount'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'],
    );
  }
}