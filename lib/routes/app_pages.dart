import 'package:app_manager/bindings/app_manager_binding.dart';
import 'package:app_manager/home.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
part 'app_routes.dart';

// ignore: avoid_classes_with_only_static_members
abstract class AppPages {
  static final routes = [
    GetPage(
      name: AppManagerRoutes.home,
      page: () {
        return AppManager();
      },
      binding: AppManagerBinding(),
    ),
  ];
}
