import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class AddTransactionScreen extends StatefulWidget {
  static const String routeName = "/add-transaction-screen";
  final MoneyType? initialMoneyType;
  final CategoryModel? initialSelectedCategory;

  const AddTransactionScreen({
    super.key,
    this.initialMoneyType,
    this.initialSelectedCategory,
  });

  @override
  AddTransactionScreenState createState() => AddTransactionScreenState();
}

class AddTransactionScreenState extends State<AddTransactionScreen> with AddTransactionScreenMixin {

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddTransactionBloc(
        initialMoneyType: widget.initialSelectedCategory?.moneyType ?? widget.initialMoneyType ?? MoneyType.save,
        initialSelectedCategory: widget.initialSelectedCategory,
      )..add(LoadCategoriesEvent(initialSelectedCategory: widget.initialSelectedCategory)),
      child: BlocListener<TransactionBloc, TransactionState>(
        listener: transactionBlocListener,
        child: Scaffold(
          appBar: buildAppBarTransaction(context),
          backgroundColor: AppColors.caribbeanGreen,
          body: Container(
              padding: SharedLayout.getScreenPadding(context),
              child: buildBody(context)),
        ),
      ),
    );
  }

}