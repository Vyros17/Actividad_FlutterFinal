import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yapchat/chat_page.dart';
import 'package:yapchat/themeAndConstants/constants.dart';
import 'package:yapchat/register_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const LoginPage());
  }

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signIn(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.of(context)
          .pushAndRemoveUntil(ChatPage.route(), (route) => false);
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      void signInWrapper() {
        _signIn(context);
      }

      final themeMode = ref.watch(themeNotifierProvider);
      final themeNotifier = ref.read(themeNotifierProvider.notifier);

      return Scaffold(
        appBar: AppBar(
          title: const Text('Iniciar Sesión'),
          actions: [
            Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (value) => themeNotifier.toggleTheme(),
            )
          ],
        ),
        body: ListView(
          padding: formPadding,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            formSpacer,
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            formSpacer,
            ElevatedButton(
              onPressed: _isLoading ? null : signInWrapper,
              child: const Text('Iniciar Sesión'),
            ),
            formSpacer,
            TextButton(
              onPressed: () {
                Navigator.of(context).push(RegisterPage.route());
              },
              child: const Text('Registrarme'),
            )
          ],
        ),
      );
    });
  }
}
