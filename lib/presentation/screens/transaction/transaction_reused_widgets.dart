import 'package:finance_management/presentation/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
    key: UniqueKey(),
    dismissThresholds: const {
      DismissDirection.startToEnd: 0.3,
      DismissDirection.endToStart: 0.3,
    },
    direction: DismissDirection.horizontal,
    confirmDismiss: (direction) async {
      if (direction == DismissDirection.endToStart) {
        return await DialogUtils.showDeleteConfirmationDialog(context);
      } else if (direction == DismissDirection.startToEnd) {
        final transaction = await context
            .read<TransactionBloc>()
            .getTransactionById(transactionId);
        if (transaction != null) {
          if (context.mounted) {
            _showEditTransactionDialog(context, transaction);
          }
        }
        return false;
      }
      return false;
    },
    onDismissed: (direction) {
      if (direction == DismissDirection.endToStart) {
        context.read<TransactionBloc>().add(
          DeleteTransactionEvent(transactionId),
        );
        final notificationModel = NotificationModel(
          iconPath: Assets.iconComponents.check.path,
          title: 'Transaction Deleted',
          subtitle: 'Deleted $title',
          time: DateFormat('HH:mm - dd/MM/yyyy').format(DateTime.now()),
          date: DateTime.now().toIso8601String(),
        );
        context.read<NotificationBloc>().add(
          AddNotification(notificationModel),
        );
        SnackbarUtils.showNoticeSnackbar(context, '$title deleted', false);
      }
    },
    background: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: AppColors.oceanBlue,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerLeft,
      child: const Icon(Icons.edit, color: Colors.white),
    ),
    secondaryBackground: Container(

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: AppColors.redColor,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerRight,
      child: const Icon(Icons.delete, color: Colors.white),
    ),
    child: AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
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
            Text(
              'Edit transaction',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 300),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: editedTitle,
                  decoration: InputDecoration(
                    labelText: 'Tiêu đề',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) => editedTitle = value,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: editedAmount,
                  decoration: InputDecoration(
                    labelText: 'Số tiền',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) => editedAmount = value,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: editedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: AppColors.caribbeanGreen,
                              onPrimary: Colors.white,
                            ),
                            dialogBackgroundColor: Colors.white,
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedDate != null) {
                      editedDate = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        editedDate.hour,
                        editedDate.minute,
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd/MM/yyyy').format(editedDate),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.calendar_today, color: AppColors.caribbeanGreen),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: editedLabel,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Ghi chú',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) => editedLabel = value,
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => context.pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.oceanBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Hủy',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TransactionBloc>().add(
                EditTransactionEvent(
                  transaction.copyWith(
                    title: editedTitle,
                    amount:
                        (double.tryParse(editedAmount) ?? transaction.amount)
                            .toInt(),
                    time: editedDate,
                    note: editedLabel,
                  ),
                ),
              );

              final notificationModel = NotificationModel(
                iconPath: Assets.iconComponents.check.path,
                title: 'Transaction Edited',
                subtitle: 'Edited $editedTitle',
                time: DateFormat('HH:mm - dd/MM/yyyy').format(DateTime.now()),
                date: DateTime.now().toIso8601String(),
              );
              context.read<NotificationBloc>().add(
                AddNotification(notificationModel),
              );
              SnackbarUtils.showNoticeSnackbar(context, 'Đã chỉnh sửa', false);
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.caribbeanGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Lưu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
        colorFilter: const ColorFilter.mode(
          AppColors.honeydew,
          BlendMode.srcIn,
        ),
      ),
    ),
  );
}
