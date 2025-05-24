import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

Widget buildTransactionItem({
  required BuildContext context,
  required int transactionId,
  required String title,
  required String iconPath,
  required String date,
  String? label,
  required String amount,
  required Color backgroundColor,
  bool showDividers = true,
}) {
  final amountColor =
  amount.startsWith('-') ? AppColors.redColor : AppColors.fenceGreen;
  final displayAmount = amount;

  return Dismissible(
    //key: ValueKey(transactionId),
    // Use transactionId as the key
    key: UniqueKey(),
    direction: DismissDirection.horizontal, // Allow both directions
    confirmDismiss: (direction) async {
      if (direction == DismissDirection.endToStart) {
        // Delete confirmation
        return await DialogUtils.showDeleteConfirmationDialog(context);
      } else if (direction == DismissDirection.startToEnd) {
        // Edit action
        final transaction = await context
            .read<TransactionBloc>()
            .getTransactionById(transactionId);
        if (transaction != null) {
          if ( context.mounted) {
            _showEditTransactionDialog(context, transaction);
          }

        }
        return false; // Prevent deletion on edit
      }
      return false; // Don't dismiss in other cases
    },
    onDismissed: (direction) {
      if (direction == DismissDirection.endToStart) {
        // Dispatch delete event using BlocProvider
        BlocProvider.of<TransactionBloc>(context)
            .add(DeleteTransactionEvent(transactionId));
        SnackbarUtils.showNoticeSnackbar(context, '$title deleted', false);
      }
      // No need to handle edit here, dialog handles it
    },
    background: Container(
      color: Colors.blue, // Edit background color
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerLeft,
      child: const Icon(Icons.edit, color: Colors.white), // Edit icon
    ),
    secondaryBackground: Container(
      color: AppColors.redColor, // Delete background color
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerRight,
      child: const Icon(Icons.delete, color: Colors.white), // Delete icon
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          _buildTransactionIcon(
            iconPath: iconPath,
            backgroundColor: backgroundColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.fenceGreen,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.oceanBlue,
                  ),
                ),
              ],
            ),
          ),
          if (showDividers)
            Container(
              width: 1,
              height: 40,
              color: AppColors.caribbeanGreen.withValues(alpha: 0.3),
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
          Expanded(
            child: Text(
              label ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.fenceGreen,
              ),
            ),
          ),
          if (showDividers)
            Container(
              width: 1,
              height: 40,
              color: AppColors.caribbeanGreen.withValues(alpha: 0.3),
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
          Expanded(
            child: Text(
              displayAmount,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: amountColor,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


Future<void> _showEditTransactionDialog(
    BuildContext context,
    TransactionModel transaction,
    ) async {
  String editedTitle = transaction.title;
  String editedAmount = transaction.amount.toString();
  DateTime editedDate = transaction.time;
  String editedLabel = transaction.note;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.edit_rounded, color: AppColors.caribbeanGreen),
            SizedBox(width: 8),
            Text('Edit transaction', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: editedTitle,
                decoration: InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onChanged: (value) => editedTitle = value,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: editedAmount,
                decoration: InputDecoration(
                  labelText: 'Số tiền',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onChanged: (value) => editedAmount = value,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: '${editedDate.year}-${editedDate.month}-${editedDate.day}',
                decoration: InputDecoration(
                  labelText: 'Ngày (YYYY-MM-DD)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onChanged: (value) {
                  try {
                    editedDate = DateTime.parse(value);
                  } catch (e) {
                    // Handle invalid date format
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: editedLabel,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Ghi chú',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onChanged: (value) => editedLabel = value,
              ),
              // Add more fields as needed
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => context.pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.oceanBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hủy', style: TextStyle(fontWeight: FontWeight.w500)),
          ),
          ElevatedButton(
            onPressed: () {
              // Dispatch event to update the transaction
              BlocProvider.of<TransactionBloc>(context).add(
                EditTransactionEvent(
                  transaction.copyWith(
                    title: editedTitle,
                    amount: (double.tryParse(editedAmount) ?? transaction.amount).toInt(),
                    time: editedDate,
                    note: editedLabel,
                  ),
                ),
              );
              SnackbarUtils.showNoticeSnackbar(context, 'Đã chỉnh sửa', false);
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.caribbeanGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Lưu', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      );
    },
  );
}

Widget _buildTransactionIcon({
  required String iconPath,
  required Color backgroundColor,
}) {
  return Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(
      child: SvgPicture.asset(
        iconPath,
        width: 20,
        height: 20,
        colorFilter: const ColorFilter.mode(AppColors.honeydew, BlendMode.srcIn),
      ),
    ),
  );
}