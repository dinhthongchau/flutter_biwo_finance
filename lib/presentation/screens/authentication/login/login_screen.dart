import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_management/data/model/user/user_model.dart';
import 'package:finance_management/presentation/shared_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class LoginScreen extends StatefulWidget {
  static const String routeName = "/login-screen";

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isFacebookHovered = false;
  bool _isGoogleHovered = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = 'test2@gmail.com';
    _passwordController.text = 'password';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await url_launcher.launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .get();

        if (!userDoc.exists || userDoc.data() == null) {
          throw Exception('User document does not exist or is invalid');
        }

        final data = userDoc.data()!;
        final isHelper = data['helper'] == true;
        final userModel = UserModel(
          id: credential.user!.uid,
          fullName: data['fullName'] ?? '',
          email: data['email'] ?? '',
          mobile: data['mobile'] ?? '',
          dob: data['dob'] ?? '',
          password: '',
          helper: isHelper,
        );

        if (kIsWeb) {
          customPrint('Logged in on Web: ${credential.user!.uid}');
        } else {
          customPrint('Logged in on Mobile: ${credential.user!.uid}');
        }

        if (!mounted) return;
        context.read<UserBloc>().add(UpdateUserEvent(userModel));
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.message}')),
        );
        setState(() => _isLoading = false);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserLoaded) {
          context.go(HomeScreen.routeName);
        } else if (state is UserError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          setState(() {
            _isLoading = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.caribbeanGreen,
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  const LoginHeader(),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppColors.honeydew,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(48),
                          topRight: Radius.circular(48),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 32,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                LoginFormFields(
                                  emailController: _emailController,
                                  passwordController: _passwordController,
                                  obscurePassword: _obscurePassword,
                                  onTogglePassword: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                const SizedBox(height: 32),
                                Padding(
                                  padding: const EdgeInsets.only(top: 40),
                                  child: Column(
                                    children: [
                                      LoginButton(
                                        onPressed:
                                            _isLoading ? null : _submitForm,
                                        isLoading: _isLoading,
                                      ),
                                      const SizedBox(height: 8),
                                      ForgotPasswordButton(
                                        onPressed:
                                            _isLoading
                                                ? null
                                                : () {
                                                  context.go(
                                                    ForgetPasswordScreen
                                                        .routeName,
                                                  );
                                                },
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: SignUpButton(
                                    onPressed: () {
                                      context.go(SignUpScreen.routeName);
                                    },
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 20),
                                  child: FingerprintAccess(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: SocialLoginSection(
                                    isFacebookHovered: _isFacebookHovered,
                                    isGoogleHovered: _isGoogleHovered,
                                    onFacebookHover:
                                        (v) => setState(
                                          () => _isFacebookHovered = v,
                                        ),
                                    onGoogleHover:
                                        (v) => setState(
                                          () => _isGoogleHovered = v,
                                        ),
                                    onFacebookTap:
                                        () => _launchURL(
                                          'https://www.facebook.com',
                                        ),
                                    onGoogleTap:
                                        () => _launchURL(
                                          'https://www.google.com',
                                        ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 20),
                                  child: SignUpPrompt(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(child: LoadingUtils.buildSpinKitSpinningLines()),
              ),
          ],
        ),
      ),
    );
  }
}

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 32, bottom: 16),
      child: Text(
        'Welcome',
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppColors.blackHeader,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class LoginFormFields extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  const LoginFormFields({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Username Or Email',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.blackHeader,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: emailController,
          decoration: InputDecoration(
            hintText: 'example@example.com',
            filled: true,
            fillColor: AppColors.lightGreen,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'Password',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.blackHeader,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: passwordController,
          obscureText: obscurePassword,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.lightGreen,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: SvgPicture.asset(
                obscurePassword
                    ? Assets.functionalIcon.vector23.path
                    : Assets.functionalIcon.vector24.path,
                width: 15,
                height: 15,
                colorFilter: const ColorFilter.mode(
                  Color.fromARGB(255, 2, 2, 2),
                  BlendMode.srcIn,
                ),
              ),
              onPressed: onTogglePassword,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            return null;
          },
        ),
      ],
    );
  }
}

class LoginButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const LoginButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.caribbeanGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            elevation: 0,
          ),
          onPressed: onPressed,
          child:
              isLoading
                  ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                  : const Text(
                    'Log In',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackHeader,
                    ),
                  ),
        ),
      ),
    );
  }
}

class ForgotPasswordButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const ForgotPasswordButton({super.key, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onPressed,
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.blackHeader,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class SignUpButton extends StatelessWidget {
  final VoidCallback onPressed;
  const SignUpButton({super.key, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.lightGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            elevation: 0,
          ),
          onPressed: onPressed,
          child: const Text(
            'Sign Up',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.blackHeader,
            ),
          ),
        ),
      ),
    );
  }
}

class FingerprintAccess extends StatelessWidget {
  const FingerprintAccess({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: const TextSpan(
          style: TextStyle(fontSize: 16, color: AppColors.blackHeader),
          children: [
            TextSpan(text: 'Use '),
            TextSpan(
              text: 'Fingerprint',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
            TextSpan(text: ' To Access'),
          ],
        ),
      ),
    );
  }
}

class SocialLoginSection extends StatelessWidget {
  final bool isFacebookHovered;
  final bool isGoogleHovered;
  final Function(bool) onFacebookHover;
  final Function(bool) onGoogleHover;
  final VoidCallback onFacebookTap;
  final VoidCallback onGoogleTap;
  const SocialLoginSection({
    super.key,
    required this.isFacebookHovered,
    required this.isGoogleHovered,
    required this.onFacebookHover,
    required this.onGoogleHover,
    required this.onFacebookTap,
    required this.onGoogleTap,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('or sign up with', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => onFacebookHover(true),
              onExit: (_) => onFacebookHover(false),
              child: GestureDetector(
                onTap: onFacebookTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform:
                      Matrix4.identity()..scale(isFacebookHovered ? 1.2 : 1.0),
                  child: SvgPicture.asset(
                    Assets.iconComponents.facebook.path,
                    width: 36,
                    height: 36,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => onGoogleHover(true),
              onExit: (_) => onGoogleHover(false),
              child: GestureDetector(
                onTap: onGoogleTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform:
                      Matrix4.identity()..scale(isGoogleHovered ? 1.2 : 1.0),
                  child: SvgPicture.asset(
                    Assets.iconComponents.google.path,
                    width: 36,
                    height: 36,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SignUpPrompt extends StatelessWidget {
  const SignUpPrompt({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: AppColors.blackHeader),
          children: [
            const TextSpan(text: "Don't have an account? "),
            WidgetSpan(
              child: GestureDetector(
                onTap: () {
                  context.go(SignUpScreen.routeName);
                },
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
