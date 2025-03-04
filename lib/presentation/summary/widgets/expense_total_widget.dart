import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/adapters.dart';

import '../../../common/constants/extensions.dart';
import '../../../common/enum/box_types.dart';
import '../../../common/widgets/material_you_card_widget.dart';
import '../../../data/expense/model/expense.dart';
import 'expense_total_for_month_widget.dart';
import 'total_balance_widget.dart';

class ExpenseTotalWidget extends StatelessWidget {
  const ExpenseTotalWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Expense>>(
      valueListenable:
          Hive.box<Expense>(BoxType.expense.stringValue).listenable(),
      builder: (_, value, child) {
        final expenses = value.values.toList();
        final totalIncome = expenses.totalIncome - expenses.totalExpense;
        final thisMonthExpenses = expenses.thisMonthExpense;
        final thisMonthIncome = expenses.thisMonthIncome;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: MaterialYouCard(
            child: Padding(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TotalBalanceWidget(
                    title: AppLocalizations.of(context)!.totalBalanceLabel,
                    amount: totalIncome,
                  ),
                  const SizedBox(height: 24),
                  ExpsenseTotalForMonthWidget(
                    outcome: thisMonthExpenses,
                    income: thisMonthIncome,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
