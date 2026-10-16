import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:sri_murugan_chits/routes/app_pages.dart';
import 'package:sri_murugan_chits/screens/auth/auth_controller.dart';
import 'package:sri_murugan_chits/screens/collections/collection_controller.dart';
import 'package:sri_murugan_chits/screens/dues/dues_controller.dart';
import 'package:sri_murugan_chits/screens/emi_collection/emi_collection_controller.dart';
import 'package:sri_murugan_chits/screens/home/home_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Get.put(AuthController());
  Get.put(HomeController());
  Get.put(CollectionController());
  Get.put(EmiCollectionController());
  Get.put(DuesController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sri Murugan Chits',
      initialRoute: '/splash',
      getPages: AppRoutes.routes,
    );
  }
}
