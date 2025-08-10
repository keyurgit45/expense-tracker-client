import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../config/injection.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/domain/services/category_service.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/edit_transaction_cubit.dart';
import '../bloc/transactions_list_cubit.dart';

class EditTransactionPage extends StatefulWidget {
  final Transaction transaction;

  const EditTransactionPage({
    super.key,
    required this.transaction,
  });

  @override
  State<EditTransactionPage> createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;
  
  final CategoryService _categoryService = getIt<CategoryService>();
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.transaction.amount.abs().toStringAsFixed(2),
    );
    _descriptionController = TextEditingController(
      text: widget.transaction.description,
    );
    _notesController = TextEditingController(
      text: widget.transaction.notes ?? '',
    );
    _loadCategories();
  }

  void _loadCategories() {
    setState(() {
      _categories = _categoryService.getCachedCategories();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<EditTransactionCubit>()
        ..initializeWithTransaction(widget.transaction),
      child: BlocConsumer<EditTransactionCubit, EditTransactionState>(
        listener: (context, state) {
          if (state is EditTransactionSuccess) {
            // Refresh the transactions list
            context.read<TransactionsListCubit>().refreshTransactions();
            
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Transaction updated successfully',
                  style: GoogleFonts.inter(fontSize: 14),
                ),
                backgroundColor: ColorConstants.positive,
                duration: const Duration(seconds: 2),
              ),
            );
            
            // Navigate back
            context.pop(state.transaction);
          } else if (state is EditTransactionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: GoogleFonts.inter(fontSize: 14),
                ),
                backgroundColor: ColorConstants.negative,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is EditTransactionLoaded) {
            return Scaffold(
              backgroundColor: ColorConstants.bgPrimary,
              body: SafeArea(
                child: Column(
                  children: [
                    _buildAppBar(context),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTypeSelector(context, state),
                            const SizedBox(height: 24),
                            _buildAmountField(context, state),
                            const SizedBox(height: 20),
                            _buildDescriptionField(context, state),
                            const SizedBox(height: 20),
                            _buildCategorySelector(context, state),
                            const SizedBox(height: 20),
                            _buildDateSelector(context, state),
                            const SizedBox(height: 20),
                            _buildTagSelector(context, state),
                            const SizedBox(height: 20),
                            _buildRecurringToggle(context, state),
                            const SizedBox(height: 20),
                            _buildNotesField(context, state),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                    _buildBottomActions(context, state),
                  ],
                ),
              ),
            );
          }
          
          return const Scaffold(
            backgroundColor: ColorConstants.bgPrimary,
            body: Center(
              child: CircularProgressIndicator(
                color: ColorConstants.textSecondary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                Icons.close,
                color: ColorConstants.textPrimary,
                size: 20,
              ),
            ),
          ),
          Text(
            'Edit Transaction',
            style: GoogleFonts.inter(
              color: ColorConstants.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(BuildContext context, EditTransactionLoaded state) {
    return Row(
      children: [
        Expanded(
          child: _TypeButton(
            label: 'Income',
            icon: Icons.arrow_downward,
            isSelected: state.type == TransactionType.income,
            color: ColorConstants.positive,
            onTap: () {
              context.read<EditTransactionCubit>().updateType(TransactionType.income);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TypeButton(
            label: 'Expense',
            icon: Icons.arrow_upward,
            isSelected: state.type == TransactionType.expense,
            color: ColorConstants.negative,
            onTap: () {
              context.read<EditTransactionCubit>().updateType(TransactionType.expense);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAmountField(BuildContext context, EditTransactionLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount',
          style: GoogleFonts.inter(
            color: ColorConstants.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: ColorConstants.surface1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ColorConstants.borderSubtle,
              width: 1,
            ),
          ),
          child: TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            style: GoogleFonts.robotoMono(
              color: ColorConstants.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: GoogleFonts.robotoMono(
                color: ColorConstants.textQuaternary,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              prefixText: '₹ ',
              prefixStyle: GoogleFonts.robotoMono(
                color: ColorConstants.textSecondary,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: (value) {
              final amount = double.tryParse(value) ?? 0;
              context.read<EditTransactionCubit>().updateAmount(amount);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(BuildContext context, EditTransactionLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: GoogleFonts.inter(
            color: ColorConstants.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: ColorConstants.surface1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ColorConstants.borderSubtle,
              width: 1,
            ),
          ),
          child: TextField(
            controller: _descriptionController,
            style: GoogleFonts.inter(
              color: ColorConstants.textPrimary,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Enter description',
              hintStyle: GoogleFonts.inter(
                color: ColorConstants.textQuaternary,
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: (value) {
              context.read<EditTransactionCubit>().updateDescription(value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector(BuildContext context, EditTransactionLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: GoogleFonts.inter(
            color: ColorConstants.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showCategoryPicker(context, state),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorConstants.surface1,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ColorConstants.borderSubtle,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  state.categoryName ?? 'Select category',
                  style: GoogleFonts.inter(
                    color: state.categoryName != null
                        ? ColorConstants.textPrimary
                        : ColorConstants.textQuaternary,
                    fontSize: 16,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: ColorConstants.textTertiary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector(BuildContext context, EditTransactionLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: GoogleFonts.inter(
            color: ColorConstants.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: state.date,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: ColorConstants.interactive,
                      surface: ColorConstants.surface2,
                      onSurface: ColorConstants.textPrimary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null && context.mounted) {
              context.read<EditTransactionCubit>().updateDate(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorConstants.surface1,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ColorConstants.borderSubtle,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy').format(state.date),
                  style: GoogleFonts.inter(
                    color: ColorConstants.textPrimary,
                    fontSize: 16,
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  color: ColorConstants.textTertiary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagSelector(BuildContext context, EditTransactionLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tag',
          style: GoogleFonts.inter(
            color: ColorConstants.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: TransactionTag.values.map((tag) {
            final isSelected = state.tag == tag;
            return GestureDetector(
              onTap: () {
                context.read<EditTransactionCubit>().updateTag(tag);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ColorConstants.interactive
                      : ColorConstants.surface2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? ColorConstants.interactive
                        : ColorConstants.borderSubtle,
                    width: 1,
                  ),
                ),
                child: Text(
                  _getTagDisplay(tag),
                  style: GoogleFonts.inter(
                    color: isSelected
                        ? ColorConstants.bgPrimary
                        : ColorConstants.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecurringToggle(BuildContext context, EditTransactionLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.surface1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorConstants.borderSubtle,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Recurring Transaction',
            style: GoogleFonts.inter(
              color: ColorConstants.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: state.isRecurring,
            onChanged: (value) {
              context.read<EditTransactionCubit>().updateIsRecurring(value);
            },
            activeColor: ColorConstants.interactive,
            inactiveThumbColor: ColorConstants.textQuaternary,
            inactiveTrackColor: ColorConstants.surface2,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField(BuildContext context, EditTransactionLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (Optional)',
          style: GoogleFonts.inter(
            color: ColorConstants.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: ColorConstants.surface1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ColorConstants.borderSubtle,
              width: 1,
            ),
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 3,
            style: GoogleFonts.inter(
              color: ColorConstants.textPrimary,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Add notes...',
              hintStyle: GoogleFonts.inter(
                color: ColorConstants.textQuaternary,
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: (value) {
              context.read<EditTransactionCubit>().updateNotes(value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context, EditTransactionState state) {
    final isLoading = state is EditTransactionSaving;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorConstants.bgPrimary,
        border: Border(
          top: BorderSide(
            color: ColorConstants.borderSubtle,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: isLoading ? null : () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: ColorConstants.surface2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      color: ColorConstants.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: isLoading
                  ? null
                  : () {
                      if (_amountController.text.isNotEmpty &&
                          _descriptionController.text.isNotEmpty) {
                        context.read<EditTransactionCubit>().saveTransaction();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please enter amount and description',
                              style: GoogleFonts.inter(fontSize: 14),
                            ),
                            backgroundColor: ColorConstants.negative,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isLoading
                      ? ColorConstants.surface3
                      : ColorConstants.interactive,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: ColorConstants.textPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Save Changes',
                          style: GoogleFonts.inter(
                            color: ColorConstants.bgPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryPicker(BuildContext context, EditTransactionLoaded state) {
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Select Category',
                style: GoogleFonts.inter(
                  color: ColorConstants.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category.id == state.categoryId;
                  
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? ColorConstants.interactive
                            : ColorConstants.surface2,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.category,
                        color: isSelected
                            ? ColorConstants.bgPrimary
                            : ColorConstants.textTertiary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      category.name,
                      style: GoogleFonts.inter(
                        color: ColorConstants.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check,
                            color: ColorConstants.interactive,
                          )
                        : null,
                    onTap: () {
                      context.read<EditTransactionCubit>().updateCategory(
                            category.id,
                            category.name,
                          );
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
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
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : ColorConstants.surface1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : ColorConstants.borderSubtle,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : ColorConstants.textTertiary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected ? color : ColorConstants.textSecondary,
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