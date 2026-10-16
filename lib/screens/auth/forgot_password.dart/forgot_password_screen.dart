import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'forgot_password_controller.dart';

class ForgotPasswordScreen extends GetView<ForgotPasswordController> {
  ForgotPasswordScreen({super.key});

  final TextEditingController usernameController =
      TextEditingController();

  final TextEditingController recoveryPinController =
      TextEditingController();

  final TextEditingController newPasswordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> formKey =
      GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Text(
          "Forgot Password",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),

                // =================================================
                // LOGO
                // =================================================

                Container(
                  height: 95,
                  width: 95,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF8B1C1C),
                        Color(0xFFB52B2B),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // =================================================
                // TITLE
                // =================================================

                const Text(
                  "Reset Your Password",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Enter your recovery details to reset your password",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 30),

                // =================================================
                // USERNAME
                // =================================================

                _buildLabel("Username"),

                const SizedBox(height: 8),

                TextFormField(
                  controller: usernameController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    hintText: "Enter username",
                    prefixIcon: Icons.person_outline,
                  ),
                ),

                const SizedBox(height: 20),

                // =================================================
                // RECOVERY PIN
                // =================================================

                _buildLabel("Recovery PIN"),

                const SizedBox(height: 8),

                TextFormField(
                  controller: recoveryPinController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  maxLength: 6,
                  obscureText: true,
                  decoration: _inputDecoration(
                    hintText: "Enter 6-digit recovery PIN",
                    prefixIcon: Icons.lock_outline,
                  ).copyWith(
                    counterText: "",
                  ),
                ),

                const SizedBox(height: 20),

                // =================================================
                // NEW PASSWORD
                // =================================================

                _buildLabel("New Password"),

                const SizedBox(height: 8),

                Obx(
                  () => TextFormField(
                    controller: newPasswordController,
                    obscureText:
                        !controller.isNewPasswordVisible.value,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration(
                      hintText: "Enter new password",
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        onPressed: controller
                            .toggleNewPasswordVisibility,
                        icon: Icon(
                          controller.isNewPasswordVisible.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // =================================================
                // CONFIRM PASSWORD
                // =================================================

                _buildLabel("Confirm Password"),

                const SizedBox(height: 8),

                Obx(
                  () => TextFormField(
                    controller: confirmPasswordController,
                    obscureText:
                        !controller
                            .isConfirmPasswordVisible
                            .value,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      _resetPassword();
                    },
                    decoration: _inputDecoration(
                      hintText: "Confirm new password",
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        onPressed: controller
                            .toggleConfirmPasswordVisibility,
                        icon: Icon(
                          controller
                                  .isConfirmPasswordVisible
                                  .value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // =================================================
                // RESET BUTTON
                // =================================================

                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF8B1C1C),
                        disabledBackgroundColor:
                            const Color(0xFFB87575),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                    AlwaysStoppedAnimation<
                                        Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              "Reset Password",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // =================================================
                // BACK TO LOGIN
                // =================================================

                TextButton.icon(
                  onPressed: () {
                    Get.back();
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 18,
                    color: Color(0xFF8B1C1C),
                  ),
                  label: const Text(
                    "Back to Login",
                    style: TextStyle(
                      color: Color(0xFF8B1C1C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // =================================================
                // FOOTER
                // =================================================

                const Text(
                  "Developed by StarWick Infotech",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =============================================================
  // RESET PASSWORD FUNCTION
  // =============================================================

  Future<void> _resetPassword() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final success =
        await controller.resetPassword(
      username: usernameController.text,
      recoveryPin: recoveryPinController.text,
      newPassword: newPasswordController.text,
      confirmPassword:
          confirmPasswordController.text,
    );

    if (success) {
      // Clear entered values
      usernameController.clear();
      recoveryPinController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      // Go back to login
      Get.offAllNamed("/login");
    }
  }

  // =============================================================
  // LABEL
  // =============================================================

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF333333),
        ),
      ),
    );
  }

  // =============================================================
  // INPUT DECORATION
  // =============================================================

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,

      hintStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 14,
      ),

      prefixIcon: Icon(
        prefixIcon,
        color: const Color(0xFF8B1C1C),
      ),

      suffixIcon: suffixIcon,

      filled: true,

      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE0E0E0),
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE0E0E0),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF8B1C1C),
          width: 1.5,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }
}