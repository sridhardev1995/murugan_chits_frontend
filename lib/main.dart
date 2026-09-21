import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:sri_murugan_chits/routes/app_pages.dart';

void main()async {
   WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      title: "Restaurant App",
      //  debugShowCheckedModeBanner: false,
      // theme: AppTheme.lightTheme,

      initialRoute: "/splash",

      getPages: AppRoutes.routes,
    );
  }
}

