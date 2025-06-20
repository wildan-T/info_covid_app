import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';
import 'auth_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final session = snapshot.data?.session;
          // Jika user sudah login (sebagai Admin)
          if (session != null) {
            return const HomeScreen(isAdmin: true);
          }
        }
        // Jika user belum login (sebagai Tamu)
        return const HomeScreen(isAdmin: false);
      },
    );
  }
}
