import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/sms_transaction.dart';
import '../../domain/repositories/sms_repository.dart';
import '../../domain/usecases/export_sms_to_csv.dart';
import 'sms_state.dart';

class SmsCubit extends Cubit<SmsState> {
  final SmsRepository repository;

  SmsCubit({required this.repository}) : super(SmsInitial());

  Future<void> loadSmsTransactions() async {
    emit(SmsLoading());

    // Request permission first
    final permissionResult = await repository.requestSmsPermission();
    permissionResult.fold(
      (failure) => emit(SmsError(message: failure.message)),
      (isGranted) async {
        if (!isGranted) {
          emit(SmsPermissionDenied());
          return;
        }

        // Load SMS transactions
        final result = await repository.getAllSmsTransactions();
        result.fold(
          (failure) => emit(SmsError(message: failure.message)),
          (transactions) => emit(SmsLoaded(transactions: transactions)),
        );
      },
    );
  }

  void filterByType(TransactionType? type) {
    final currentState = state;
    if (currentState is SmsLoaded) {
      emit(SmsLoaded(
        transactions: currentState.transactions,
        filterType: type,
      ));
    }
  }

  Future<void> exportAllSmsToCSV() async {
    final currentState = state;
    if (currentState is! SmsLoaded) return;

    try {
      // Get all SMS messages (not just bank transactions)
      final result = await repository.getAllSmsMessages();
      
      await result.fold(
        (failure) async {
          // Show error somehow
        },
        (allMessages) async {
          await ExportSmsToCsv.exportToCSV(allMessages);
        },
      );
    } catch (e) {
      // Handle error
    }
  }
}