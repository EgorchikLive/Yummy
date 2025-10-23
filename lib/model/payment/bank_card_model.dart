class BankCardModel {
  final String id;
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String cardHolder;
  final bool isSaved;
  final DateTime? createdAt;

  BankCardModel({
    required this.id,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.cardHolder,
    this.isSaved = false,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardNumber': cardNumber,
      'expiryDate': expiryDate,
      'cvv': cvv,
      'cardHolder': cardHolder,
      'isSaved': isSaved,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory BankCardModel.fromJson(Map<String, dynamic> json) {
    return BankCardModel(
      id: json['id'],
      cardNumber: json['cardNumber'],
      expiryDate: json['expiryDate'],
      cvv: json['cvv'],
      cardHolder: json['cardHolder'],
      isSaved: json['isSaved'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  String get maskedCardNumber {
    if (cardNumber.length < 16) return cardNumber;
    return '${cardNumber.substring(0, 4)} **** **** ${cardNumber.substring(12)}';
  }
}