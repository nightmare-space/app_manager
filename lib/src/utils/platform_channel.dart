import 'package:flutter/services.dart';

class PlatformChannel {
  static const MethodChannel defaultChannel = MethodChannel('SomeThing');
  static const MethodChannel AppInfo = MethodChannel('App');
  static const MethodChannel GetAppIcon = MethodChannel('GetAppIcon');
}
