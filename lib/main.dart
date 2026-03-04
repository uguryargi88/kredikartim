// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/card_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Provider'ları oluştur
  final cardProvider = CardProvider();
  final transactionProvider = TransactionProvider();
  
  // Verileri yükle
  await cardProvider.loadCards();
  await transactionProvider.loadTransactions();
  
  // ✅ Veri Kalıcılığı Testi (Debug Log)
  print('🚀 =========================================');
  print('🚀 Uygulama Başlatıldı - V1.0');
  print('🚀 =========================================');
  print('📦 Kart Sayısı: ${cardProvider.cards.length}');
  print('💳 Harcama Sayısı: ${transactionProvider.transactions.length}');
  
  if (cardProvider.cards.isNotEmpty) {
    print('✅ İlk Kart: ${cardProvider.cards.first.bankName}');
    print('   Limit: ${cardProvider.cards.first.limit} TL');
    print('   Kullanılan: ${cardProvider.cards.first.usedAmount} TL');
  } else {
    print('⚠️ Kart verisi bulunamadı - Veri kalıcılığı testi');
  }
  
  if (transactionProvider.transactions.isNotEmpty) {
    print('✅ İlk Harcama: ${transactionProvider.transactions.first.description}');
    print('   Tutar: ${transactionProvider.transactions.first.amount} TL');
    print('   Taksit: ${transactionProvider.transactions.first.installmentCount}');
  } else {
    print('⚠️ Harcama verisi bulunamadı - Veri kalıcılığı testi');
  }
  
  print('🚀 =========================================');
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => cardProvider),
        ChangeNotifierProvider(create: (_) => transactionProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KrediKartım',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}