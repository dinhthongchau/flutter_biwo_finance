import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

enum AppEnvironment { dev, prod }

AppEnvironment currentEnvironment = AppEnvironment.dev;

void customPrint(String message) {
  if (kIsWeb) {
    debugPrint('WEB: $message');
  }
  if (kDebugMode && currentEnvironment == AppEnvironment.dev) {
    debugPrint('🔍 $message');
  }
}

class LoadingUtils {
  static OverlayEntry? _overlayEntry;

  static void showLoading(BuildContext context, bool isLoading) {
    if (!context.mounted) return;
    if (isLoading) {
      _showOverlay(context);
    } else {
      _hideOverlay();
    }
  }

  static void _showOverlay(BuildContext context) {
    _hideOverlay();
    _overlayEntry = OverlayEntry(
      builder:
          (context) =>
          Stack(
            children: [
              const Opacity(
                opacity: 0.5,
                child: ModalBarrier(dismissible: false, color: Colors.black),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildSpinKitSpinningLines(),
                    const SizedBox(height: 15),
                    // Scaffold(
                    //   body: Text(
                    //     "Loading...",
                    //     style: TextStyle(color: AppColors.caribbeanGreen, fontWeight: FontWeight.bold),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }


  static void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
  static Widget buildSpinKitSpinningLines() {
    return const SpinKitSpinningLines(
      color: AppColors.caribbeanGreen,
      size: 40.0,
      lineWidth: 3.0,
    );
  }
  static Widget buildSpinKitSpinningLinesWhite() {
    return const SpinKitSpinningLines(
      color: AppColors.honeydew,
      size: 40.0,
      lineWidth: 3.0,
    );
  }
}


class DialogUtils {
  static void isErrorDialog(BuildContext context, String? errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.redAccent),
              SizedBox(width: 8),
              Text('Error', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(errorMessage ?? 'An error occurred of isErrorDialog' , style: const TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                context.pop();
              },
              child: const Text('OK'),
            ),
          ],
          backgroundColor: Colors.white,
          elevation: 8,
        );
      },
    );
  }

  static Future<bool?> showDeleteConfirmationDialog(BuildContext context, {
    String title = 'Xác nhận xóa',
    String content = 'Bạn có chắc chắn muốn xóa mục này không?',
    String cancelText = 'Hủy',
    String confirmText = 'Xóa',
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_rounded, color: AppColors.redColor),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            content,
            style: const TextStyle(color: AppColors.fenceGreen),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => context.pop(false),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.fenceGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                cancelText,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            ElevatedButton(
              onPressed: () => context.pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                confirmText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<void> isSuccessDialog(BuildContext context,
      String successMessage,) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green),
              SizedBox(width: 8),
              Text('Success', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(successMessage, style: const TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                context.pop();
              },
              child: const Text('OK'),
            ),
          ],
          backgroundColor: Colors.white,
          elevation: 8,
        );
      },
    );
  }

  static Future<void> isConfirmDialog(BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Row(
            children: [
              const Icon(Icons.help_outline, color: Colors.blue),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(message, style: const TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black54,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                context.pop();
              },
              child: Text(cancelText),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                //context.pop();
                onConfirm();
              },
              child: Text(confirmText),
            ),
          ],
          backgroundColor: Colors.white,
          elevation: 8,
        );
      },
    );
  }
}

class NumberFormatUtils {
  static String formatAmount(num amount) {
    final numberFormat = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 0,
    );
    return numberFormat.format(amount.abs());
  }

  static String formatCurrency(int amount) {
    return '\$${NumberFormat('#,###', 'en_US').format(amount.abs())}';
  }
}

class SnackbarUtils {
  static void showNoticeSnackbar(BuildContext context,
      String message,
      bool isError, {
        int durationSeconds = 3,
      }) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: <Widget>[
              // Thêm <Widget>
              Expanded(
                flex: 2,
                child: Icon(
                  isError ? Icons.error_outline_rounded : Icons.done_outline,
                  color: Colors.white,
                ),
              ),
              Expanded(
                flex: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Thêm <Widget>
                    Text(
                      isError ? 'Error' : 'Success',
                      style: const TextStyle(
                        // Thêm const
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(message),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: Duration(seconds: durationSeconds),
          action: SnackBarAction(
            label: 'Close',
            textColor: Colors.white,
            onPressed: () {},
          ),
          behavior: SnackBarBehavior.floating,
          // Đã sửa thành fixed
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(10), // Thêm const
        ),
      );
  }
}

class CategoryIconUtils {
  static String getCategoriesIconPath(String categoryType, MoneyType moneyType) {
    if (moneyType == MoneyType.income) {
      switch (categoryType) {
        case 'Salary':
          return Assets.iconComponents.salaryWhite.path;
        case 'Other Income':
          return Assets.iconComponents.income.path;
        default:
          return Assets.iconComponents.income.path;
      }
    } else if (moneyType == MoneyType.save) {
      switch (categoryType) {
        case 'Travel':
          return Assets.iconComponents.travel.path;
        case 'New House':
          return Assets.iconComponents.newHome.path;
        case 'Wedding':
          return Assets.iconComponents.weddingDay.path;
        case 'Other Savings':
          return Assets.iconComponents.salaryWhite.path;
        default:
          return Assets.iconComponents.salaryWhite.path;
      }
    } else {
      switch (categoryType) {
        case 'Food':
          return Assets.iconComponents.vector1.path;
        case 'Transport':
          return Assets.iconComponents.vector2.path;
        case 'Medicine':
          return Assets.iconComponents.vector4.path;
        case 'Groceries':
          return Assets.iconComponents.groceriesWhite.path;
        case 'Rent':
          return Assets.iconComponents.rentWhite.path;
        case 'Gifts':
          return Assets.iconComponents.vector5.path;
        case 'Entertainment':
          return Assets.iconComponents.vector6.path;
        default:
          return Assets.iconComponents.expense.path;
      }
    }
  }
}
