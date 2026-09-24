import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:sri_murugan_chits/screens/auth/auth_binding.dart';
import 'package:sri_murugan_chits/screens/auth/login_screen.dart';
import 'package:sri_murugan_chits/screens/dashboard.dart/dashboard_binding.dart'
    show DashboardBinding;
import 'package:sri_murugan_chits/screens/dashboard.dart/dashboard_view.dart';
import 'package:sri_murugan_chits/screens/master/customer/customer_binding.dart';
import 'package:sri_murugan_chits/screens/master/customer/customer_screen.dart';
import 'package:sri_murugan_chits/screens/master/diwali_entrollment/diwali_enrollment_binding.dart';
import 'package:sri_murugan_chits/screens/master/diwali_entrollment/diwali_enrollment_view.dart';
import 'package:sri_murugan_chits/screens/master/diwali_scheme/diwali_scheme_binding.dart';
import 'package:sri_murugan_chits/screens/master/diwali_scheme/diwali_scheme_view.dart';
import 'package:sri_murugan_chits/screens/master/emi_entroll/emi_enrollment_binding.dart';
import 'package:sri_murugan_chits/screens/master/emi_entroll/emi_enrollment_list_screen.dart';
import 'package:sri_murugan_chits/screens/master/emi_entroll/emi_enrollment_screen.dart';
import 'package:sri_murugan_chits/screens/master/emi_scheme/emi_scheme_binding.dart';
import 'package:sri_murugan_chits/screens/master/emi_scheme/emi_scheme_screen.dart';
import 'package:sri_murugan_chits/screens/report/emi_payment_report_binding.dart';
import 'package:sri_murugan_chits/screens/report/emi_payment_report_screen.dart';
import 'package:sri_murugan_chits/screens/settings/settings_binding.dart' hide EmiPaymentReportBinding;
import 'package:sri_murugan_chits/screens/settings/settings_screen.dart';
import 'package:sri_murugan_chits/screens/splash/splash_screen.dart';

class AppRoutes {
  static final routes = [
    GetPage(name: "/login", page: () => LoginScreen(), binding: AuthBinding()),
    GetPage(
      name: '/dashboard',
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(name: '/splash', page: () => const SplashScreen()),
    GetPage(
      name: "/settings",
      page: () => const SettingsScreen(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: '/customer',
      page: () => const CustomerView(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: '/diwali-schemes',
      page: () => const DiwaliSchemeView(),
      binding: DiwaliSchemeBinding(),
    ),
    GetPage(
      name: '/diwali-enrollments',
      page: () => const DiwaliEnrollmentView(),
      binding: DiwaliEnrollmentBinding(),
    ),
    GetPage(
      name: '/emi-schemes',
      page: () => const EmiSchemeScreen(),
      binding: EmiSchemeBinding(),
    ),
    GetPage(
      name: '/emi-enrollments',
      page: () => const AddEnrollmentScreen(),
      binding: EmiEnrollmentBinding(),
    ),
    GetPage(
  name: '/emi-enrollments-list',
  page: () => const EmiEnrollmentListScreen(),
),
GetPage(
  name: '/emi-payment-report',
  page: () => const EmiPaymentReportScreen(),
  binding: EmiPaymentReportBinding(),   // 👈 add this
),
  ];
}
