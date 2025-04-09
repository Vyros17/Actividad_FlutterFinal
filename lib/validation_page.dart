import 'package:flutter/material.dart';
import 'package:yapchat/chat_page.dart';
import 'package:yapchat/register_page.dart';
import 'package:yapchat/themeAndConstants/constants.dart';

class ValidationPage extends StatefulWidget {
  const ValidationPage({super.key});

  @override
  ValidationPageState createState() => ValidationPageState();
}

class ValidationPageState extends State<ValidationPage> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(Duration.zero);

    final session = supabase.auth.currentSession;
    if (session == null) {
      Navigator.of(context)
          .pushAndRemoveUntil(RegisterPage.route(), (route) => false);
    } else {
      Navigator.of(context)
          .pushAndRemoveUntil(ChatPage.route(), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: preloader);
  }
}
