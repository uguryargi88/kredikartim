// lib/widgets/debt_forecast_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/card_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/credit_card.dart';
import '../models/transaction.dart';

class MonthlyForecast {
  final DateTime month;
  final double totalAmount;
  final Map<String, double> cardBreakdown;

  MonthlyForecast({
    required this.month,
    required this.totalAmount,
    required this.cardBreakdown,
  });
}

class DebtForecastChart extends StatelessWidget {
  const DebtForecastChart({super.key});

  List<MonthlyForecast> _calculate6MonthForecast(
    List<CreditCard> cards,
    List<Transaction> transactions,
  ) {
    List<MonthlyForecast> forecast = [];
    DateTime currentMonth = DateTime.now();

    for (int i = 0; i < 6; i++) {
      DateTime targetMonth = DateTime(currentMonth.year, currentMonth.month + i);
      double total = 0;
      Map<String, double> cardBreakdown = {};

      // Mevcut kart borçlarını ekle
      for (var card in cards) {
        if (card.usedAmount > 0) {
          // Ekstre tarihine göre ayda mı yoksa dağıtık mı?
          if (card.statementDay <= targetMonth.day) {
            total += card.usedAmount;
            cardBreakdown[card.id] = (cardBreakdown[card.id] ?? 0) + card.usedAmount;
          }
        }
      }

      // Taksitli harcamaları ekle
      for (var transaction in transactions) {
        if (transaction.installmentCount > 1) {
          double monthlyPayment = transaction.amount / transaction.installmentCount;
          // Taksit hangi aya denk geliyor?
          int monthsSinceTransaction = (targetMonth.year - transaction.date.year) * 12 + 
                                       (targetMonth.month - transaction.date.month);
          
          if (monthsSinceTransaction >= 0 && monthsSinceTransaction < transaction.installmentCount) {
            total += monthlyPayment;
            cardBreakdown[transaction.cardId] = (cardBreakdown[transaction.cardId] ?? 0) + monthlyPayment;
          }
        }
      }

      forecast.add(MonthlyForecast(
        month: targetMonth,
        totalAmount: total,
        cardBreakdown: cardBreakdown,
      ));
    }

    return forecast;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CardProvider, TransactionProvider>(
      builder: (context, cardProvider, transactionProvider, child) {
        final forecast = _calculate6MonthForecast(cardProvider.cards, transactionProvider.transactions);
        
        if (forecast.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Henüz veri yok'),
          );
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📊 Önümüzdeki 6 Ay Borç Tahmini',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: forecast.map((f) => f.totalAmount).fold(0.0, (max, val) => val > max ? val : max) * 1.2,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final month = forecast[groupIndex].month;
                            final amount = forecast[groupIndex].totalAmount;
                            return BarTooltipItem(
                              '${DateFormat('MMM yyyy').format(month)}\n',
                              const TextStyle(color: Colors.white, fontSize: 12),
                              children: [
                                TextSpan(
                                  text: '₺${amount.toStringAsFixed(0)}',
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 && value.toInt() < forecast.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    DateFormat('MMM').format(forecast[value.toInt()].month),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: true),
                      barGroups: forecast.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: data.totalAmount,
                              color: Colors.blue,
                              width: 20,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}