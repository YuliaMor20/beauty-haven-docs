import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();

    void resetPassword() {
      final email = emailController.text.trim();
      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Введите вашу электронную почту')),
        );
        return;
      }
      // Реализуйте логику отправки письма для восстановления пароля
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ссылка для восстановления пароля отправлена на почту')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Восстановление пароля'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Введите ваш адрес электронной почты, чтобы восстановить пароль.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Электронная почта',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: resetPassword,
              child: const Text('Восстановить пароль'),
            ),
          ],
        ),
      ),
    );
  }
}
