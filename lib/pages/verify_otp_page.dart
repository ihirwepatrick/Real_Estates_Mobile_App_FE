import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';

class VerifyOtpPage extends StatefulWidget {
  const VerifyOtpPage({
    super.key,
    required this.email,
    this.type = 'signup',
  });

  final String email;
  final String type;

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final _code = TextEditingController();
  bool _busy = false;
  bool _resending = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final token = _code.text.trim();
    if (token.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 6-digit code from your email')),
      );
      return;
    }
    setState(() => _busy = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.verifyOtp(
      email: widget.email,
      token: token,
      type: widget.type,
    );
    setState(() => _busy = false);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email verified — welcome!')),
      );
      context.go('/profile');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Invalid code')),
      );
    }
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.resendOtp(
      email: widget.email,
      type: widget.type == 'recovery' ? 'recovery' : 'signup',
    );
    setState(() => _resending = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'A new code was sent to ${widget.email}'
              : (auth.error ?? 'Could not resend'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRecovery = widget.type == 'recovery';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isRecovery ? 'Reset password' : 'Verify email'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.brand50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.mark_email_unread_outlined,
                      color: AppColors.brand600, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isRecovery
                          ? 'Enter the 6-digit code we sent to ${widget.email} to continue resetting your password.'
                          : 'We sent a 6-digit code to ${widget.email}. Enter it below to activate your account.',
                      style: const TextStyle(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: _code,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: 8,
              ),
              maxLength: 8,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Verification code',
                counterText: '',
                hintText: '••••••',
              ),
              onFieldSubmitted: (_) => _verify(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _busy ? null : _verify,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isRecovery ? 'Continue' : 'Verify & continue'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _resending ? null : _resend,
              child: Text(
                _resending ? 'Sending…' : 'Resend code',
                style: const TextStyle(color: AppColors.brand600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
