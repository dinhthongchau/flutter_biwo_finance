import 'package:finance_management/gen/assets.gen.dart';

String getExpenseIcon(String categoryType) {
  switch (categoryType) {
    case 'Groceries':
      return Assets.iconComponents.groceriesWhite.path;
    case 'Rent':
      return Assets.iconComponents.rentWhite.path;
    case 'Transport':
      return Assets.iconComponents.iconTransport.path;
    case 'Food':
      return Assets.iconComponents.groceriesWhite.path;
    case 'Medicine':
      return Assets.iconComponents.iconMedicine.path;
    case 'Gifts':
      return Assets.iconComponents.iconGift.path;
    case 'Entertainment':
      return Assets.iconComponents.iconEntertainment.path;
    case 'Travel':
      return Assets.iconComponents.travel.path;
    case 'New House':
      return Assets.iconComponents.newHome.path;
    case 'Wedding':
      return Assets.iconComponents.weddingDay.path;
    case 'Salary':
      return Assets.iconComponents.salaryWhite.path;
    case 'Other Income':
      return Assets.iconComponents.income.path;
    case 'Other Expense':
      return Assets.iconComponents.expense.path;
    case 'Other Savings':
      return Assets.iconComponents.travel.path;
    default:
      return Assets.iconComponents.expense.path;
  }
}

String getCategoryIconPath(String categoryType) {
  switch (categoryType) {
    case 'Travel':
      return Assets.iconComponents.travel.path;
    case 'New House':
      return Assets.iconComponents.newHome.path;
    case 'Wedding':
      return Assets.iconComponents.weddingDay.path;
    case 'Other Savings':
      return Assets.iconComponents.travel.path;
    default:
      return Assets.iconComponents.vector7.path;
  }
}