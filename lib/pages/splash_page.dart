import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/services/auth/auth_controller.dart';
import 'package:twinkle/themes/theme.dart';
import 'package:twinkle/routes/app_routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _loadingAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();

    // Auth
    _checkAuth();
  }

  void _checkAuth() async {
    await Future.delayed(Duration(seconds: 3));
    
    final authController = Get.put(AuthController(), permanent: true);
    
    if (authController.isAuthenticated) {
      Get.offAllNamed(AppRoutes.main);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double trackWidth = 250;
    double heartSize = 24;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          const Color.fromARGB(255, 216, 152, 230),
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 215, 186, 186),
                          blurRadius: 10,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite, 
                      size: 70, 
                      color: Colors.white),
                  ),

                  const SizedBox(height: 25),
                  Text(
                    "Twinkle",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.secondaryColor,
                          fontWeight: FontWeight.w900,
                        ),
                  ),

                  const SizedBox(height: 25),
                  Text(
                    "Find a new partner",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                  ),

                  const SizedBox(height: 50),

                  // PROGRESS BAR
                  SizedBox(
                    width: trackWidth,
                    height: 30,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // Track trắng mờ
                        Container(
                          height: 3,
                          width: trackWidth,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),

                        // Thanh progress hồng
                        Container(
                          height: 3,
                          width: _loadingAnimation.value * trackWidth,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 235, 108, 150),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),

                        // Trái tim
                        Positioned(
                          left: _loadingAnimation.value * (trackWidth - heartSize),
                          child: const Icon(
                            Icons.favorite,
                            color: Color.fromARGB(255, 235, 108, 150),
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
