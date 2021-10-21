import 'dart:io';
import 'package:app_manager/global/global.dart';
import 'package:app_manager/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:global_repository/global_repository.dart';

class AppIconHeader extends StatefulWidget {
  const AppIconHeader({
    Key key,
    this.packageName,
    this.padding = const EdgeInsets.all(8.0),
  }) : super(key: key);
  final String packageName;
  final EdgeInsets padding;
  @override
  _AppIconHeaderState createState() => _AppIconHeaderState();
}

class _AppIconHeaderState extends State<AppIconHeader> {
  bool imgExist = false;
  bool prepare = false;
  String iconDirPath = RuntimeEnvir.filesPath + '/AppManager/.icon';
  @override
  void initState() {
    super.initState();
    loadAppIcon();
  }

  Future<void> loadAppIcon() async {
    File cacheFile = File('$iconDirPath/${widget.packageName}');
    if (!await cacheFile.exists()) {
      await cacheFile.writeAsBytes(
        await Global().appChannel.getAppIconBytes(widget.packageName),
      );
    }
    prepare = true;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!prepare) {
      return const SizedBox(
        width: 54,
        height: 54,
        child: SpinKitDoubleBounce(
          color: Colors.indigo,
          size: 16.0,
        ),
      );
    } else {
      return SizedBox(
        child: Padding(
          padding: widget.padding,
          child: Image.file(
            File('$iconDirPath/${widget.packageName}'),
            gaplessPlayback: true,
          ),
        ),
      );
    }
  }
}
