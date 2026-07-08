import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracker_app/core/theme/app_color.dart';
import 'package:tracker_app/features/expense/data/model/expense_model.dart';

class ExpenseItemWidget extends StatefulWidget {
  final ExpenseModel expense;
  final int index;
  final VoidCallback onDelete;

  const ExpenseItemWidget({
    super.key,
    required this.expense,
    required this.index,
    required this.onDelete,
  });

  @override
  State<ExpenseItemWidget> createState() => _ExpenseItemWidgetState();
}

class _ExpenseItemWidgetState extends State<ExpenseItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

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

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + (widget.index * 50).clamp(0, 500)),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _slideAnim = Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = _categoryColor(widget.expense.category);

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Dismissible(
          key: Key(widget.expense.id ?? widget.expense.title),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.dangerColor,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
          ),
          onDismissed: (_) => widget.onDelete(),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.borderColor.withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.expense.category.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.expense.title, style: theme.textTheme.titleSmall),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('d MMM, hh:mm a').format(widget.expense.date),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '-₹${widget.expense.amount.toStringAsFixed(2)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.dangerColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.expense.category.label,
                        style: theme.textTheme.labelSmall?.copyWith(color: color),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}