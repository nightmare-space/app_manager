import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_toolkit/config/config.dart';
import 'package:flutter_toolkit/utils/platform_channel.dart';

class ItemHeader extends StatefulWidget {
  const ItemHeader({Key key, this.packageName}) : super(key: key);
  final String packageName;

  @override
  _ItemHeaderState createState() => _ItemHeaderState();
}

class _ItemHeaderState extends State<ItemHeader> {
  bool imgExist = false;
  @override
  void initState() {
    super.initState();
    checkImageExist();
  }

  Future<void> checkImageExist() async {
    if (File('${Config.filesPath}/AppManager/.icon/${widget.packageName}')
        .existsSync()) {
      imgExist = true;
      setState(() {});
    } else {
      await PlatformChannel.GetAppIcon.invokeMethod<void>(widget.packageName);
      checkImageExist();
    }
  }

  @override
  Widget build(BuildContext context) {
    return imgExist
        ? Image.file(
            File('${Config.filesPath}/AppManager/.icon/${widget.packageName}'))
        : const SizedBox();
  }
}
