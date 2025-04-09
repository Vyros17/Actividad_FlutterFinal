import 'package:flutter/material.dart';
import 'package:yapchat/chat_page.dart';
import 'package:yapchat/login_page.dart';
import 'package:yapchat/themeAndConstants/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key, required this.isRegistering}) : super(key: key);

  static Route<void> route({bool isRegistering = false}) {
    return MaterialPageRoute(
      builder: (context) => RegisterPage(isRegistering: isRegistering),
    );
  }

  final bool isRegistering;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  Future<void> _signUp(BuildContext context) async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    final email = _emailController.text;
    final password = _passwordController.text;
    final username = _usernameController.text;
    try {
      await supabase.auth.signUp(
          email: email, password: password, data: {'username': username});
      Navigator.of(context)
          .pushAndRemoveUntil(ChatPage.route(), (route) => false);
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      void _signUpWrapper() {
        _signUp(context);
      }

      final themeMode = ref.watch(themeNotifierProvider);
      final themeNotifier = ref.read(themeNotifierProvider.notifier);
      return Scaffold(
        appBar: AppBar(
          title: const Text('Registrar Perfil'),
          actions: [
            Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (value) => themeNotifier.toggleTheme(),
            )
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: formPadding,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  label: Text('Email'),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Requerido';
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              formSpacer,
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  label: Text('Contraseña'),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Requerido';
                  }
                  return null;
                },
              ),
              formSpacer,
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  label: Text('Usuario'),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Requerido';
                  }
                  return null;
                },
              ),
              formSpacer,
              ElevatedButton(
                onPressed: _isLoading ? null : _signUpWrapper,
                child: const Text('Registrar'),
              ),
              formSpacer,
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(LoginPage.route());
                },
                child: const Text('Ya tengo una cuenta'),
              )
            ],
          ),
        ),
      );
    });
  }
}
