import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

import 'global/global.dart';
import 'home.dart';
import 'provider/app_manager_controller.dart';
import 'utils/socket_util.dart';

void main() {
  RuntimeEnvir.initEnvirWithPackageName('com.nightmare.appmanager');
  runApp(ToastApp(
    child: MaterialApp(
      home: AppManager(),
    ),
  ));
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
}

void openFormPackage(YanProcess executable) {}
