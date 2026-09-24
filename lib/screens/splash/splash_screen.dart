import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_murugan_chits/services/api/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _checkLogin();
  }

  Future<void> _checkLogin() async {
    // Splash image display time
    await Future.delayed(const Duration(seconds: 2));

    final token = await StorageService.getToken();

    debugPrint("SPLASH TOKEN: $token");

    if (token != null && token.isNotEmpty) {
      // Token exists -> Dashboard
      Get.offAllNamed("/dashboard");
    } else {
      // No token -> Login
      Get.offAllNamed("/login");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 700,
          width: 350,
          child: Image.asset(
            'assets/images/splash_murugan.png',
            fit: BoxFit.none,
          ),
        ),
      ),
    );
  }
}
