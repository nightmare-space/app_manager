import 'dart:io';

import 'package:app_channel/app_channel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

/// 需要实现一个 App Icon 的 Widget
/// 先从缓存中查是否有某个 App 的 Icon，如果没有先下载
/// 之前的策略是，每个 Icon 都作为网络图片从目标设备中加载
/// 这样对客户端到没啥影响，但会影响目标设备
/// 目标设备会由于大量的 IO 而卡顿
/// 例如无界控制 Android 时，由于无界在获取图标
/// 导致远程的性能也受到影响
/// 例如使用小米设备查看魅族设备上的应用列表

class AppIcon extends StatefulWidget {
  const AppIcon({
    Key? key,
    required this.packageName,
    required this.channel,
  }) : super(key: key);
  final String packageName;
  final AppChannel channel;

  @override
  State<AppIcon> createState() => _AppIconState();
}

class _AppIconState extends State<AppIcon> {
  bool isReady = false;
  @override
  void initState() {
    super.initState();
    cacheIcon();
  }

  Future<void> cacheIcon() async {
    Directory directory = Directory('${RuntimeEnvir.binPath}/cache');
    String iconPath = '${directory.path}/${widget.packageName}.png';
    if (File(iconPath).existsSync()) {
      isReady = true;
      setState(() {});
      return;
    }
    directory.createSync(recursive: true);
    String url = 'http://127.0.0.1:${widget.channel.port}/icon?package=${widget.packageName}';
    await httpInstance.download(url, iconPath);
    isReady = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return const SizedBox();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(l(8)),
      child: Image.file(
        File('${RuntimeEnvir.binPath}/cache/${widget.packageName}.png'),
      ),
    );
  }
}
