import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/card_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final cardProvider = CardProvider();
  final transactionProvider = TransactionProvider();
  
  await cardProvider.loadCards();
  await transactionProvider.loadTransactions();
  
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