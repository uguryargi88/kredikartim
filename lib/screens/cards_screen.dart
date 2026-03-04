import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/card_provider.dart';
import '../models/credit_card.dart';

class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kartlarım'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<CardProvider>(
        builder: (context, provider, child) {
          if (provider.cards.isEmpty) {
            return const Center(
              child: Text('Henüz kart eklemediniz.'),
            );
          }
          return ListView.builder(
            itemCount: provider.cards.length,
            itemBuilder: (context, index) {
              final card = provider.cards[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Text(card.bankName[0]),
                  ),
                  title: Text(card.bankName),
                  subtitle: Text('Son 4 Hane: ${card.cardNumber.substring(card.cardNumber.length - 4)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteDialog(context, card.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCardDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCardDialog(BuildContext context) {
    final bankController = TextEditingController();
    final cardController = TextEditingController();
    final limitController = TextEditingController();
    final statementController = TextEditingController(text: '15');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yeni Kart Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: bankController,
              decoration: const InputDecoration(labelText: 'Banka Adı'),
            ),
            TextField(
              controller: cardController,
              decoration: const InputDecoration(labelText: 'Kart Numarası'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: limitController,
              decoration: const InputDecoration(labelText: 'Limit (TL)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: statementController,
              decoration: const InputDecoration(labelText: 'Hesap Kesim Tarihi (Gün)'),
              keyboardType: TextInputType.number,
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
              if (bankController.text.isNotEmpty && 
                  cardController.text.isNotEmpty && 
                  limitController.text.isNotEmpty) {
                context.read<CardProvider>().addCard(
                  bankController.text,
                  cardController.text,
                  double.parse(limitController.text),
                  int.parse(statementController.text),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String cardId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sil'),
        content: const Text('Bu kartı silmek istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              context.read<CardProvider>().deleteCard(cardId);
              Navigator.pop(ctx);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}