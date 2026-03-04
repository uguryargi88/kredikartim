// lib/screens/expenses_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/card_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/credit_card.dart';
import '../models/transaction.dart';

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
                  statementDay: 15,
                  createdAt: DateTime.now(),
                  paymentDueDate: DateTime.now().add(const Duration(days: 30)),
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
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
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _showEditTransactionDialog(context, transaction, cardProvider),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteDialog(context, transaction.id),
                      ),
                    ],
                  ),
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
    DateTime selectedDate = DateTime.now();

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
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Harcama Tarihi'),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      selectedDate = picked;
                    }
                  },
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
                      selectedDate,
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

  void _showEditTransactionDialog(BuildContext context, Transaction transaction, CardProvider cardProvider) {
    final descriptionController = TextEditingController(text: transaction.description);
    final amountController = TextEditingController(text: transaction.amount.toString());
    final installmentController = TextEditingController(text: transaction.installmentCount.toString());
    DateTime selectedDate = transaction.date;

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

          String? selectedCardId = transaction.cardId;

          return AlertDialog(
            title: const Text('Harcama Düzenle'),
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
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Harcama Tarihi'),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      selectedDate = picked;
                    }
                  },
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
                    context.read<TransactionProvider>().updateTransaction(
                      transaction.id,
                      descriptionController.text,
                      double.parse(amountController.text),
                      selectedCardId!,
                      int.parse(installmentController.text),
                      selectedDate,
                    );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Güncelle'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String transactionId) {
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
              context.read<TransactionProvider>().deleteTransaction(transactionId);
              Navigator.pop(ctx);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}