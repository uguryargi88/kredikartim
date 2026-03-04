import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/services.dart'; // Clipboard için bu import gerekli
import '../providers/card_provider.dart';
import '../providers/transaction_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Veri Yönetimi
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Veri Yönetimi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.backup),
                    title: const Text('Verileri Yedekle'),
                    subtitle: const Text('JSON formatında dışa aktar'),
                    onTap: () => _exportData(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.restore),
                    title: const Text('Verileri Geri Yükle'),
                    subtitle: const Text('JSON formatından içe aktar'),
                    onTap: () => _importData(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Tüm Verileri Sil'),
                    subtitle: const Text('Uygulama verilerini sıfırla'),
                    onTap: () => _resetData(context),
                    tileColor: Colors.red.withOpacity(0.1),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Hakkında
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hakkında',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('Uygulama Sürümü'),
                    subtitle: const Text('1.0.0'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('Gizlilik Politikası'),
                    subtitle: const Text('Verileriniz sadece cihazınızda saklanır'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _exportData(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final cards = prefs.getString('cards') ?? '[]';
    final transactions = prefs.getString('transactions') ?? '[]';

    final data = {
      'cards': cards,
      'transactions': transactions,
      'exportDate': DateTime.now().toIso8601String(),
    };

    final jsonString = jsonEncode(data);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Veri Yedekleme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Verileriniz aşağıda kopyalandı:'),
            const SizedBox(height: 8),
            TextField(
              maxLines: 10,
              readOnly: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(8),
              ),
              controller: TextEditingController(text: jsonString),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonString));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Veriler panoya kopyalandı!')),
              );
            },
            child: const Text('Kopyala'),
          ),
        ],
      ),
    );
  }

  void _importData(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Veri Geri Yükleme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Yedek JSON verisini yapıştırın:'),
            const SizedBox(height: 8),
            TextField(
              maxLines: 10,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(8),
              ),
              controller: TextEditingController(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Geri yükleme özelliği yakında eklenecek!')),
              );
            },
            child: const Text('Geri Yükle'),
          ),
        ],
      ),
    );
  }

  void _resetData(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tüm Verileri Sil'),
        content: const Text('Tüm kart ve harcama verileriniz silinecek. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('cards');
              await prefs.remove('transactions');
              Navigator.pop(ctx);
              context.read<CardProvider>().loadCards();
              context.read<TransactionProvider>().loadTransactions();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Veriler silindi!')),
              );
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}