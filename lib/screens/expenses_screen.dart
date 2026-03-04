import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/card_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/credit_card.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harcamalarım'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer2<CardProvider, TransactionProvider>(
        builder: (context, cardProvider, transactionProvider, child) {
          if (transactionProvider.transactions.isEmpty) {
            return const Center(
              child: Text('Henüz harcama eklemediniz.'),
            );
          }
          return ListView.builder(
            itemCount: transactionProvider.transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactionProvider.transactions[index];
              final card = cardProvider.cards.firstWhere(
                (c) => c.id == transaction.cardId,
                orElse: () => CreditCard(
                  id: '',
                  bankName: 'Bilinmeyen',
                  cardNumber: '****',
                  limit: 0,
                  usedAmount: 0,
                  statementDay: 0,
                  createdAt: DateTime.now(),
                ),
              );

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Text(transaction.installmentCount > 1 ? '₺' : '₺'),
                  ),
                  title: Text(transaction.description),
                  subtitle: Text(
                    '${card.bankName} • ${DateFormat('dd/MM/yyyy').format(transaction.date)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(transaction.amount / transaction.installmentCount).toStringAsFixed(2)} TL',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                      if (transaction.installmentCount > 1)
                        Text('${transaction.installmentCount} Taksit'),
                    ],
                  ),
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Sil'),
                        content: const Text('Bu harcamayı silmek istiyor musunuz?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('İptal'),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<TransactionProvider>().deleteTransaction(transaction.id);
                              Navigator.pop(ctx);
                            },
                            child: const Text('Sil', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final installmentController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (ctx) => Consumer<CardProvider>(
        builder: (context, cardProvider, child) {
          if (cardProvider.cards.isEmpty) {
            return AlertDialog(
              title: const Text('Hata'),
              content: const Text('Önce kart eklemeniz gerekiyor.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Tamam'),
                ),
              ],
            );
          }

          String? selectedCardId;

          return AlertDialog(
            title: const Text('Yeni Harcama Ekle'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Açıklama'),
                ),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Tutar (TL)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: installmentController,
                  decoration: const InputDecoration(labelText: 'Taksit Sayısı'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Kart Seçin'),
                  value: selectedCardId,
                  items: cardProvider.cards.map((card) {
                    return DropdownMenuItem(
                      value: card.id,
                      child: Text('${card.bankName} - ${card.cardNumber.substring(card.cardNumber.length - 4)}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedCardId = value;
                  },
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
                  if (descriptionController.text.isNotEmpty && 
                      amountController.text.isNotEmpty && 
                      installmentController.text.isNotEmpty &&
                      selectedCardId != null) {
                    context.read<TransactionProvider>().addTransaction(
                      descriptionController.text,
                      double.parse(amountController.text),
                      selectedCardId!,
                      int.parse(installmentController.text),
                    );
                    context.read<CardProvider>().updateCardUsedAmount(
                      selectedCardId!,
                      double.parse(amountController.text),
                    );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Kaydet'),
              ),
            ],
          );
        },
      ),
    );
  }
}