import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/home_map_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://egepekkxsjhulyodbpjx.supabase.co',
    anonKey: 'sb_publishable_V-S1qvGFMkxMDnEynjHpOg_X_0vV-3i',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Activity Buddy',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: AuthGate(),
    );
  }
}

// Checks if user is logged in
class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    return session != null ? HomeMapScreen() : LoginScreen();
  }
}