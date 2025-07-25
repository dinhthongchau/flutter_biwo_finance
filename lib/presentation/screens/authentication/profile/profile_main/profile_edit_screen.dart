import 'dart:io';
import 'package:finance_management/presentation/bloc/user/user_bloc.dart';
import 'package:finance_management/presentation/widgets/widget/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:finance_management/presentation/widgets/cubit/theme/theme_cubit.dart';
import 'package:go_router/go_router.dart';

class ProfileEditScreen extends StatefulWidget {
  static const String routeName = "/profile-edit";
  final int userId;

  const ProfileEditScreen({super.key, required this.userId});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  String? _username;
  String? _phone;
  String? _email;
  String? _avatarPath;
  bool _pushNoti = false;
  bool _darkTheme = false;

  @override
  void initState() {
    super.initState();
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded) {
      final user = userState.user;
      _username = user.fullName;
      _phone = user.mobile;
      _email = user.email;
      _avatarPath = user.avatarPath;
    }
  }

  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _avatarPath = picked.path;
      });
    }
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final userState = context.read<UserBloc>().state;
      if (userState is UserLoaded) {
        final updatedUser = userState.user.copyWith(
          fullName: _username,
          mobile: _phone,
          email: _email,
          avatarPath: _avatarPath,
        );
        context.read<UserBloc>().add(UpdateUserEvent(updatedUser));
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.caribbeanGreen,
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserLoaded) {
            final user = state.user;
            return Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 24,
                      left: 8,
                      right: 24,
                      bottom: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => context.pop(),
                        ),
                        const Text(
                          'Edit My Profile',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
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
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
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
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                const SizedBox(height: 70),

                                Text(
                                  _username ?? '',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.blackHeader,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ID:  0${user.id.toString().padLeft(7, '0')}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Account Settings',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.blackHeader,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                _buildTextField(
                                  label: 'Username',
                                  initialValue: _username,
                                  onSaved: (v) => _username = v,
                                ),
                                const SizedBox(height: 16),

                                _buildTextField(
                                  label: 'Phone',
                                  initialValue: _phone,
                                  keyboardType: TextInputType.phone,
                                  onSaved: (v) => _phone = v,
                                ),
                                const SizedBox(height: 16),

                                _buildTextField(
                                  label: 'Email Address',
                                  initialValue: _email,
                                  keyboardType: TextInputType.emailAddress,
                                  onSaved: (v) => _email = v,
                                  readOnly: true,
                                ),
                                const SizedBox(height: 24),

                                _buildSwitch(
                                  'Push Notifications',
                                  _pushNoti,
                                  (v) => setState(() => _pushNoti = v),
                                ),
                                const SizedBox(height: 8),

                                _buildSwitch('Turn Dark Theme', _darkTheme, (
                                  v,
                                ) {
                                  setState(() => _darkTheme = v);
                                  context.read<ThemeCubit>().toggleTheme(v);
                                }),
                                const SizedBox(height: 24),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.caribbeanGreen,
                                      foregroundColor: AppColors.blackHeader,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      textStyle: const TextStyle(
                                        color: AppColors.blackHeader,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: _updateProfile,
                                    child: const Text(
                                      'Update Profile',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.blackHeader,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                      ),

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
                                    _avatarPath != null
                                        ? FileImage(File(_avatarPath!))
                                        : null,
                                child:
                                    _avatarPath == null
                                        ? Text(
                                          (_username != null &&
                                                  _username!.isNotEmpty)
                                              ? _username![0].toUpperCase()
                                              : '',
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
                                onTap: _pickAvatar,
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
            );
          }
          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    String? initialValue,
    TextInputType? keyboardType,
    required FormFieldSetter<String> onSaved,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
        ),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: initialValue,
          keyboardType: keyboardType,
          onSaved: onSaved,
          readOnly: readOnly,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFE8F6EA),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.caribbeanGreen,
        ),
      ],
    );
  }
}
