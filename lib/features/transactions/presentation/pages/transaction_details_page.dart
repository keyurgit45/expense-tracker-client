import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/transaction.dart';

class TransactionDetailsPage extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailsPage({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildAppBar(context),
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header with amount
                    _buildHeader(),
                    const SizedBox(height: 32),
                    // Details section
                    _buildDetailsSection(),
                    const SizedBox(height: 24),
                    // Actions
                    _buildActions(context),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ColorConstants.surface2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: ColorConstants.textPrimary,
                size: 20,
              ),
            ),
          ),
          // Title
          Text(
            'Transaction Details',
            style: GoogleFonts.inter(
              color: ColorConstants.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          // More options
          GestureDetector(
            onTap: () => _showMoreOptions(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ColorConstants.surface2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.more_vert,
                color: ColorConstants.textPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final bool isIncome = transaction.type == TransactionType.income;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isIncome 
                  ? ColorConstants.positiveSubtle 
                  : ColorConstants.negativeSubtle,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome 
                  ? ColorConstants.positive 
                  : ColorConstants.negative,
              size: 32,
            ),
          ),
          const SizedBox(height: 24),
          // Amount
          Text(
            '${isIncome ? '+' : '-'}${CurrencyFormatter.format(transaction.amount.abs())}',
            style: GoogleFonts.robotoMono(
              color: isIncome 
                  ? ColorConstants.positive 
                  : ColorConstants.textPrimary,
              fontSize: 36,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          // Description
          Text(
            transaction.description,
            style: GoogleFonts.inter(
              color: ColorConstants.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Builder(
      builder: (context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ColorConstants.surface1,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ColorConstants.borderSubtle,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TRANSACTION DETAILS',
              style: GoogleFonts.inter(
                color: ColorConstants.textTertiary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow(
              label: 'Date & Time',
              value: DateFormat('MMM dd, yyyy • hh:mm a').format(transaction.date),
              icon: Icons.calendar_today,
            ),
            _buildDivider(),
            _buildDetailRow(
              label: 'Type',
              value: transaction.type == TransactionType.income ? 'Income' : 'Expense',
              icon: Icons.swap_vert,
            ),
            _buildDivider(),
            _buildDetailRow(
              label: 'Category',
              value: transaction.categoryName ?? 'Uncategorized',
              icon: Icons.category,
            ),
            if (transaction.tag != TransactionTag.other) ...[
              _buildDivider(),
              _buildDetailRow(
                label: 'Tag',
                value: _getTagDisplay(transaction.tag),
                icon: Icons.label,
                tagColor: _getTagColor(transaction.tag),
              ),
            ],
            if (transaction.isRecurring) ...[
              _buildDivider(),
              _buildDetailRow(
                label: 'Recurring',
                value: 'Yes',
                icon: Icons.repeat,
                valueColor: ColorConstants.positive,
              ),
            ],
            if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
              _buildDivider(),
              _buildDetailRow(
                label: 'Notes',
                value: transaction.notes!,
                icon: Icons.note,
                isMultiline: true,
              ),
            ],
            _buildDivider(),
            _buildDetailRow(
              label: 'Transaction ID',
              value: transaction.id.substring(0, 8).toUpperCase(),
              icon: Icons.fingerprint,
              onTap: () => _copyToClipboard(context, transaction.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required IconData icon,
    bool isMultiline = false,
    Color? valueColor,
    Color? tagColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: ColorConstants.surface2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: ColorConstants.textTertiary,
                size: 18,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      color: ColorConstants.textTertiary,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (tagColor != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: tagColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        value,
                        style: GoogleFonts.inter(
                          color: tagColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ] else ...[
                    Text(
                      value,
                      style: GoogleFonts.inter(
                        color: valueColor ?? ColorConstants.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: isMultiline ? null : 1,
                      overflow: isMultiline ? null : TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (onTap != null) ...[
              const Icon(
                Icons.copy,
                color: ColorConstants.textQuaternary,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: ColorConstants.borderSubtle,
      margin: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _ActionButton(
        label: 'Edit Transaction',
        icon: Icons.edit,
        onTap: () {
          // TODO: Navigate to edit transaction
          context.push('/transactions/edit/${transaction.id}', extra: transaction);
        },
        isPrimary: true,
      ),
    );
  }

  String _getTagDisplay(TransactionTag tag) {
    switch (tag) {
      case TransactionTag.fee:
        return 'Fee';
      case TransactionTag.sale:
        return 'Sale';
      case TransactionTag.refund:
        return 'Refund';
      case TransactionTag.other:
        return 'Other';
    }
  }

  Color _getTagColor(TransactionTag tag) {
    switch (tag) {
      case TransactionTag.fee:
        return Colors.orange;
      case TransactionTag.sale:
        return Colors.green;
      case TransactionTag.refund:
        return Colors.blue;
      case TransactionTag.other:
        return ColorConstants.textTertiary;
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Transaction ID copied',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        backgroundColor: ColorConstants.surface3,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: ColorConstants.bgSecondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ColorConstants.borderDefault,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _OptionTile(
              icon: Icons.share,
              label: 'Share Transaction',
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement share
              },
            ),
            _OptionTile(
              icon: Icons.download,
              label: 'Export as PDF',
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement export
              },
            ),
            _OptionTile(
              icon: Icons.flag,
              label: 'Report Issue',
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement report
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isPrimary
        ? ColorConstants.interactive
        : ColorConstants.surface2;
    final foregroundColor = isPrimary
        ? ColorConstants.bgPrimary
        : ColorConstants.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: foregroundColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                color: foregroundColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: ColorConstants.surface2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: ColorConstants.textPrimary,
          size: 20,
        ),
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(
          color: ColorConstants.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: ColorConstants.textTertiary,
      ),
      onTap: onTap,
    );
  }
}