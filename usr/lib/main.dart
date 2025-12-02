import 'package:flutter/material.dart';
import 'screens/menu_screen.dart';
import 'screens/battle_screen.dart';

void main() {
  runApp(const UndertaleOrangeApp());
}

class UndertaleOrangeApp extends StatelessWidget {
  const UndertaleOrangeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Undertale Orange',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Courier', // خط يشبه الستايل القديم
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MenuScreen(),
        '/battle': (context) => const BattleScreen(),
      },
    );
  }
}
