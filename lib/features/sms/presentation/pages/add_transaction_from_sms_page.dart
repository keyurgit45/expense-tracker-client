import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../config/injection.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/domain/services/category_service.dart';
import '../../../transactions/domain/entities/transaction.dart' as trans;
import '../../../transactions/domain/usecases/create_transaction.dart';
import '../../../transactions/presentation/bloc/home_cubit.dart';
import '../../../transactions/presentation/bloc/transactions_list_cubit.dart';
import '../../domain/entities/sms_transaction.dart';

class AddTransactionFromSmsPage extends StatefulWidget {
  final SmsTransaction smsTransaction;

  const AddTransactionFromSmsPage({
    super.key,
    required this.smsTransaction,
  });

  @override
  State<AddTransactionFromSmsPage> createState() =>
      _AddTransactionFromSmsPageState();
}

class _AddTransactionFromSmsPageState
    extends State<AddTransactionFromSmsPage> {
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  trans.TransactionType _transactionType = trans.TransactionType.expense;
  trans.TransactionTag _selectedTag = trans.TransactionTag.other;
  bool _isRecurring = false;
  bool _isSaving = false;

  final CategoryService _categoryService = getIt<CategoryService>();
  final CreateTransaction _createTransaction = getIt<CreateTransaction>();
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    
    // Initialize from SMS transaction
    final amount = widget.smsTransaction.amount ?? 0;
    _amountController = TextEditingController(
      text: amount.toStringAsFixed(2),
    );
    
    // Build description from SMS data
    String description = widget.smsTransaction.merchant ?? 'Transaction';
    if (widget.smsTransaction.paymentMethod != null) {
      description += ' (${widget.smsTransaction.paymentMethod})';
    }
    _descriptionController = TextEditingController(text: description);
    
    // Add reference as notes if available
    _notesController = TextEditingController(
      text: widget.smsTransaction.reference ?? '',
    );
    
    _selectedDate = widget.smsTransaction.date;
    
    // Set transaction type based on SMS type
    _transactionType = widget.smsTransaction.transactionType == TransactionType.credit
        ? trans.TransactionType.income
        : trans.TransactionType.expense;
    
    _loadCategories();
  }

  void _loadCategories() async {
    try {
      final categories = await _categoryService.getCategories();
      setState(() {
        _categories = categories;
        // Try to auto-select category based on merchant name
        _autoSelectCategory();
      });
    } catch (e) {
      // Handle error
    }
  }

  void _autoSelectCategory() {
    if (widget.smsTransaction.merchant == null) return;
    
    final merchantLower = widget.smsTransaction.merchant!.toLowerCase();
    
    // Try to match category based on merchant name
    for (final category in _categories) {
      final categoryLower = category.name.toLowerCase();
      
      if (merchantLower.contains('food') || 
          merchantLower.contains('restaurant') ||
          merchantLower.contains('cafe')) {
        if (categoryLower.contains('food')) {
          _selectedCategoryId = category.id;
          _selectedCategoryName = category.name;
          break;
        }
      } else if (merchantLower.contains('uber') || 
                 merchantLower.contains('ola') ||
                 merchantLower.contains('taxi')) {
        if (categoryLower.contains('transport')) {
          _selectedCategoryId = category.id;
          _selectedCategoryName = category.name;
          break;
        }
      } else if (merchantLower.contains('amazon') ||
                 merchantLower.contains('flipkart') ||
                 merchantLower.contains('myntra')) {
        if (categoryLower.contains('shopping')) {
          _selectedCategoryId = category.id;
          _selectedCategoryName = category.name;
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    if (_amountController.text.isEmpty || _descriptionController.text.isEmpty) {
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
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      final signedAmount = _transactionType == trans.TransactionType.income
          ? amount.abs()
          : -amount.abs();

      final transaction = trans.Transaction(
        id: const Uuid().v4(),
        description: _descriptionController.text,
        amount: signedAmount,
        type: _transactionType,
        tag: _selectedTag,
        date: _selectedDate,
        categoryId: _selectedCategoryId,
        categoryName: _selectedCategoryName,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        isRecurring: _isRecurring,
      );

      final result = await _createTransaction(
        CreateTransactionParams(transaction: transaction),
      );

      result.fold(
        (failure) {
          setState(() {
            _isSaving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to add transaction: ${failure.message}',
                style: GoogleFonts.inter(fontSize: 14),
              ),
              backgroundColor: ColorConstants.negative,
              duration: const Duration(seconds: 3),
            ),
          );
        },
        (transaction) {
          // Refresh the home and transactions list
          if (context.mounted) {
            context.read<HomeCubit>().loadHomeData();
            context.read<TransactionsListCubit>().refreshTransactions();
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Transaction added successfully',
                  style: GoogleFonts.inter(fontSize: 14),
                ),
                backgroundColor: ColorConstants.positive,
                duration: const Duration(seconds: 2),
              ),
            );
            
            // Navigate back
            context.pop(true);
          }
        },
      );
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
            style: GoogleFonts.inter(fontSize: 14),
          ),
          backgroundColor: ColorConstants.negative,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSmsInfo(),
                    const SizedBox(height: 24),
                    _buildTypeSelector(),
                    const SizedBox(height: 24),
                    _buildAmountField(),
                    const SizedBox(height: 20),
                    _buildDescriptionField(),
                    const SizedBox(height: 20),
                    _buildCategorySelector(),
                    const SizedBox(height: 20),
                    _buildDateSelector(),
                    const SizedBox(height: 20),
                    _buildTagSelector(),
                    const SizedBox(height: 20),
                    _buildRecurringToggle(),
                    const SizedBox(height: 20),
                    _buildNotesField(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
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
            'Add from SMS',
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

  Widget _buildSmsInfo() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sms,
                size: 16,
                color: ColorConstants.textTertiary,
              ),
              const SizedBox(width: 8),
              Text(
                'SMS Transaction',
                style: GoogleFonts.inter(
                  color: ColorConstants.textTertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'From: ${widget.smsTransaction.senderAddress}',
            style: GoogleFonts.inter(
              color: ColorConstants.textSecondary,
              fontSize: 14,
            ),
          ),
          if (widget.smsTransaction.bankName != null) ...[
            const SizedBox(height: 4),
            Text(
              'Bank: ${widget.smsTransaction.bankName}',
              style: GoogleFonts.inter(
                color: ColorConstants.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _TypeButton(
            label: 'Income',
            icon: Icons.arrow_downward,
            isSelected: _transactionType == trans.TransactionType.income,
            color: ColorConstants.positive,
            onTap: () {
              setState(() {
                _transactionType = trans.TransactionType.income;
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TypeButton(
            label: 'Expense',
            icon: Icons.arrow_upward,
            isSelected: _transactionType == trans.TransactionType.expense,
            color: ColorConstants.negative,
            onTap: () {
              setState(() {
                _transactionType = trans.TransactionType.expense;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAmountField() {
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
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
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
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
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
          onTap: () => _showCategoryPicker(),
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
                  _selectedCategoryName ?? 'Select category',
                  style: GoogleFonts.inter(
                    color: _selectedCategoryName != null
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

  Widget _buildDateSelector() {
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
              initialDate: _selectedDate,
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
            if (picked != null) {
              setState(() {
                _selectedDate = picked;
              });
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
                  DateFormat('MMM dd, yyyy').format(_selectedDate),
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

  Widget _buildTagSelector() {
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
          children: trans.TransactionTag.values.map((tag) {
            final isSelected = _selectedTag == tag;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTag = tag;
                });
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

  Widget _buildRecurringToggle() {
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
            value: _isRecurring,
            onChanged: (value) {
              setState(() {
                _isRecurring = value;
              });
            },
            activeColor: ColorConstants.interactive,
            inactiveThumbColor: ColorConstants.textQuaternary,
            inactiveTrackColor: ColorConstants.surface2,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
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
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
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
              onTap: _isSaving ? null : () => Navigator.of(context).pop(),
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
              onTap: _isSaving ? null : _saveTransaction,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _isSaving
                      ? ColorConstants.surface3
                      : ColorConstants.interactive,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: ColorConstants.textPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Add Transaction',
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

  void _showCategoryPicker() {
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
                  final isSelected = category.id == _selectedCategoryId;
                  
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
                      setState(() {
                        _selectedCategoryId = category.id;
                        _selectedCategoryName = category.name;
                      });
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

  String _getTagDisplay(trans.TransactionTag tag) {
    switch (tag) {
      case trans.TransactionTag.fee:
        return 'Fee';
      case trans.TransactionTag.sale:
        return 'Sale';
      case trans.TransactionTag.refund:
        return 'Refund';
      case trans.TransactionTag.other:
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