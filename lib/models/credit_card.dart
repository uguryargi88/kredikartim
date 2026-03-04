// lib/models/credit_card.dart
class CreditCard {
  final String id;
  String bankName;
  String cardNumber;
  double limit;
  double usedAmount;
  final int statementDay;
  final DateTime createdAt;
  final DateTime paymentDueDate;

  CreditCard({
    required this.id,
    required this.bankName,
    required this.cardNumber,
    required this.limit,
    required this.usedAmount,
    required this.statementDay,
    required this.createdAt,
    required this.paymentDueDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bankName': bankName,
      'cardNumber': cardNumber,
      'limit': limit,
      'usedAmount': usedAmount,
      'statementDay': statementDay,
      'createdAt': createdAt.toIso8601String(),
      'paymentDueDate': paymentDueDate.toIso8601String(),
    };
  }

  factory CreditCard.fromJson(Map<String, dynamic> json) {
    return CreditCard(
      id: json['id'],
      bankName: json['bankName'],
      cardNumber: json['cardNumber'],
      limit: json['limit'],
      usedAmount: json['usedAmount'],
      statementDay: json['statementDay'],
      createdAt: DateTime.parse(json['createdAt']),
      paymentDueDate: json['paymentDueDate'] != null 
          ? DateTime.parse(json['paymentDueDate']) 
          : DateTime.now().add(const Duration(days: 30)),
    );
  }

  CreditCard copyWith({
    String? id,
    String? bankName,
    String? cardNumber,
    double? limit,
    double? usedAmount,
    int? statementDay,
    DateTime? createdAt,
    DateTime? paymentDueDate,
  }) {
    return CreditCard(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      cardNumber: cardNumber ?? this.cardNumber,
      limit: limit ?? this.limit,
      usedAmount: usedAmount ?? this.usedAmount,
      statementDay: statementDay ?? this.statementDay,
      createdAt: createdAt ?? this.createdAt,
      paymentDueDate: paymentDueDate ?? this.paymentDueDate,
    );
  }
}