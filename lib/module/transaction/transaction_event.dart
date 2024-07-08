import 'package:equatable/equatable.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {}

class AddTransaction extends TransactionEvent {
  final String type;
  final double amount;
  final String description;
  final DateTime date;

  const AddTransaction({
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
  });

  @override
  List<Object?> get props => [type, amount, description, date];
}

class DeleteTransaction extends TransactionEvent {
  final String transactionId;

  const DeleteTransaction({
    required this.transactionId,
  });

  @override
  List<Object?> get props => [transactionId];
}

class FilterTransactions extends TransactionEvent {
  final DateTime startDate;
  final DateTime endDate;

  const FilterTransactions({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}
