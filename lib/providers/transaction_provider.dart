// lib/providers/transaction_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      print('💳 Harcama verisi yükleniyor...');
      final prefs = await SharedPreferences.getInstance();
      final String? transactionsJson = prefs.getString('transactions');
      
      if (transactionsJson != null) {
        final List<dynamic> data = jsonDecode(transactionsJson);
        _transactions = data.map((e) => Transaction.fromJson(e)).toList();
        
        // ✅ Tarihe göre sırala (en yeni önce)
        _transactions.sort((a, b) => b.date.compareTo(a.date));
        
        print('✅ ${_transactions.length} harcama yüklendi');
      } else {
        print('⚠️ Harcama verisi bulunamadı');
      }
    } catch (e) {
      print('❌ Harcama yükleme hatası: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(String description, double amount, String cardId, int installmentCount, DateTime date) async {
    try {
      print('➕ Yeni harcama ekleniyor: $description - ${amount} TL');
      final newTransaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: description,
        amount: amount,
        installmentCount: installmentCount,
        cardId: cardId,
        date: date,
        dueDate: installmentCount > 1 
          ? DateTime.now().add(Duration(days: 30 * installmentCount)) 
          : null,
      );
      _transactions.add(newTransaction);
      await _saveTransactions();
      print('✅ Harcama kaydedildi: ${_transactions.length} harcama');
      notifyListeners();
    } catch (e) {
      print('❌ Harcama ekleme hatası: $e');
    }
  }

  Future<void> updateTransaction(String id, String description, double amount, String cardId, int installmentCount, DateTime date) async {
    try {
      print('✏️ Harcama güncelleniyor: $id');
      final index = _transactions.indexWhere((t) => t.id == id);
      if (index != -1) {
        _transactions[index] = Transaction(
          id: id,
          description: description,
          amount: amount,
          installmentCount: installmentCount,
          cardId: cardId,
          date: date,
          dueDate: installmentCount > 1 
            ? DateTime.now().add(Duration(days: 30 * installmentCount)) 
            : null,
        );
        await _saveTransactions();
        print('✅ Harcama güncellendi');
        notifyListeners();
      }
    } catch (e) {
      print('❌ Harcama güncelleme hatası: $e');
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      print('🗑️ Harcama siliniyor: $id');
      _transactions.removeWhere((t) => t.id == id);
      await _saveTransactions();
      print('✅ Harcama silindi: ${_transactions.length} harcama kaldı');
      notifyListeners();
    } catch (e) {
      print('❌ Harcama silme hatası: $e');
    }
  }

  Future<void> _saveTransactions() async {
    try {
      print('💾 Harcama verisi kaydediliyor...');
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> data = _transactions.map((t) => t.toJson()).toList();
      await prefs.setString('transactions', jsonEncode(data));
      print('✅ Harcama verisi kaydedildi');
    } catch (e) {
      print('❌ Harcama kaydetme hatası: $e');
    }
  }
}