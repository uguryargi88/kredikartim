// lib/providers/card_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/credit_card.dart';

class CardProvider extends ChangeNotifier {
  List<CreditCard> _cards = [];
  bool _isLoading = false;

  List<CreditCard> get cards => _cards;
  bool get isLoading => _isLoading;

  Future<void> loadCards() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      print('📦 Kart verisi yükleniyor...');
      final prefs = await SharedPreferences.getInstance();
      final String? cardsJson = prefs.getString('cards');
      
      if (cardsJson != null) {
        final List<dynamic> data = jsonDecode(cardsJson);
        _cards = data.map((e) => CreditCard.fromJson(e)).toList();
        print('✅ ${_cards.length} kart yüklendi');
      } else {
        print('⚠️ Kart verisi bulunamadı');
      }
    } catch (e) {
      print('❌ Kart yükleme hatası: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCard(String bankName, String cardNumber, double limit, int statementDay, DateTime paymentDueDate) async {
    try {
      print('➕ Yeni kart ekleniyor: $bankName');
      final newCard = CreditCard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        bankName: bankName,
        cardNumber: cardNumber,
        limit: limit,
        usedAmount: 0,
        statementDay: statementDay,
        createdAt: DateTime.now(),
        paymentDueDate: paymentDueDate,
      );
      _cards.add(newCard);
      await _saveCards();
      print('✅ Kart kaydedildi: ${_cards.length} kart');
      notifyListeners();
    } catch (e) {
      print('❌ Kart ekleme hatası: $e');
    }
  }

  Future<void> updateCard(String id, String bankName, String cardNumber, double limit, int statementDay, DateTime paymentDueDate) async {
    try {
      print('✏️ Kart güncelleniyor: $id');
      final index = _cards.indexWhere((c) => c.id == id);
      if (index != -1) {
        _cards[index] = CreditCard(
          id: id,
          bankName: bankName,
          cardNumber: cardNumber,
          limit: limit,
          usedAmount: _cards[index].usedAmount,
          statementDay: statementDay,
          createdAt: _cards[index].createdAt,
          paymentDueDate: paymentDueDate,
        );
        await _saveCards();
        print('✅ Kart güncellendi');
        notifyListeners();
      }
    } catch (e) {
      print('❌ Kart güncelleme hatası: $e');
    }
  }

  Future<void> updateCardUsedAmount(String cardId, double amount) async {
    try {
      final index = _cards.indexWhere((c) => c.id == cardId);
      if (index != -1) {
        _cards[index] = _cards[index].copyWith(
          usedAmount: _cards[index].usedAmount + amount,
        );
        await _saveCards();
        print('✅ Kart kullanımı güncellendi: ${_cards[index].usedAmount} TL');
        notifyListeners();
      }
    } catch (e) {
      print('❌ Kart güncelleme hatası: $e');
    }
  }

  Future<void> deleteCard(String id) async {
    try {
      print('🗑️ Kart siliniyor: $id');
      _cards.removeWhere((c) => c.id == id);
      await _saveCards();
      print('✅ Kart silindi: ${_cards.length} kart kaldı');
      notifyListeners();
    } catch (e) {
      print('❌ Kart silme hatası: $e');
    }
  }

  // ✅ Yaklaşan Ödeme Tarihi Olan Kartları Getir
  List<CreditCard> getCardsWithUpcomingPayment(int daysAhead) {
    final now = DateTime.now();
    final upcomingCards = _cards.where((card) {
      final daysUntilPayment = card.paymentDueDate.difference(now).inDays;
      return daysUntilPayment >= 0 && daysUntilPayment <= daysAhead;
    }).toList();
    
    // Ödeme tarihi yakına göre sırala
    upcomingCards.sort((a, b) => a.paymentDueDate.compareTo(b.paymentDueDate));
    
    return upcomingCards;
  }

  Future<void> _saveCards() async {
    try {
      print('💾 Kart verisi kaydediliyor...');
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> data = _cards.map((c) => c.toJson()).toList();
      await prefs.setString('cards', jsonEncode(data));
      print('✅ Kart verisi kaydedildi');
    } catch (e) {
      print('❌ Kart kaydetme hatası: $e');
    }
  }
}