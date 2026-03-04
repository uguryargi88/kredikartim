import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  Future<void> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? transactionsJson = prefs.getString('transactions');
    
    if (transactionsJson != null) {
      final List<dynamic> data = jsonDecode(transactionsJson);
      _transactions = data.map((e) => Transaction.fromJson(e)).toList();
    }
    notifyListeners();
  }

  Future<void> addTransaction(String description, double amount, String cardId, int installmentCount) async {
    final newTransaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: description,
      amount: amount,
      installmentCount: installmentCount,
      cardId: cardId,
      date: DateTime.now(),
      dueDate: installmentCount > 1 
        ? DateTime.now().add(Duration(days: 30 * installmentCount)) 
        : null,
    );
    _transactions.add(newTransaction);
    await _saveTransactions();
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _saveTransactions();
    notifyListeners();
  }

  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> data = _transactions.map((t) => t.toJson()).toList();
    await prefs.setString('transactions', jsonEncode(data));
  }
}