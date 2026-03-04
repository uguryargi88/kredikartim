import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/credit_card.dart';

class CardProvider extends ChangeNotifier {
  List<CreditCard> _cards = [];

  List<CreditCard> get cards => _cards;

  Future<void> loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cardsJson = prefs.getString('cards');
    
    if (cardsJson != null) {
      final List<dynamic> data = jsonDecode(cardsJson);
      _cards = data.map((e) => CreditCard.fromJson(e)).toList();
    }
    notifyListeners();
  }

  Future<void> addCard(String bankName, String cardNumber, double limit, int statementDay) async {
    final newCard = CreditCard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bankName: bankName,
      cardNumber: cardNumber,
      limit: limit,
      usedAmount: 0,
      statementDay: statementDay,
      createdAt: DateTime.now(),
    );
    _cards.add(newCard);
    await _saveCards();
    notifyListeners();
  }

  Future<void> updateCardUsedAmount(String cardId, double amount) async {
    final index = _cards.indexWhere((c) => c.id == cardId);
    if (index != -1) {
      _cards[index] = _cards[index].copyWith(
        usedAmount: _cards[index].usedAmount + amount,
      );
      await _saveCards();
      notifyListeners();
    }
  }

  Future<void> deleteCard(String id) async {
    _cards.removeWhere((c) => c.id == id);
    await _saveCards();
    notifyListeners();
  }

  Future<void> _saveCards() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> data = _cards.map((c) => c.toJson()).toList();
    await prefs.setString('cards', jsonEncode(data));
  }
}