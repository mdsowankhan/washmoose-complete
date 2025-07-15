import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _foamController;
  List<FoamBubble> _foamBubbles = [];
  List<SnowFoam> _snowFoam = [];
  final Random _random = Random();
  
  @override
  void initState() {
    super.initState();
    
    // Initialize foam animation
    _foamController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    // Create foam bubbles and snow foam
    _createFoamBubbles();
    _createSnowFoam();
    
    // Simple 3 second delay then navigate
    Timer(const Duration(seconds: 3), _handleNavigation);
  }
  
  void _createFoamBubbles() {
    _foamBubbles = List.generate(15, (index) {
      return FoamBubble(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 8 + 4,
        speed: _random.nextDouble() * 0.3 + 0.1,
        opacity: _random.nextDouble() * 0.4 + 0.2,
      );
    });
  }
  
  void _createSnowFoam() {
    _snowFoam = List.generate(12, (index) {
      return SnowFoam(
        x: _random.nextDouble(),
        y: _random.nextDouble() * -0.5, // Start above screen
        width: _random.nextDouble() * 25 + 15, // Width 15-40
        height: _random.nextDouble() * 15 + 8, // Height 8-23
        speed: _random.nextDouble() * 0.2 + 0.05, // Slower than bubbles
        opacity: _random.nextDouble() * 0.6 + 0.3, // More visible
        drift: _random.nextDouble() * 0.02 + 0.01, // Horizontal drift
      );
    });
  }
  
  Future<void> _handleNavigation() async {
    if (!mounted) return;
    
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser != null) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? userRole = prefs.getString('user_role');
        
        if (userRole == 'customer') {
          Navigator.of(context).pushReplacementNamed('/customer_main');
        } else if (userRole == 'washer') {
          Navigator.of(context).pushReplacementNamed('/washer_main');
        } else {
          Navigator.of(context).pushReplacementNamed('/choose_role');
        }
      } else {
        Navigator.of(context).pushReplacementNamed('/choose_role');
      }
    } catch (e) {
      print('Navigation error: $e');
      Navigator.of(context).pushReplacementNamed('/choose_role');
    }
  }

  @override
  void dispose() {
    _foamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF00C2CB), // Your teal
                  Color(0xFF1E2B3C), // Your dark blue
                ],
              ),
            ),
          ),
          
          // Foam effects layer (bubbles + snow foam)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _foamController,
              builder: (context, child) {
                return CustomPaint(
                  painter: FoamEffectsPainter(
                    bubbles: _foamBubbles, 
                    snowFoam: _snowFoam,
                    animationValue: _foamController.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Top spacer
                const Spacer(flex: 2),
                
                // Logo section
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(80),
                      child: Image.asset(
                        'assets/images/washmoose_logo.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.local_car_wash,
                            size: 80,
                            color: Color(0xFF1E2B3C),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // App name
                const Text(
                  'WashMoose',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Tagline
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: const Text(
                    'Car washing, at your doorstep anytime',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      height: 1.3,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const Spacer(flex: 1),
                
                // Loading section
                Column(
                  children: [
                    // Loading spinner
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Loading text
                    const Text(
                      'Loading...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                
                const Spacer(flex: 1),
                
                // Bottom section with company info
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Premium Mobile Car Wash Service',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sydney, Australia',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Version info
                      Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Foam bubble data class
class FoamBubble {
  double x;
  double y;
  final double size;
  final double speed;
  final double opacity;
  
  FoamBubble({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

// Snow foam data class - for thick car wash foam
class SnowFoam {
  double x;
  double y;
  final double width;
  final double height;
  final double speed;
  final double opacity;
  final double drift;
  double driftOffset = 0;
  
  SnowFoam({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.speed,
    required this.opacity,
    required this.drift,
  });
}

// Custom painter for all foam effects
class FoamEffectsPainter extends CustomPainter {
  final List<FoamBubble> bubbles;
  final List<SnowFoam> snowFoam;
  final double animationValue;
  
  FoamEffectsPainter({
    required this.bubbles,
    required this.snowFoam,
    required this.animationValue,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Draw snow foam first (background layer)
    for (SnowFoam foam in snowFoam) {
      // Update foam position
      foam.y += foam.speed * 0.015;
      foam.driftOffset += foam.drift;
      
      // Reset when foam goes off screen
      if (foam.y > 1.2) {
        foam.y = -0.3;
        foam.x = Random().nextDouble();
        foam.driftOffset = 0;
      }
      
      // Calculate position with drift
      final double actualX = (foam.x + sin(foam.driftOffset) * 0.08) * size.width;
      final double actualY = foam.y * size.height;
      
      // Create fluffy snow foam effect
      final Paint foamPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(foam.opacity),
            Colors.white.withOpacity(foam.opacity * 0.7),
            Colors.white.withOpacity(foam.opacity * 0.3),
            Colors.white.withOpacity(0.1),
          ],
          stops: const [0.0, 0.4, 0.7, 1.0],
        ).createShader(Rect.fromCenter(
          center: Offset(actualX, actualY),
          width: foam.width * 2,
          height: foam.height * 2,
        ));
      
      // Draw main foam blob (oval/irregular shape)
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(actualX, actualY),
          width: foam.width,
          height: foam.height,
        ),
        foamPaint,
      );
      
      // Add some smaller foam chunks around main blob
      for (int i = 0; i < 3; i++) {
        final double offsetX = actualX + (Random().nextDouble() - 0.5) * foam.width * 0.8;
        final double offsetY = actualY + (Random().nextDouble() - 0.5) * foam.height * 0.6;
        final double chunkSize = foam.width * (0.2 + Random().nextDouble() * 0.3);
        
        final Paint chunkPaint = Paint()
          ..color = Colors.white.withOpacity(foam.opacity * 0.6)
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(
          Offset(offsetX, offsetY),
          chunkSize,
          chunkPaint,
        );
      }
    }
    
    // Draw bubbles on top of snow foam
    for (FoamBubble bubble in bubbles) {
      // Update bubble position
      bubble.y -= bubble.speed * 0.012;
      
      // Reset bubble when it goes off top
      if (bubble.y < -0.1) {
        bubble.y = 1.1;
        bubble.x = Random().nextDouble();
      }
      
      final double actualX = bubble.x * size.width;
      final double actualY = bubble.y * size.height;
      
      // Create subtle foam bubble
      final Paint bubblePaint = Paint()
        ..color = Colors.white.withOpacity(bubble.opacity)
        ..style = PaintingStyle.fill;
      
      // Draw main bubble
      canvas.drawCircle(
        Offset(actualX, actualY),
        bubble.size,
        bubblePaint,
      );
      
      // Add small highlight
      final Paint highlightPaint = Paint()
        ..color = Colors.white.withOpacity(bubble.opacity * 0.8)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(actualX - bubble.size * 0.3, actualY - bubble.size * 0.3),
        bubble.size * 0.25,
        highlightPaint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}