import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> with TickerProviderStateMixin {
  // Game State
  double playerX = 0;
  double playerY = 0;
  final double boxSize = 250.0;
  final double playerSize = 20.0;
  int playerHP = 20;
  int maxHP = 20;
  bool isGameOver = false;
  
  // Movement
  bool moveUp = false;
  bool moveDown = false;
  bool moveLeft = false;
  bool moveRight = false;
  final double speed = 3.0;

  // Bullets
  List<Bullet> bullets = [];
  int frameCount = 0;
  late Ticker _ticker;

  @override
  void initState() {
    super.initState();
    // Start game loop
    _ticker = createTicker((elapsed) {
      if (!isGameOver) {
        _updateGame();
      }
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _updateGame() {
    setState(() {
      frameCount++;
      
      // 1. Move Player
      if (moveUp && playerY > -boxSize / 2 + playerSize / 2) playerY -= speed;
      if (moveDown && playerY < boxSize / 2 - playerSize / 2) playerY += speed;
      if (moveLeft && playerX > -boxSize / 2 + playerSize / 2) playerX -= speed;
      if (moveRight && playerX < boxSize / 2 - playerSize / 2) playerX += speed;

      // 2. Spawn Bullets
      if (frameCount % 40 == 0) {
        _spawnBulletPattern();
      }

      // 3. Update Bullets
      for (var i = bullets.length - 1; i >= 0; i--) {
        bullets[i].update();
        
        // Remove if out of bounds (simplified)
        if (bullets[i].y > boxSize || bullets[i].y < -boxSize || 
            bullets[i].x > boxSize || bullets[i].x < -boxSize) {
          bullets.removeAt(i);
          continue;
        }

        // Collision Detection
        if (_checkCollision(bullets[i])) {
          _takeDamage();
          bullets.removeAt(i);
        }
      }
    });
  }

  void _spawnBulletPattern() {
    // Simple pattern: Rain from top
    Random rng = Random();
    double startX = (rng.nextDouble() * boxSize) - (boxSize / 2);
    bullets.add(Bullet(x: startX, y: -boxSize / 2, dx: 0, dy: 3));
    
    // Sometimes spawn from sides
    if (rng.nextBool()) {
       double startY = (rng.nextDouble() * boxSize) - (boxSize / 2);
       bullets.add(Bullet(x: -boxSize / 2, y: startY, dx: 3, dy: 0));
    }
  }

  bool _checkCollision(Bullet b) {
    // Simple AABB collision
    double dist = sqrt(pow(b.x - playerX, 2) + pow(b.y - playerY, 2));
    return dist < (playerSize / 2 + 5); // 5 is bullet radius approx
  }

  void _takeDamage() {
    playerHP -= 3;
    if (playerHP <= 0) {
      playerHP = 0;
      isGameOver = true;
      _showGameOverDialog();
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(0),
        ),
        title: const Text('GAME OVER', style: TextStyle(color: Colors.red, fontFamily: 'Courier')),
        content: const Text('Stay Determined...', style: TextStyle(color: Colors.white, fontFamily: 'Courier')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to menu
            },
            child: const Text('RETRY', style: TextStyle(color: Colors.orange)),
          )
        ],
      ),
    );
  }

  // Keyboard handling for Web/Desktop
  void _handleKeyEvent(RawKeyEvent event) {
    bool isDown = event is RawKeyDownEvent;
    if (event.logicalKey == LogicalKeyboardKey.arrowUp || event.logicalKey == LogicalKeyboardKey.keyW) {
      moveUp = isDown;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown || event.logicalKey == LogicalKeyboardKey.keyS) {
      moveDown = isDown;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft || event.logicalKey == LogicalKeyboardKey.keyA) {
      moveLeft = isDown;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight || event.logicalKey == LogicalKeyboardKey.keyD) {
      moveRight = isDown;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            // Top Stats
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('YOU', style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
                  Text('LV 1', style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Courier')),
                  Row(
                    children: [
                      const Text('HP ', style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Courier')),
                      Container(
                        width: 100,
                        height: 20,
                        color: Colors.red,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: (playerHP / maxHP) * 100,
                            color: Colors.yellow,
                          ),
                        ),
                      ),
                      Text(' $playerHP / $maxHP', style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Courier')),
                    ],
                  ),
                ],
              ),
            ),
            
            // Enemy Area (Placeholder)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://placehold.co/150x150/000000/FFFFFF/png?text=Enemy', 
                      width: 150,
                      height: 150,
                      errorBuilder: (c, e, s) => const Icon(Icons.bug_report, color: Colors.white, size: 100),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "The enemy looks eager to fight!",
                        style: TextStyle(color: Colors.white, fontFamily: 'Courier'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Battle Box
            Container(
              width: boxSize + 10,
              height: boxSize + 10,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: ClipRect(
                child: Stack(
                  children: [
                    // Bullets
                    ...bullets.map((b) => Positioned(
                      left: (boxSize / 2) + b.x - 5, // Center offset
                      top: (boxSize / 2) + b.y - 5,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )),
                    
                    // Player Soul
                    Positioned(
                      left: (boxSize / 2) + playerX - (playerSize / 2),
                      top: (boxSize / 2) + playerY - (playerSize / 2),
                      child: Icon(
                        Icons.favorite,
                        color: Colors.orange,
                        size: playerSize,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton('FIGHT', Colors.orange),
                  _buildActionButton('ACT', Colors.orange),
                  _buildActionButton('ITEM', Colors.orange),
                  _buildActionButton('MERCY', Colors.orange),
                ],
              ),
            ),

            // Mobile Controls (Visible only if touch needed, but let's add them for safety)
            SizedBox(
              height: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                   // D-Pad
                   Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       GestureDetector(
                         onTapDown: (_) => moveUp = true,
                         onTapUp: (_) => moveUp = false,
                         child: const Icon(Icons.arrow_drop_up, color: Colors.grey, size: 50),
                       ),
                       Row(
                         children: [
                           GestureDetector(
                             onTapDown: (_) => moveLeft = true,
                             onTapUp: (_) => moveLeft = false,
                             child: const Icon(Icons.arrow_left, color: Colors.grey, size: 50),
                           ),
                           const SizedBox(width: 20),
                           GestureDetector(
                             onTapDown: (_) => moveRight = true,
                             onTapUp: (_) => moveRight = false,
                             child: const Icon(Icons.arrow_right, color: Colors.grey, size: 50),
                           ),
                         ],
                       ),
                       GestureDetector(
                         onTapDown: (_) => moveDown = true,
                         onTapUp: (_) => moveDown = false,
                         child: const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 50),
                       ),
                     ],
                   )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontFamily: 'Courier',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class Bullet {
  double x;
  double y;
  double dx;
  double dy;

  Bullet({required this.x, required this.y, required this.dx, required this.dy});

  void update() {
    x += dx;
    y += dy;
  }
}
