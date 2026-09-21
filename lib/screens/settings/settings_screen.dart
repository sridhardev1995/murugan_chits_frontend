import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_murugan_chits/utils/global/app_text_style.dart';
import 'settings_controller.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case "people":
        return Icons.people_alt_outlined;

      case "festival":
        return Icons.local_fire_department_outlined;

      case "person_add":
        return Icons.person_add_alt_1_outlined;

      default:
        return Icons.settings_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF6F7FB),

      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            // ======================================================
            // HEADER
            // ======================================================

            const SizedBox(height: 5),

            Text(
              "Settings",
              style: AppTextStyle.heading.copyWith(
                fontSize: 28,
                color: const Color(0xFF1F2937),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Manage your application",
              style: AppTextStyle.regular.copyWith(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 25),

            // ======================================================
            // SECTION TITLE
            // ======================================================

            Text(
              "Manage",
              style: AppTextStyle.semiBold.copyWith(
                fontSize: 15,
                color: const Color(0xFF6B7280),
              ),
            ),

            const SizedBox(height: 12),

            // ======================================================
            // SETTINGS MENUS
            // ======================================================

            ...List.generate(
              controller.settingsMenus.length,
              (index) {
                final menu =
                    controller.settingsMenus[index];

                return _buildSettingsCard(
                  context,
                  title: menu["title"],
                  subtitle: menu["subtitle"],
                  icon: _getIcon(menu["icon"]),
                  onTap: () {
                    controller.onMenuTap(
                      menu["route"],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SETTINGS CARD
  // ============================================================

  Widget _buildSettingsCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Row(
            children: [

              // ==================================================
              // ICON
              // ==================================================

              Container(
                width: 52,
                height: 52,

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF9800),
                      Color(0xFFFF5722),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),

                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 27,
                ),
              ),

              const SizedBox(width: 15),

              // ==================================================
              // TITLE + SUBTITLE
              // ==================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      title,
                      style: AppTextStyle.semiBoldLarge.copyWith(
                        fontSize: 17,
                        color: const Color(0xFF1F2937),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,
                      style: AppTextStyle.regularSmall.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // ARROW
              // ==================================================

              Container(
                height: 36,
                width: 36,

                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                ),

                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}