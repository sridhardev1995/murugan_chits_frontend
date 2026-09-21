import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_murugan_chits/screens/dashboard.dart/dashboard_controller.dart';
import 'package:sri_murugan_chits/screens/master/diwali_entrollment/diwali_enrollment_view.dart';
import 'package:sri_murugan_chits/screens/settings/settings_screen.dart';
import 'package:sri_murugan_chits/utils/colors/app_colors.dart';
import 'package:sri_murugan_chits/utils/colors/app_gradients.dart';
import 'package:sri_murugan_chits/utils/global/app_text_style.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text("Sri Murugan Chits", style: AppTextStyle.heading),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.primaryGradient,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed('/login');
            },
            icon: const Icon(Icons.logout, color: AppColors.black),
          ),
        ],
      ),

      body: Obx(() {
  switch (controller.selectedIndex.value) {
    case 0:
      return _dashboardPage(context);

    case 1:
      return _customersPage(context);

    case 2:
      return _collectionsPage(context);

    case 3:
      return const DiwaliEnrollmentView(); // 👈 replaced reports

    case 4:
      return const SettingsScreen();

    default:
      return _dashboardPage(context);
  }
}),

      bottomNavigationBar: Obx(() {
        return Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.primaryGradient,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 10), // 👈 gap above icons
              child: BottomNavigationBar(
                currentIndex: controller.selectedIndex.value,
                onTap: controller.changeIndex,
                type: BottomNavigationBarType.fixed,
                iconSize: 25,
                backgroundColor: Colors.transparent,
                selectedItemColor: Colors.black,
                unselectedItemColor: Colors.black54,
                selectedFontSize: 12,
                unselectedFontSize: 11,
                elevation: 0,
                items: controller.bottomItems,
              ),
            ),
          ),
        );
      }),
    );
  }

  // ============================================================
  // DASHBOARD
  // ============================================================

  Widget _dashboardPage(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 10),

            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back 👋',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        'Admin',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Summary cards
            Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    title: 'Customers',
                    value: '125',
                    icon: Icons.people,
                    iconColor: Colors.blue,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _summaryCard(
                    title: 'Collections',
                    value: '₹45,250',
                    icon: Icons.currency_rupee,
                    iconColor: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    title: 'Pending',
                    value: '₹12,500',
                    icon: Icons.pending_actions,
                    iconColor: Colors.orange,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _summaryCard(
                    title: 'Schemes',
                    value: '8',
                    icon: Icons.receipt_long,
                    iconColor: Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _quickAction(
              icon: Icons.person_add_alt_1,
              title: 'Add Customer',
              subtitle: 'Create a new customer',
              color: Colors.blue,
              onTap: () {},
            ),

            const SizedBox(height: 10),

            _quickAction(
              icon: Icons.payments_outlined,
              title: 'Add Collection',
              subtitle: 'Record customer payment',
              color: Colors.green,
              onTap: () {},
            ),

            const SizedBox(height: 10),

            _quickAction(
              icon: Icons.receipt_long_outlined,
              title: 'View Reports',
              subtitle: 'Check collection reports',
              color: Colors.purple,
              onTap: () {
                controller.changeIndex(3);
              },
            ),

            const SizedBox(height: 25),

            const Text(
              'Recent Collections',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _recentCollection(
              name: 'Ramesh',
              amount: '₹2,500',
              date: '11 Sep 2026',
            ),

            _recentCollection(
              name: 'Kumar',
              amount: '₹1,500',
              date: '11 Sep 2026',
            ),

            _recentCollection(
              name: 'Suresh',
              amount: '₹3,000',
              date: '10 Sep 2026',
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CUSTOMERS
  // ============================================================

  Widget _customersPage(BuildContext context) {
    return _simplePage(
      icon: Icons.people,
      title: 'Customers',
      subtitle: 'Manage your customers',
    );
  }

  // ============================================================
  // COLLECTIONS
  // ============================================================

  Widget _collectionsPage(BuildContext context) {
    return _simplePage(
      icon: Icons.account_balance_wallet,
      title: 'Collections',
      subtitle: 'Manage customer collections',
    );
  }

  // ============================================================
  // REPORTS
  // ============================================================

  Widget _reportsPage(BuildContext context) {
    return _simplePage(
      icon: Icons.bar_chart,
      title: 'Reports',
      subtitle: 'View collection reports',
    );
  }

  // ============================================================
  // PROFILE
  // ============================================================

  Widget _profilePage(BuildContext context) {
    return _simplePage(
      icon: Icons.person,
      title: 'Profile',
      subtitle: 'Manage your account',
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            height: 42,
            width: 42,

            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(icon, color: iconColor, size: 22),
          ),

          const SizedBox(height: 14),

          Text(
            title,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 5),

          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK ACTION
  // ============================================================

  Widget _quickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(16),

      child: Container(
        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,

              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),

              child: Icon(icon, color: color),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // RECENT COLLECTION
  // ============================================================

  Widget _recentCollection({
    required String name,
    required String amount,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: const Color(0xFFE8F0FE),

            child: Text(
              name.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),

                const SizedBox(height: 4),

                Text(
                  date,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          Text(
            amount,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SIMPLE PAGE
  // ============================================================

  Widget _simplePage({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              height: 80,
              width: 80,

              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(25),
              ),

              child: Icon(icon, size: 40, color: const Color(0xFF2563EB)),
            ),

            const SizedBox(height: 20),

            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
