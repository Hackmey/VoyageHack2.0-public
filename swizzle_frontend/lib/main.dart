import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:swizzle_frontend/screens/splash.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashPage(),
      theme: ThemeData.light(), // Ensures dark theme behavior
    );
  }
}

