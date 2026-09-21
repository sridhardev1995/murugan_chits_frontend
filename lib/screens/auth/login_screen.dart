import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sri_murugan_chits/screens/auth/auth_controller.dart';
import 'package:sri_murugan_chits/utils/colors/app_gradients.dart';
import 'package:sri_murugan_chits/utils/colors/gradient_button.dart';

class LoginScreen extends GetView<AuthController> {
  LoginScreen({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(
          () => Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              child: Column(
                children: [

                  // ==================================================
                  // LOGO
                  // ==================================================

                  Container(
                    height: 90,
                    width: 90,
                    decoration: const BoxDecoration(
                      gradient:
                          AppGradients.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: Colors.white,
                      size: 45,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // TITLE
                  // ==================================================

                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Login to continue",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // ==================================================
                  // EMAIL
                  // ==================================================

                  TextField(
                    controller: emailController,
                    keyboardType:
                        TextInputType.emailAddress,
                    textInputAction:
                        TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: "Email",
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // PASSWORD
                  // ==================================================

                  TextField(
                    controller: passwordController,
                    obscureText:
                        !controller.isPasswordVisible.value,
                    textInputAction:
                        TextInputAction.done,
                    onSubmitted: (_) {
                      controller.login(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                      );
                    },
                    decoration: InputDecoration(
                      hintText: "Password",

                      // Lock icon
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                      ),

                      // Show / Hide password
                      suffixIcon: IconButton(
                        onPressed: () {
                          controller
                              .togglePasswordVisibility();
                        },
                        icon: Icon(
                          controller
                                  .isPasswordVisible
                                  .value
                              ? Icons.visibility_outlined
                              : Icons
                                  .visibility_off_outlined,
                        ),
                      ),

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // LOGIN BUTTON
                  // ==================================================

                  controller.isLoading.value
                      ? const SizedBox(
                          height: 50,
                          width: 50,
                          child:
                              CircularProgressIndicator(),
                        )
                      : GradientButton(
                          text: "Login",
                          onTap: () {
                            controller.login(
                              emailController.text.trim(),
                              passwordController.text.trim(),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}