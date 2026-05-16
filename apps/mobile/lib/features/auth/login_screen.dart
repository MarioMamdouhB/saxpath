import 'package:flutter/material.dart';
import 'package:saxpath_mobile/data/saxpath_api_client.dart';
import 'package:saxpath_mobile/features/shell/main_app_shell.dart';
import 'package:saxpath_mobile/features/auth/forgot_password_screen.dart';
import 'package:saxpath_mobile/shared/services/auth_service.dart';
import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';
import 'package:saxpath_mobile/shared/widgets/saxpath_brand_mark.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = AuthService();
  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await _auth.signIn(_emailController.text, _passwordController.text);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في تسجيل الدخول: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SaxCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SaxPathBrandMark(),
                const SizedBox(height: 32),
                const Text('تسجيل الدخول لسحابة SaxPath', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'البريد الإلكتروني', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'كلمة المرور', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 24),
                _isLoading 
                  ? const CircularProgressIndicator()
                  : PrimaryButton(label: 'دخول', onPressed: _handleSignIn),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    // BYPASS: Direct entry for demo
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => MainAppShell(apiClient: SaxPathApiClient()))
                    );
                  },
                  child: const Text('دخول كضيف (تجربة سريعة)'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
                  }, 
                  child: const Text('نسيت كلمة المرور؟')
                ),
                TextButton(onPressed: () {}, child: const Text('إنشاء حساب جديد')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
