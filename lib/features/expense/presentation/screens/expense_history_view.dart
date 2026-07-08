import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:tracker_app/core/theme/app_color.dart';
import 'package:tracker_app/features/expense/data/model/expense_model.dart';
import 'package:tracker_app/features/expense/presentation/bloc/expense_cubit.dart';
import 'package:tracker_app/features/expense/presentation/bloc/expense_state.dart';
import 'package:tracker_app/features/expense/presentation/screens/widget/expense_item_widget.dart';

class ExpenseHistoryScreen extends StatefulWidget {
  const ExpenseHistoryScreen({super.key});

  @override
  State<ExpenseHistoryScreen> createState() => _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState extends State<ExpenseHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<ExpenseCubit>().loadByFilter(
          _tabController.index == 0 ? ExpenseFilter.week : ExpenseFilter.month,
        );
      }
    });
    context.read<ExpenseCubit>().loadByFilter(ExpenseFilter.week);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _categoryColor(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.food:
        return AppColors.foodColor;
      case ExpenseCategory.transport:
        return AppColors.transportColor;
      case ExpenseCategory.shopping:
        return AppColors.shoppingColor;
      case ExpenseCategory.health:
        return AppColors.healthColor;
      case ExpenseCategory.entertainment:
        return AppColors.entertainmentColor;
      case ExpenseCategory.bills:
        return AppColors.billsColor;
      case ExpenseCategory.education:
        return AppColors.educationColor;
      case ExpenseCategory.other:
        return AppColors.otherColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Expense History'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? AppColors.darkSurface
                  : const Color(0xFFEEF0F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.hintTextColor,
              labelStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'This Week'),
                Tab(text: 'This Month'),
              ],
            ),
          ),
        ),
      ),
      body: BlocBuilder<ExpenseCubit, ExpenseState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _buildExpenseList(state, theme),
              _buildExpenseList(state, theme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExpenseList(ExpenseState state, ThemeData theme) {
    if (state.expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('💸', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('No expenses yet', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Start adding your expenses!',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    // Summary card
    final categoryTotals = state.categoryTotals;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Spent',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${state.totalAmount.toStringAsFixed(2)}',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${state.expenses.length} transactions',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Category breakdown
                if (categoryTotals.isNotEmpty) ...[
                  Text('By Category', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 10),
                  ...categoryTotals.entries.map((entry) {
                    final pct = state.totalAmount > 0
                        ? (entry.value / state.totalAmount)
                        : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Text(
                            entry.key.emoji,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      entry.key.label,
                                      style: theme.textTheme.labelMedium,
                                    ),
                                    Text(
                                      '₹${entry.value.toStringAsFixed(2)}',
                                      style: theme.textTheme.labelMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: pct.toDouble()),
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeOut,
                                  builder: (_, value, _) => ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: value,
                                      minHeight: 6,
                                      backgroundColor: AppColors.borderColor,
                                      valueColor: AlwaysStoppedAnimation(
                                        _categoryColor(entry.key),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  Divider(color: AppColors.borderColor.withValues(alpha: 0.5)),
                  const SizedBox(height: 8),
                  Text('All Transactions', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4),
                ],
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => ExpenseItemWidget(
              expense: state.expenses[i],
              index: i,
              onDelete: () => context.read<ExpenseCubit>().deleteExpense(
                state.expenses[i].id!,
              ),
            ),
            childCount: state.expenses.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}
