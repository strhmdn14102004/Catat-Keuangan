import 'package:bloc/bloc.dart';
import 'package:catat_keuangan/module/transaction/transaction_event.dart';
import 'package:catat_keuangan/module/transaction/transaction_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  TransactionBloc(this.firestore, this.auth) : super(TransactionLoading()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<FilterTransactions>(_onFilterTransactions);
  }

  void _onLoadTransactions(LoadTransactions event, Emitter<TransactionState> emit) async {
    try {
      emit(TransactionLoading());

      // Dapatkan email pengguna yang login
      final user = auth.currentUser;
      final email = user?.email;

      if (email == null) {
        emit(TransactionError("User not logged in"));
        return;
      }

      // Ambil data dari Firestore berdasarkan email
      final snapshot = await firestore.collection('transactions').doc(email).collection('user_transactions').get();
      final transactions = snapshot.docs.map((doc) => doc.data()).toList();

      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  void _onAddTransaction(AddTransaction event, Emitter<TransactionState> emit) async {
    try {
      emit(TransactionLoading());

      // Dapatkan email pengguna yang login
      final user = auth.currentUser;
      final email = user?.email;

      if (email == null) {
        emit(TransactionError("User not logged in"));
        return;
      }

      // Tambahkan transaksi ke Firestore berdasarkan email
      await firestore.collection('transactions').doc(email).collection('user_transactions').add({
        'tipe': event.type,
        'jumlah': event.amount,
        'deskripsi': event.description,
        'tanggal': event.date,
      });

      // Reload transactions after adding
      add(LoadTransactions());
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  void _onDeleteTransaction(DeleteTransaction event, Emitter<TransactionState> emit) async {
    try {
      emit(TransactionLoading());

      // Dapatkan email pengguna yang login
      final user = auth.currentUser;
      final email = user?.email;

      if (email == null) {
        emit(TransactionError("User not logged in"));
        return;
      }

      // Hapus transaksi dari Firestore berdasarkan email
      await firestore.collection('transactions').doc(email).collection('user_transactions').doc(event.transactionId).delete();

      // Reload transactions after deleting
      add(LoadTransactions());
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  void _onFilterTransactions(FilterTransactions event, Emitter<TransactionState> emit) async {
    try {
      emit(TransactionLoading());

      // Dapatkan email pengguna yang login
      final user = auth.currentUser;
      final email = user?.email;

      if (email == null) {
        emit(TransactionError("User not logged in"));
        return;
      }

      // Ambil data dari Firestore dengan rentang tanggal berdasarkan email
      final snapshot = await firestore.collection('transactions').doc(email).collection('user_transactions')
          .where('tanggal', isGreaterThanOrEqualTo: event.startDate)
          .where('tanggal', isLessThanOrEqualTo: event.endDate)
          .get();
      final transactions = snapshot.docs.map((doc) => doc.data()).toList();

      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }
}
