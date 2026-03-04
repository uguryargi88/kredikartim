// lib/screens/summary_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/card_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/credit_card.dart';
import '../models/transaction.dart';
import '../widgets/debt_forecast_chart.dart';

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
          final upcomingCards = cardProvider.getCardsWithUpcomingPayment(7);
          final recentTransactions = transactionProvider.transactions.take(5).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 6 Aylık Borç Tahmin Grafiği
                const DebtForecastChart(),
                const SizedBox(height: 16),

                // Önemli Uyarılar (Yaklaşan Ödemeler)
                if (upcomingCards.isNotEmpty) ...[
                  Card(
                    color: Colors.orange.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.warning, color: Colors.orange),
                              SizedBox(width: 8),
                              Text(
                                '⚠️ Yaklaşan Ödemeler',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...upcomingCards.map((card) {
                            final daysUntil = card.paymentDueDate.difference(DateTime.now()).inDays;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                '• ${card.bankName} - ₺${card.usedAmount.toStringAsFixed(0)} - ${DateFormat('dd/MM/yyyy').format(card.paymentDueDate)} (${daysUntil} gün)',
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Toplam Limit Kartı
                _buildSummaryCard(
                  context,
                  'Toplam Limit',
                  '${totalLimit.toStringAsFixed(2)} TL',
                  Icons.account_balance_wallet,
                  Colors.green,
                ),
                const SizedBox(height: 16),

                // Kullanılan Limit Kartı
                _buildSummaryCard(
                  context,
                  'Kullanılan Limit',
                  '${totalUsed.toStringAsFixed(2)} TL',
                  Icons.money,
                  Colors.orange,
                ),
                const SizedBox(height: 16),

                // Toplam Harcama Kartı
                _buildSummaryCard(
                  context,
                  'Toplam Harcama',
                  '${totalExpenses.toStringAsFixed(2)} TL',
                  Icons.receipt_long,
                  Colors.red,
                ),
                const SizedBox(height: 24),

                // Son 5 Harcama
                const Text('📋 Son 5 Harcama', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (recentTransactions.isEmpty)
                  const Text('Henüz harcama yok')
                else
                  ...recentTransactions.map((transaction) {
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
                      margin: const EdgeInsets.only(bottom: 8),
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
                        trailing: Text(
                          '${(transaction.amount / transaction.installmentCount).toStringAsFixed(2)} TL',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 16),

                // Kart Listesi
                const Text('📇 Kartlarım', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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