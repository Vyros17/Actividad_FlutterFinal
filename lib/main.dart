import 'package:flutter/material.dart';
import 'package:yapchat/themeAndConstants/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yapchat/validation_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jrqltbbprszqvxlleggb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpycWx0YmJwcnN6cXZ4bGxlZ2diIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM2NDk3OTMsImV4cCI6MjA1OTIyNTc5M30.ASn7r4VGTEejnXllHXtcE8BOvtyio3dEiKjsiii5PLk',
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    return MaterialApp(
        title: 'YapChat',
        themeMode: themeMode,
        theme: lightTheme,
        darkTheme: darkTheme,
        home: const ValidationPage());
  }
}
