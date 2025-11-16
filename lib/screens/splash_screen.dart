import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../utils/theme_manager.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    // Start fade animation
    _animationController.forward();
    
    try {
      // Initialize app data
      await appProvider.initialize();
      
      // Wait for animation to complete
      await _animationController.forward();
      
      // Navigate to main screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      // Handle initialization error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize app: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: ThemeManager.getThemeGradient(appProvider.currentTheme),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App logo/icon
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(60),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.book,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // App title
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Text(
                      'MyDiary',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Subtitle
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Inspired by "Your Name"',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 64),
                  
                  // Loading indicator
                  if (appProvider.isLoading)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}