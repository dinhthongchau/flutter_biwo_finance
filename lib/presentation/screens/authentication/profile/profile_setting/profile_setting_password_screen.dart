import 'package:flutter/material.dart';
import 'package:finance_management/presentation/widgets/widget/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_management/presentation/bloc/user/user_bloc.dart';
import 'package:finance_management/data/model/user/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileSettingPasswordScreen extends StatefulWidget {
  static const String routeName = '/profile-setting-password';
  const ProfileSettingPasswordScreen({super.key});

  @override
  State<ProfileSettingPasswordScreen> createState() =>
      _ProfileSettingPasswordScreenState();
}

class _ProfileSettingPasswordScreenState
    extends State<ProfileSettingPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  UserModel? _user;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<UserBloc>().state;
    if (state is UserLoaded) {
      _user = state.user;
    }
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate() && _user != null) {
      try {
        // Reauthenticate user before changing password
        final credential = EmailAuthProvider.credential(
          email: _user!.email,
          password: _currentController.text,
        );
        await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(
          credential,
        );

        // Change password
        await FirebaseAuth.instance.currentUser?.updatePassword(
          _newController.text,
        );

        // Update user model
        final updatedUser = _user!.copyWith(password: _newController.text);
        context.read<UserBloc>().add(UpdateUserEvent(updatedUser));

        if (mounted) {
          context.go(
            '/profile-splash',
            extra: 'Password changed successfully!',
          );
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.caribbeanGreen,
      body: Column(
        children: [
          // AppBar
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
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.go('/profile-setting-screen'),
                  ),
                  const Text(
                    'Password Settings',
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
          // Nội dung
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 40),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.honeydew,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildPasswordField(
                        'Current Password',
                        _currentController,
                        _obscureCurrent,
                        () {
                          setState(() => _obscureCurrent = !_obscureCurrent);
                        },
                        isCurrent: true,
                      ),
                      const SizedBox(height: 24),
                      _buildPasswordField(
                        'New Password',
                        _newController,
                        _obscureNew,
                        () {
                          setState(() => _obscureNew = !_obscureNew);
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildPasswordField(
                        'Confirm New Password',
                        _confirmController,
                        _obscureConfirm,
                        () {
                          setState(() => _obscureConfirm = !_obscureConfirm);
                        },
                      ),
                      const SizedBox(height: 36),
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
                          onPressed: _changePassword,
                          child: const Text(
                            'Change Password',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool obscure,
    VoidCallback onToggle, {
    bool isCurrent = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFE8F6EA),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: onToggle,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            if (label == 'Confirm New Password' &&
                value != _newController.text) {
              return 'Passwords do not match';
            }
            if (label == 'New Password' && value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
      ],
    );
  }
}
