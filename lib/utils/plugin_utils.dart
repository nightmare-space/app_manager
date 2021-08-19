import 'package:flutter/services.dart';

const MethodChannel _channel = MethodChannel('app_manager');

class PluginUtils {
  static void shareFile(String path) {
    _channel.invokeMethod('shareApk', path);
  }
}
