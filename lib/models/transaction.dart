class Transaction {
  final String id;
  final String description;
  final double amount;
  final int installmentCount;
  final String cardId;
  final DateTime date;
  final DateTime? dueDate;

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.installmentCount,
    required this.cardId,
    required this.date,
    this.dueDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'installmentCount': installmentCount,
      'cardId': cardId,
      'date': date.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      description: json['description'],
      amount: json['amount'],
      installmentCount: json['installmentCount'],
      cardId: json['cardId'],
      date: DateTime.parse(json['date']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    );
  }
}