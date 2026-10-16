import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sri_murugan_chits/utils/colors/app_gradients.dart';
import 'package:sri_murugan_chits/utils/colors/gradient_button.dart';

import 'change_password_controller.dart';

class ChangePasswordScreen
    extends GetView<ChangePasswordController> {
  ChangePasswordScreen({super.key});

  final currentPasswordController =
      TextEditingController();

  final newPasswordController =
      TextEditingController();

  final confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Change Password",
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(
          () => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [

                // ==================================================
                // HEADER ICON
                // ==================================================

                Center(
                  child: Container(
                    height: 90,
                    width: 90,
                    decoration: const BoxDecoration(
                      gradient:
                          AppGradients.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      color: Colors.white,
                      size: 45,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 22,
                ),

                // ==================================================
                // TITLE
                // ==================================================

                const Center(
                  child: Text(
                    "Update Password",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                const Center(
                  child: Text(
                    "Create a new secure password",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 32,
                ),

                // ==================================================
                // CURRENT PASSWORD
                // ==================================================

                TextField(
                  controller:
                      currentPasswordController,
                  obscureText:
                      !controller
                          .isCurrentPasswordVisible
                          .value,
                  textInputAction:
                      TextInputAction.next,
                  decoration:
                      InputDecoration(
                    labelText:
                        "Current Password",
                    hintText:
                        "Enter current password",
                    prefixIcon:
                        const Icon(
                      Icons.lock_outline,
                    ),
                    suffixIcon:
                        IconButton(
                      onPressed:
                          controller
                              .toggleCurrentPasswordVisibility,
                      icon: Icon(
                        controller
                                .isCurrentPasswordVisible
                                .value
                            ? Icons
                                .visibility_outlined
                            : Icons
                                .visibility_off_outlined,
                      ),
                    ),
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                // ==================================================
                // NEW PASSWORD
                // ==================================================

                TextField(
                  controller:
                      newPasswordController,
                  obscureText:
                      !controller
                          .isNewPasswordVisible
                          .value,
                  textInputAction:
                      TextInputAction.next,
                  decoration:
                      InputDecoration(
                    labelText:
                        "New Password",
                    hintText:
                        "Enter new password",
                    prefixIcon:
                        const Icon(
                      Icons.lock_open_outlined,
                    ),
                    suffixIcon:
                        IconButton(
                      onPressed:
                          controller
                              .toggleNewPasswordVisibility,
                      icon: Icon(
                        controller
                                .isNewPasswordVisible
                                .value
                            ? Icons
                                .visibility_outlined
                            : Icons
                                .visibility_off_outlined,
                      ),
                    ),
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                // ==================================================
                // CONFIRM PASSWORD
                // ==================================================

                TextField(
                  controller:
                      confirmPasswordController,
                  obscureText:
                      !controller
                          .isConfirmPasswordVisible
                          .value,
                  textInputAction:
                      TextInputAction.done,
                  onSubmitted: (_) {
                    _submit();
                  },
                  decoration:
                      InputDecoration(
                    labelText:
                        "Confirm Password",
                    hintText:
                        "Re-enter new password",
                    prefixIcon:
                        const Icon(
                      Icons.verified_user_outlined,
                    ),
                    suffixIcon:
                        IconButton(
                      onPressed:
                          controller
                              .toggleConfirmPasswordVisibility,
                      icon: Icon(
                        controller
                                .isConfirmPasswordVisible
                                .value
                            ? Icons
                                .visibility_outlined
                            : Icons
                                .visibility_off_outlined,
                      ),
                    ),
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                // ==================================================
                // PASSWORD INFO
                // ==================================================

                Container(
                  padding:
                      const EdgeInsets.all(
                    14,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.grey.shade100,
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Colors.grey,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          "Password must contain at least 6 characters.",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 28,
                ),

                // ==================================================
                // UPDATE BUTTON
                // ==================================================

                controller.isLoading.value
                    ? const Center(
                        child:
                            CircularProgressIndicator(),
                      )
                    : GradientButton(
                        text:
                            "Update Password",
                        onTap: _submit,
                      ),

                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  void _submit() async {
    final success =
        await controller.changePassword(
      currentPassword:
          currentPasswordController.text,
      newPassword:
          newPasswordController.text,
      confirmPassword:
          confirmPasswordController.text,
    );

    if (success) {
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      await Future.delayed(
        const Duration(
          milliseconds: 500,
        ),
      );

      if (Get.isOverlaysOpen) {
        Get.back();
      }
    }
  }
}