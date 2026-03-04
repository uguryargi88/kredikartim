import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String cardName;

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.cardName,
  });
}

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 0;

  @override
  Transaction read(BinaryReader reader) {
    final fields = reader.readFieldCount();
    final id = reader.readString();
    final description = reader.readString();
    final amount = reader.readDouble();
    final date = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final cardName = reader.readString();
    return Transaction(
      id: id,
      description: description,
      amount: amount,
      date: date,
      cardName: cardName,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer.writeFieldCount(5);
    writer.writeString(obj.id);
    writer.writeString(obj.description);
    writer.writeDouble(obj.amount);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeString(obj.cardName);
  }
}