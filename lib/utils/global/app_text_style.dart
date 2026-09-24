import 'package:flutter/material.dart';
import 'package:sri_murugan_chits/utils/colors/app_colors.dart';


class AppTextStyle {
  AppTextStyle._();

  static const String fontFamily = 'Inter';

  // Regular - 400
  static const TextStyle regular = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: AppColors.black,
  );

  static const TextStyle regularSmall = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: AppColors.black,
  );

  static const TextStyle regularLarge = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    color: AppColors.black,
  );



  // SemiBold - 600
  static const TextStyle semiBold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: AppColors.black,
  );

  

  static const TextStyle semiBoldSmall = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 12,
    color: AppColors.black,
  );

  static const TextStyle semiBoldLarge = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: AppColors.black,
  );

  static const TextStyle heading = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 20,
    color: AppColors.black,
  );

  // Button text
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: AppColors.white,
  );
}