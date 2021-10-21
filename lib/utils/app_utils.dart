import 'dart:io';

import 'package:app_manager/global/config.dart';
import 'package:app_manager/global/global.dart';
import 'package:app_manager/model/app.dart';
import 'package:app_manager/utils/socket_util.dart';
import 'package:flutter/services.dart';
import 'package:global_repository/global_repository.dart';

const MethodChannel _channel = MethodChannel('app_manager');
int port = 6000;

class AppUtils {
  static bool runOnPackage() {
    return RuntimeEnvir.packageName != Config.packageName;
  }

}
