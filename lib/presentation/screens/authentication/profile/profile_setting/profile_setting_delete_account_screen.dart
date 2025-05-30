import 'package:flutter/material.dart';
import 'package:finance_management/presentation/widgets/widget/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_management/presentation/bloc/user/user_bloc.dart';
import 'package:finance_management/data/model/user/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:finance_management/presentation/screens/authentication/profile/profile_setting/profile_setting_screen.dart';
import 'package:finance_management/presentation/screens/authentication/profile/profile_main/profile_splash_screen.dart';

class ProfileSettingDeleteAccountScreen extends StatefulWidget {
  static const String routeName = '/profile-setting-delete-account';
  const ProfileSettingDeleteAccountScreen({super.key});

  @override
  State<ProfileSettingDeleteAccountScreen> createState() =>
      _ProfileSettingDeleteAccountScreenState();
}

class _ProfileSettingDeleteAccountScreenState
    extends State<ProfileSettingDeleteAccountScreen> {
  final _passwordController = TextEditingController();
  bool _obscure = true;
  String? _errorText;
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
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onDeletePressed() async {
    if (_user == null) return;

    try {
      // Reauthenticate user before deleting account
      final credential = EmailAuthProvider.credential(
        email: _user!.email,
        password: _passwordController.text,
      );
      await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(
        credential,
      );

      setState(() => _errorText = null);
      _showConfirmDialog();
    } on FirebaseAuthException {
      setState(() => _errorText = 'Invalid password');
    }
  }

  Future<void> _deleteAccount() async {
    try {
      // Delete user from Firebase Auth
      await FirebaseAuth.instance.currentUser?.delete();

      // Delete user from Firestore and update state
      if (_user != null) {
        context.read<UserBloc>().add(DeleteUserEvent(_user!.id));
      }

      if (mounted) {
        context.go(
          ProfileSplashScreen.routeName,
          extra: 'Account deleted successfully!',
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

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Delete Account',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Are You Sure You Want To Log Out?\n\nBy deleting your account, you agree that you understand the consequences of this action and that you agree to permanently delete your account and all associated data.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _deleteAccount,
                    child: const Text(
                      'Yes, Delete Account',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.blackHeader,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      side: const BorderSide(color: Colors.grey),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => context.pop(),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.caribbeanGreen,
      body: Column(
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
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.go('/profile-setting-screen'),
                  ),
                  const Text(
                    'Delete Account',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Are You Sure You Want To Delete Your Account?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6F5E6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'This action will permanently delete all of your data, and you will not be able to recover it. Please keep the following in mind before proceeding:',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '• All your expenses, income and associated transactions will be eliminated.',
                          ),
                          Text(
                            '• You will not be able to access your account or any related information.',
                          ),
                          Text('• This action cannot be undone.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Please Enter Your Password To Confirm Deletion Of Your Account.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFE8F6EA),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(18)),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        errorText: _errorText,
                      ),
                    ),
                    const SizedBox(height: 32),
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
                        onPressed: _onDeletePressed,
                        child: const Text(
                          'Yes, Delete Account',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.blackHeader,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey,
                          side: const BorderSide(color: Colors.grey),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed:
                            () => context.go(ProfileSettingScreen.routeName),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
