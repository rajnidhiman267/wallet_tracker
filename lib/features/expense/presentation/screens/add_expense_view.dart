 import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_app/core/theme/app_color.dart';
import 'package:tracker_app/core/utils/helper_utils.dart';
import 'package:tracker_app/features/expense/data/model/expense_model.dart';
import 'package:tracker_app/features/expense/presentation/bloc/expense_cubit.dart';
import 'package:tracker_app/features/expense/presentation/bloc/expense_state.dart';
import 'package:intl/intl.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  DateTime _selectedDate = DateTime.now();

  late AnimationController _slideCtrl;
  late AnimationController _fadeCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn));
    _slideCtrl.forward();
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _fadeCtrl.dispose();
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Color _categoryColor(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.food: return AppColors.foodColor;
      case ExpenseCategory.transport: return AppColors.transportColor;
      case ExpenseCategory.shopping: return AppColors.shoppingColor;
      case ExpenseCategory.health: return AppColors.healthColor;
      case ExpenseCategory.entertainment: return AppColors.entertainmentColor;
      case ExpenseCategory.bills: return AppColors.billsColor;
      case ExpenseCategory.education: return AppColors.educationColor;
      case ExpenseCategory.other: return AppColors.otherColor;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<ExpenseCubit>().addExpense(
      title: _titleCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text.trim()),
      category: _selectedCategory,
      date: _selectedDate,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<ExpenseCubit, ExpenseState>(
      listener: (context, state) {
        if (state.addSuccess) {
          context.read<ExpenseCubit>().resetAddSuccess();
          HelperUtils.showCustomToast(toastMsg: 'Expense added!');
          context.pop();
        }
        if (state.errorMessage != null) {
          HelperUtils.showCustomToast(toastMsg: state.errorMessage, isError: true);
        }
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Add Expense',
                              style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('EEEE, d MMMM yyyy').format(_selectedDate),
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              backgroundColor: AppColors.gradientStart,
            ),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Amount field - prominent
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.gradientStart, AppColors.gradientEnd],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Amount', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                                TextFormField(
                                  controller: _amountCtrl,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                                  ],
                                  style: const TextStyle(
                                    fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                                  decoration: const InputDecoration(
                                    filled: false,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    prefixText: '₹ ',
                                    prefixStyle: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white70),
                                    hintText: '0.00',
                                    hintStyle: TextStyle(fontSize: 36, color: Colors.white38),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Enter amount';
                                    if (double.tryParse(v) == null) return 'Invalid amount';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Category picker
                          Text('Category', style: theme.textTheme.labelLarge),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 80,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: ExpenseCategory.values.length,
                              separatorBuilder: (_, _) => const SizedBox(width: 10),
                              itemBuilder: (context, i) {
                                final cat = ExpenseCategory.values[i];
                                final isSelected = _selectedCategory == cat;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedCategory = cat),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOut,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? _categoryColor(cat)
                                          : (isDark ? AppColors.darkCard : Colors.white),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSelected ? _categoryColor(cat) : AppColors.borderColor,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      boxShadow: isSelected
                                          ? [BoxShadow(color: _categoryColor(cat).withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4))]
                                          : [],
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(cat.emoji, style: const TextStyle(fontSize: 22)),
                                        const SizedBox(height: 4),
                                        Text(
                                          cat.label,
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: isSelected ? Colors.white : null,
                                            fontWeight: isSelected ? FontWeight.w600 : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Title field
                          Text('Title', style: theme.textTheme.labelLarge),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _titleCtrl,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(hintText: 'e.g. Lunch at restaurant'),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Enter a title' : null,
                          ),
                          const SizedBox(height: 20),

                          // Date picker
                          Text('Date', style: theme.textTheme.labelLarge),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _pickDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurface : AppColors.bgTextFieldColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderColor),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.hintTextColor),
                                  const SizedBox(width: 12),
                                  Text(
                                    DateFormat('d MMM, yyyy').format(_selectedDate),
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.chevron_right_rounded, color: AppColors.hintTextColor),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Note
                          Text('Note (optional)', style: theme.textTheme.labelLarge),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _noteCtrl,
                            maxLines: 3,
                            decoration: const InputDecoration(hintText: 'Add a note...'),
                          ),
                          const SizedBox(height: 32),

                          // Submit
                          BlocBuilder<ExpenseCubit, ExpenseState>(
                            builder: (context, state) {
                              return SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: state.isAdding ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14)),
                                    ),
                                    child: state.isAdding
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                                color: Colors.white, strokeWidth: 2))
                                        : const Text('Save Expense',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white)),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}