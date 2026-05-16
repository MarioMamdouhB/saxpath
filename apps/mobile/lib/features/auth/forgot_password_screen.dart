import 'package:flutter/material.dart';
import 'package:saxpath_mobile/shared/services/auth_service.dart';
import 'package:saxpath_mobile/shared/widgets/primary_button.dart';
import 'package:saxpath_mobile/shared/widgets/sax_card.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _auth = AuthService();
  bool _isLoading = false;
  bool _emailSent = false;

  Future<void> _handleReset() async {
    if (_emailController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await _auth.resetPassword(_emailController.text.trim());
      setState(() => _emailSent = true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('استعادة كلمة المرور')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SaxCard(
            child: _emailSent ? _buildSuccessState() : _buildFormState(),
          ),
        ),
      ),
    );
  }

  Widget _buildFormState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.lock_reset_rounded, size: 64, color: Colors.orange),
        const SizedBox(height: 16),
        const Text('نسيت كلمة المرور؟', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('أدخل بريدك الإلكتروني وسنرسل لك رابطاً لتعيين كلمة مرور جديدة.', textAlign: TextAlign.center),
        const SizedBox(height: 24),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'البريد الإلكتروني', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 24),
        _isLoading 
          ? const CircularProgressIndicator()
          : PrimaryButton(label: 'إرسال رابط الاستعادة', onPressed: _handleReset),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.mark_email_read_rounded, size: 64, color: Colors.green),
        const SizedBox(height: 16),
        const Text('تم الإرسال!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('تفقد بريدك الإلكتروني لاتباع خطوات تعيين كلمة المرور الجديدة.', textAlign: TextAlign.center),
        const SizedBox(height: 24),
        PrimaryButton(label: 'العودة للدخول', onPressed: () => Navigator.pop(context)),
      ],
    );
  }
}
