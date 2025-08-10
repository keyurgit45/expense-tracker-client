import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/color_constants.dart';
import '../../domain/entities/sms_transaction.dart';

class SmsTransactionItem extends StatelessWidget {
  final SmsTransaction transaction;
  final VoidCallback? onAddToTransactions;

  const SmsTransactionItem({
    super.key,
    required this.transaction,
    this.onAddToTransactions,
  });

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.transactionType == TransactionType.credit;
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      locale: 'en_IN',
      decimalDigits: 2,
    );

    return InkWell(
      onTap: () {
        // Show full SMS in a bottom sheet
        _showSmsDetails(context);
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side - Merchant and Bank
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.merchant ?? 'Bank Transaction',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ColorConstants.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 100,
                    child: Text(
                      transaction.bankName ?? 'Unknown Bank',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: ColorConstants.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Right side - Amount and Type
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isCredit ? '+' : '-'}${currencyFormat.format(transaction.amount)}',
                  style: GoogleFonts.robotoMono(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: ColorConstants.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isCredit
                        ? ColorConstants.positiveSubtle
                        : ColorConstants.surface2,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isCredit ? 'IN' : 'OUT',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isCredit
                          ? ColorConstants.positive
                          : ColorConstants.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSmsDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ColorConstants.surface1,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ColorConstants.surface3,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                'SMS Details',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: ColorConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              // Details
              _buildDetailRow('Sender', transaction.senderAddress),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Date',
                DateFormat('MMM d, yyyy • h:mm a').format(transaction.date),
              ),
              if (transaction.paymentMethod != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow('Payment Method', transaction.paymentMethod!),
              ],
              if (transaction.reference != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow('Reference', transaction.reference!),
              ],
              const SizedBox(height: 20),
              // Full message
              Text(
                'Full Message',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ColorConstants.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorConstants.bgPrimary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  transaction.body,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: ColorConstants.textTertiary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Action button to add to transactions
              if (transaction.isParsed) ...[
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    if (onAddToTransactions != null) {
                      onAddToTransactions!();
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: ColorConstants.interactive,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add,
                          color: ColorConstants.bgPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Add to Transactions',
                          style: GoogleFonts.inter(
                            color: ColorConstants.bgPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: ColorConstants.textTertiary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ColorConstants.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}