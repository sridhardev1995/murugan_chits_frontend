import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_murugan_chits/screens/auth/auth_controller.dart';
import 'package:sri_murugan_chits/utils/colors/app_colors.dart';
import 'package:sri_murugan_chits/utils/global/app_text_style.dart';

/// Brand colors taken from the logo.
/// Better: move these two into AppColors (see note in chat).
class _Brand {
  static const Color navy = Color(0xFF0A2A5C);
  static const Color gold = Color(0xFFC9971C);
  static const Color goldDark = Color(0xFFA67508);
}

class LoginScreen extends GetView<AuthController> {
  LoginScreen({super.key});

  // Remove the default text before release
  final _usernameController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController(text: 'admin123');

  void _submit() {
    controller.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyle.regular.copyWith(color: Colors.grey),
      prefixIcon: Icon(icon, color: _Brand.navy),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: border(Colors.grey.shade300),
      enabledBorder: border(Colors.grey.shade300),
      focusedBorder: border(_Brand.gold, 1.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                // Logo (no circle, no background, no shadow)
                Image.asset(
                  'assets/images/logo.png',
                  width: width * 0.7 > 300 ? 300 : width * 0.7,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),

                // Gold divider accent
                Container(
                  width: 60,
                  height: 3,
                  decoration: BoxDecoration(
                    color: _Brand.gold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 18),

                // Title
                Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.heading.copyWith(
                    fontSize: 24,
                    color: _Brand.navy,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Login to continue',
                  style: AppTextStyle.regular.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Username
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Username',
                    style: AppTextStyle.semiBold.copyWith(color: _Brand.navy),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _usernameController,
                  style: AppTextStyle.regular,
                  cursorColor: _Brand.gold,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration(
                    hint: 'Enter username',
                    icon: Icons.person_outline,
                  ),
                ),
                const SizedBox(height: 18),

                // Password (only this part needs Obx)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Password',
                    style: AppTextStyle.semiBold.copyWith(color: _Brand.navy),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => TextField(
                    controller: _passwordController,
                    style: AppTextStyle.regular,
                    cursorColor: _Brand.gold,
                    obscureText: !controller.isPasswordVisible.value,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    decoration: _decoration(
                      hint: 'Enter password',
                      icon: Icons.lock_outline,
                      suffix: IconButton(
                        onPressed: controller.togglePasswordVisibility,
                        icon: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Login button
                Obx(
                  () => controller.isLoading.value
                      ? const SizedBox(
                          height: 50,
                          width: 50,
                          child: CircularProgressIndicator(
                            color: _Brand.gold,
                          ),
                        )
                      : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _Brand.navy,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Login',
                              style: AppTextStyle.semiBoldLarge.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 12),

                // Change password / Forgot password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Get.toNamed('/change-password'),
                      child: Text(
                        'Change Password',
                        style: AppTextStyle.semiBold.copyWith(
                          color: _Brand.navy,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed('/forgot-password'),
                      child: Text(
                        'Forgot Password?',
                        style: AppTextStyle.semiBold.copyWith(
                          color: _Brand.goldDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Footer
                Text(
                  'Developed by Starwick Infotech',
                  style: AppTextStyle.semiBold.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}