class CreditCard {
  final String id;
  String bankName;
  String cardNumber;
  double limit;
  double usedAmount;
  final int statementDay;
  final DateTime createdAt;

  CreditCard({
    required this.id,
    required this.bankName,
    required this.cardNumber,
    required this.limit,
    required this.usedAmount,
    required this.statementDay,
    required this.createdAt,
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
    );
  }

  // Kopya oluşturma metodu
  CreditCard copyWith({
    String? id,
    String? bankName,
    String? cardNumber,
    double? limit,
    double? usedAmount,
    int? statementDay,
    DateTime? createdAt,
  }) {
    return CreditCard(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      cardNumber: cardNumber ?? this.cardNumber,
      limit: limit ?? this.limit,
      usedAmount: usedAmount ?? this.usedAmount,
      statementDay: statementDay ?? this.statementDay,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}