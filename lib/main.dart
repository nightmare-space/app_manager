import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

import 'global/global.dart';
import 'home.dart';
import 'provider/app_manager_provider.dart';

void main() {
  Get.put(AppManagerController());
  RuntimeEnvir.initEnvirWithPackageName('com.nightmare.appmanager');
  runApp(MaterialApp(
    home: AppManager(),
  ));
  Global().initProcess();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
}
