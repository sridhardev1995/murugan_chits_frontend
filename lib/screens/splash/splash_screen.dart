import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sri_murugan_chits/services/api/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    _checkLogin();
  }

  // ============================================================
  // CHECK LOGIN
  // ============================================================

  Future<void> _checkLogin() async {
    await Future.delayed(
      const Duration(seconds: 2),
    );

    final token =
        await StorageService.getToken();

    final isLoggedIn =
        token != null && token.isNotEmpty;

    debugPrint(
      "================================",
    );

    debugPrint(
      "SPLASH LOGIN CHECK",
    );

    debugPrint(
      "TOKEN EXISTS: $isLoggedIn",
    );

    debugPrint(
      "TOKEN LENGTH: ${token?.length ?? 0}",
    );

    debugPrint(
      "================================",
    );

    if (!mounted) {
      return;
    }

    if (isLoggedIn) {
      // ========================================================
      // TOKEN EXISTS
      // ========================================================

      Get.offAllNamed("/dashboard");
    } else {
      // ========================================================
      // TOKEN NOT EXISTS
      // ========================================================

      Get.offAllNamed("/login");
    }
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 700,
          width: 350,
          child: Image.asset(
            'assets/images/splash_murugan.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}