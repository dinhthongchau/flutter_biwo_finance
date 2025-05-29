import 'dart:io';
import 'package:finance_management/presentation/bloc/user/user_bloc.dart';
import 'package:finance_management/presentation/shared_data.dart';
import 'package:finance_management/presentation/widgets/widget/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:finance_management/presentation/bloc/notification/notification_bloc.dart';
import 'package:finance_management/presentation/bloc/notification/notification_state.dart';
import 'package:finance_management/presentation/bloc/notification/notification_event.dart';
// TODO: import bottom navigation bar widget nếu có

class ProfileScreen extends StatefulWidget {
  static const String routeName = "/profile-screen";
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAvatar(UserLoaded state) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return;
    if (picked != null) {
      final updatedUser = state.user.copyWith(avatarPath: picked.path);
      context.read<UserBloc>().add(UpdateUserEvent(updatedUser));
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'End Session',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Are you sure you want to log out?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.caribbeanGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          context.pop();
                          context.go('/login-screen');
                        },
                        child: const Text(
                          'Yes, End Session',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.caribbeanGreen,
                          side: const BorderSide(
                            color: AppColors.caribbeanGreen,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => context.pop(),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is UserLoaded) {
          final user = state.user;
          return Scaffold(
            backgroundColor: AppColors.caribbeanGreen,
            body: Column(
              children: [
                // 1. AppBar (Profile + notification)
                const ProfileAppBar(),
                // 2. Stack để avatar nổi giữa 2 nền, còn lại là honeydew bo tròn
                Expanded(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      // Nền honeydew bo tròn lớn phía trên
                      Container(
                        margin: const EdgeInsets.only(top: 80),
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: AppColors.honeydew,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 70),
                            // 3. Tên, ID
                            ProfileAvatarName(user: user),
                            const SizedBox(height: 32),
                            // 4. Menu
                            ProfileMenuList(onLogout: _showLogoutDialog),
                          ],
                        ),
                      ),
                      // Avatar nổi hoàn toàn trong nền honeydew
                      Positioned(
                        top: 30,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 48,
                                backgroundColor: AppColors.caribbeanGreen,
                                backgroundImage:
                                    user.avatarPath != null
                                        ? FileImage(File(user.avatarPath!))
                                        : null,
                                child:
                                    user.avatarPath == null
                                        ? Text(
                                          user.fullName[0].toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 40,
                                            color: Colors.white,
                                          ),
                                        )
                                        : null,
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _pickAvatar(state),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.lightBlue,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (state is UserError) {
          return Scaffold(body: Center(child: Text(state.message)));
        }
        return const Scaffold(
          body: Center(child: Text('Something went wrong')),
        );
      },
    );
  }
}

// Widget 1: AppBar
class ProfileAppBar extends StatelessWidget {
  const ProfileAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Giả sử bạn lấy chatRoomId từ UserBloc hoặc local storage, ví dụ:
    // final chatRoomId = context.select((UserBloc bloc) => bloc.state.chatRoomId);
    // Ở đây demo hardcode, bạn cần thay bằng lấy đúng chatRoomId thực tế
    // final chatRoomId = 'main_user_helper_chat_room';
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 36, left: 24, right: 24, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 40),
            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                return Stack(
                  children: [
                    IconButton(
                      icon: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.notifications_none,
                          color: Colors.black,
                        ),
                      ),
                      onPressed: () {
                        //!TODO later
                        // context.read<NotificationBloc>().add(
                        //   NotificationRead(),
                        // );
                        // Điều hướng sang màn hình notification để chọn phòng chat
                        context.go('/home-screen/notifications');
                      },
                    ),
                    //!TODO later
                    // if (state.hasNewMessage)
                    //   Positioned(
                    //     right: 10,
                    //     top: 10,
                    //     child: Container(
                    //       width: 12,
                    //       height: 12,
                    //       decoration: const BoxDecoration(
                    //         color: Colors.red,
                    //         shape: BoxShape.circle,
                    //       ),
                    //     ),
                    //   ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Widget 2: Avatar, tên, ID
class ProfileAvatarName extends StatelessWidget {
  final dynamic user;
  const ProfileAvatarName({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          user.fullName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.blackHeader,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'ID: ${user.id.padLeft(8, '0')}',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Widget 3: Menu
class ProfileMenuList extends StatelessWidget {
  final VoidCallback onLogout;
  const ProfileMenuList({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final userState = context.read<UserBloc>().state;
    String userId = '';
    if (userState is UserLoaded) {
      userId = userState.user.id;
    }
    return Column(
      children: [
        _buildMenuItem(
          Icons.person_outline,
          'Edit Profile',
          AppColors.lightBlue,
          () {
            //context.push('/profile-edit-screen?userId=$userId');
            context.push('${ProfileEditScreen.routeName}?userId=$userId');
          },
        ),
        _buildMenuItem(
          Icons.shield_outlined,
          'Security',
          AppColors.lightBlue,
          () {
            context.push('/profile-security-screen');
          },
        ),
        _buildMenuItem(
          Icons.settings_outlined,
          'Setting',
          AppColors.vividBlue,
          () {
            context.go('/profile-setting-screen');
          },
        ),
        _buildMenuItem(
          Icons.headset_mic_outlined,
          'Help',
          AppColors.lightBlue,
          () {
            context.go('/profile-help-faqs');
          },
        ),
        _buildMenuItem(Icons.logout, 'Logout', AppColors.lightBlue, onLogout),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 18),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.blackHeader,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
