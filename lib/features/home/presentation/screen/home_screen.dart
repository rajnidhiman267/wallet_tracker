import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_app/core/routes/app_route_name.dart';
import 'package:tracker_app/core/theme/app_color.dart';
import 'package:tracker_app/core/widgets/custom_profile_image_widget.dart';
import 'package:tracker_app/features/expense/data/model/expense_model.dart';
import 'package:tracker_app/features/expense/presentation/bloc/expense_cubit.dart';
import 'package:tracker_app/features/expense/presentation/bloc/expense_state.dart';
import 'package:tracker_app/features/expense/presentation/screens/widget/expense_item_widget.dart';
import 'package:tracker_app/features/home/presentation/bloc/theme_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _headerCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  // FIX 1: Track previous totalAmount so TweenAnimationBuilder re-animates
  // every time the value genuinely changes (not just on first build).
  double _previousTotal = 0;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeIn));
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));
    _headerCtrl.forward();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
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
    final isDark = theme.brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: BlocBuilder<ExpenseCubit, ExpenseState>(
        builder: (context, state) {
          // FIX 1: Capture the current total so TweenAnimationBuilder always
          // has a fresh `begin` value on the next state change.
          final currentTotal = state.totalAmount;

          return CustomScrollView(
            slivers: [
              // === HEADER ===
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _headerFade,
                  child: SlideTransition(
                    position: _headerSlide,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.gradientStart,
                            AppColors.gradientEnd,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(28),
                          bottomRight: Radius.circular(28),
                        ),
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CustomProfileImageWidget(
                                    imageSize: 42,
                                    image: user?.photoURL,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _greeting(),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(color: Colors.white70),
                                        ),
                                        Text(
                                          user?.displayName ?? 'User',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  BlocBuilder<ThemeCubit, ThemeMode>(
                                    builder: (ctx, themeMode) => IconButton(
                                      onPressed: () =>
                                          ctx.read<ThemeCubit>().toggleTheme(),
                                      icon: Icon(
                                        themeMode == ThemeMode.dark
                                            ? Icons.light_mode_rounded
                                            : Icons.dark_mode_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.person_outline_rounded,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => context.pushNamed(
                                      AppRouteName.profileSetup,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.logout_rounded,
                                      color: Colors.white,
                                    ),
                                    onPressed: () async {
                                      await FirebaseAuth.instance.signOut();
                                      if (context.mounted) {
                                        context.goNamed(AppRouteName.login);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'This Month',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 4),

                              // FIX 1: Use key to force widget rebuild when total
                              // changes so the animation always plays from the
                              // previous value to the new one.
                              TweenAnimationBuilder<double>(
                                key: ValueKey(currentTotal),
                                tween: Tween(
                                  begin: _previousTotal,
                                  end: currentTotal,
                                ),
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeOut,
                                onEnd: () {
                                  // After animation completes, update baseline
                                  _previousTotal = currentTotal;
                                },
                                builder: (_, value, _) => Text(
                                  '₹${value.toStringAsFixed(2)}',
                                  style: theme.textTheme.headlineLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),

                              const SizedBox(height: 8),
                              Text(
                                '${state.expenses.length} transactions',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // === QUICK ACTIONS ===
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.add_circle_outline_rounded,
                          label: 'Add Expense',
                          gradient: const [
                            Color(0xFF667EEA),
                            Color(0xFF764BA2),
                          ],
                          onTap: () =>
                              context.pushNamed(AppRouteName.addExpense),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.bar_chart_rounded,
                          label: 'History',
                          gradient: const [
                            Color(0xFF11998e),
                            Color(0xFF38ef7d),
                          ],
                          onTap: () =>
                              context.pushNamed(AppRouteName.expenseHistory),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // === CATEGORY SUMMARY ===
              if (state.categoryTotals.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'By Category',
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                SliverToBoxAdapter(
                  child: SizedBox(
                    // FIX 2: Increased height slightly to prevent overflow
                    height: 100,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: state.categoryTotals.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final entry = state.categoryTotals.entries.toList()[i];
                        final color = _categoryColor(entry.key);

                        // FIX 2: Use intrinsic sizing instead of fixed width.
                        // Wrap content in a flexible column so long amounts
                        // never overflow the card.
                        return Container(
                          // FIX 2: Let width adapt — set a min but no hard max
                          constraints: const BoxConstraints(minWidth: 90),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: color.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                entry.key.emoji,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(height: 4),
                              // FIX 2: FittedBox shrinks the text if it's too
                              // wide rather than overflowing the card.
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '₹${entry.value.toStringAsFixed(0)}',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                entry.key.label,
                                style: theme.textTheme.labelSmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],

              // === RECENT TRANSACTIONS ===
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: theme.textTheme.titleSmall,
                      ),
                      if (state.expenses.isNotEmpty)
                        GestureDetector(
                          onTap: () =>
                              context.pushNamed(AppRouteName.expenseHistory),
                          child: Text(
                            'See All',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.gradientStart,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              if (state.isLoading)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              else if (state.expenses.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        const Text('💸', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          'No expenses yet',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap "Add Expense" to get started',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final expense = state.expenses[i];
                      return ExpenseItemWidget(
                        expense: expense,
                        index: i,
                        onDelete: () => context
                            .read<ExpenseCubit>()
                            .deleteExpense(expense.id!),
                      );
                    },
                    childCount: state.expenses.length > 5
                        ? 5
                        : state.expenses.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(AppRouteName.addExpense),
        backgroundColor: AppColors.gradientStart,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
