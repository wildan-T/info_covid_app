import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://pmrmehlmgdnkakelmutd.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBtcm1laGxtZ2Rua2FrZWxtdXRkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA0MjQzMzEsImV4cCI6MjA2NjAwMDMzMX0.fvImycN4nh1M5jmb7te-51nsN3MwNetQz6kHS-PBFXo',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Info Covid Banten',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}
