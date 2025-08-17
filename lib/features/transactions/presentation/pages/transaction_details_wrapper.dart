import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/injection.dart';
import '../../../../core/constants/color_constants.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import 'transaction_details_page.dart';

class TransactionDetailsWrapper extends StatefulWidget {
  final String transactionId;

  const TransactionDetailsWrapper({
    super.key,
    required this.transactionId,
  });

  @override
  State<TransactionDetailsWrapper> createState() =>
      _TransactionDetailsWrapperState();
}

class _TransactionDetailsWrapperState extends State<TransactionDetailsWrapper> {
  Transaction? _currentTransaction;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt<TransactionRepository>()
          .getTransactionById(widget.transactionId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: ColorConstants.bgPrimary,
            body: Center(
              child: CircularProgressIndicator(
                color: ColorConstants.textPrimary,
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          final result = snapshot.data;
          String errorMessage = 'Transaction not found';

          if (result != null) {
            result.fold(
              (failure) => errorMessage = failure.message,
              (transaction) => {},
            );
          }

          return Scaffold(
            backgroundColor: ColorConstants.bgPrimary,
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: ColorConstants.surface2,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        size: 40,
                        color: ColorConstants.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Oops!',
                      style: GoogleFonts.inter(
                        color: ColorConstants.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMessage,
                      style: GoogleFonts.inter(
                        color: ColorConstants.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: ColorConstants.surface2,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Go Back',
                          style: GoogleFonts.inter(
                            color: ColorConstants.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return snapshot.data!.fold(
          (failure) => Scaffold(
            backgroundColor: ColorConstants.bgPrimary,
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: ColorConstants.textTertiary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading transaction',
                      style: GoogleFonts.inter(
                        color: ColorConstants.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      failure.message,
                      style: GoogleFonts.inter(
                        color: ColorConstants.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          (transaction) {
            // Update current transaction if it's different
            if (_currentTransaction?.id != transaction.id) {
              _currentTransaction = transaction;
            }

            return TransactionDetailsPage(
              transaction: _currentTransaction!,
              onTransactionUpdated: (updatedTransaction) {
                setState(() {
                  _currentTransaction = updatedTransaction;
                });
              },
            );
          },
        );
      },
    );
  }
}
