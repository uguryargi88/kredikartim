import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/card_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/credit_card.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Özet'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer2<CardProvider, TransactionProvider>(
        builder: (context, cardProvider, transactionProvider, child) {
          final totalLimit = cardProvider.cards.fold(0.0, (sum, card) => sum + card.limit);
          final totalUsed = cardProvider.cards.fold(0.0, (sum, card) => sum + card.usedAmount);
          final totalExpenses = transactionProvider.transactions.fold(0.0, (sum, t) => sum + t.amount);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(
                  context,
                  'Toplam Limit',
                  '${totalLimit.toStringAsFixed(2)} TL',
                  Icons.account_balance_wallet,
                  Colors.green,
                ),
                const SizedBox(height: 16),
                _buildSummaryCard(
                  context,
                  'Kullanılan Limit',
                  '${totalUsed.toStringAsFixed(2)} TL',
                  Icons.money,
                  Colors.orange,
                ),
                const SizedBox(height: 16),
                _buildSummaryCard(
                  context,
                  'Toplam Harcama',
                  '${totalExpenses.toStringAsFixed(2)} TL',
                  Icons.receipt_long,
                  Colors.red,
                ),
                const SizedBox(height: 24),
                const Text('Kartlarım', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...cardProvider.cards.map((card) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Text(card.bankName[0]),
                    ),
                    title: Text(card.bankName),
                    subtitle: Text('Son 4 Hane: ${card.cardNumber.substring(card.cardNumber.length - 4)}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${card.usedAmount.toStringAsFixed(2)} TL'),
                        Text('${((card.usedAmount / card.limit) * 100).toStringAsFixed(0)}%'),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}