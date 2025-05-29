import 'package:finance_management/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:finance_management/presentation/widgets/widget/app_colors.dart';
import 'package:go_router/go_router.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:finance_management/data/services/firebase_chat_service.dart';
import 'package:finance_management/data/model/chat/chat_room_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationScreen extends StatelessWidget {
  static const String routeName = '/notifications';

  const NotificationScreen({super.key});

  Future<List<ChatRoomModel>> _filterRoomsWithMessages(
      List<ChatRoomModel> rooms,
      ) async {
    List<ChatRoomModel> result = [];
    for (final room in rooms) {
      final messagesSnapshot =
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(room.id)
          .collection('messages')
          .limit(1)
          .get();
      if (messagesSnapshot.docs.isNotEmpty) {
        result.add(room);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    if (userId == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<List<ChatRoomModel>>(
        stream: FirebaseChatService().chatRoomsForUserStream(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final chatRooms = snapshot.data!;
          return FutureBuilder<List<ChatRoomModel>>(
            future: _filterRoomsWithMessages(chatRooms),
            builder: (context, filteredSnapshot) {
              if (!filteredSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final filteredRooms = filteredSnapshot.data!;
              if (filteredRooms.isEmpty) {
                return const Center(child: Text('No chat notifications.'));
              }
              return ListView.builder(
                itemCount: filteredRooms.length,
                itemBuilder: (context, i) {
                  final room = filteredRooms[i];
                  return ListTile(
                    title: Text('Chat with: ${room.helperId ?? 'No helper'}'),
                    subtitle: Text(room.lastMessage),
                    trailing: const Icon(Icons.chat_bubble_outline),
                    onTap: () {
                      context.go(
                        '/profile-online-support-helper-center?chatRoomId=${room.id}',
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: AppBar(
        backgroundColor: AppColors.caribbeanGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.honeydew),
          onPressed: () {
            context.pop();
          },
        ),
        title: const Center(
          child: Text(
            'Notification',
            style: TextStyle(
              color: AppColors.fenceGreen,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          SizedBox(
            width: 40,
            height: 40,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.honeydew,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                //  'assets/FunctionalIcon/Vector.svg',
                Assets.functionalIcon.vector.path,
                height: 19,
                width: 15,
              ),
            ),
          ),
          const SizedBox(width: 30),
        ],
      ),
    );
  }

  Widget _buildBody(List<dynamic> notificationData) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.honeydew,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 37, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
            notificationData.map((sectionData) {
              final String sectionTitle = sectionData['section'];
              final List<dynamic> items = sectionData['items'];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(sectionTitle),
                  ...items
                      .map((item) => _buildNotificationItem(item))
                      .toList(),
                  const SizedBox(height: 24),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.fenceGreen,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> data) {
    final String iconPath = data['iconPath'];
    final String title = data['title'];
    final String subtitle = data['subtitle'];
    final String time = data['time'];
    final Color iconColor = _getColorFromString(data['iconColor']);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(
                  alpha: (0.1 * 255).round().toDouble(),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SvgPicture.asset(
                iconPath,
                height: 24,
                width: 24,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.fenceGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.oceanBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: AppColors.oceanBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorFromString(String colorString) {
    switch (colorString) {
      case 'AppColors.caribbeanGreen':
        return AppColors.caribbeanGreen;
      case 'AppColors.fenceGreen':
        return AppColors.fenceGreen;
      case 'AppColors.honeydew':
        return AppColors.honeydew;
      case 'AppColors.oceanBlue':
        return AppColors.oceanBlue;
      case 'AppColors.lightBlue':
        return AppColors.lightBlue;
      case 'AppColors.vividBlue':
        return AppColors.vividBlue;
      case 'AppColors.lightGreen':
        return AppColors.lightGreen;
      case 'AppColors.blackHeader':
        return AppColors.blackHeader;
      default:
        return Colors.grey; // Default color if string is not recognized
    }
  }
}
