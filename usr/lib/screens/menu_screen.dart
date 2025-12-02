import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'UNDERTALE\nORANGE',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.orange,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                fontFamily: 'Courier',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'The Bravery Soul',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 100),
            const Text(
              '[ Press Start ]',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/battle');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text('START GAME'),
            ),
          ],
        ),
      ),
    );
  }
}
