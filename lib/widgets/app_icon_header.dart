import 'dart:io';
import 'package:app_manager/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:global_repository/global_repository.dart';

class AppIconHeader extends StatefulWidget {
  const AppIconHeader({Key key, this.packageName}) : super(key: key);
  final String packageName;

  @override
  _AppIconHeaderState createState() => _AppIconHeaderState();
}

class _AppIconHeaderState extends State<AppIconHeader> {
  bool imgExist = false;
  bool prepare = false;
  @override
  void initState() {
    super.initState();
    loadAppIcon();
    // checkImageExist();
  }

  // Future<void> checkImageExist() async {
  //   if (File('${RuntimeEnvir.filesPath}/AppManager/.icon/${widget.packageName}')
  //       .existsSync()) {
  //     imgExist = true;
  //     setState(() {});
  //   } else {
  //     await PlatformChannel.GetAppIcon.invokeMethod<void>(widget.packageName);
  //     checkImageExist();
  //   }
  // }
  Future<void> loadAppIcon() async {
    // if ((_bytes = IconStore().loadCache(widget.packageName)).isEmpty) {
    File cacheFile = File(
        RuntimeEnvir.filesPath + '/AppManager/.icon/${widget.packageName}');
    if (!await cacheFile.exists()) {
      await cacheFile.writeAsBytes(
        await AppUtils.getAppIconBytes(widget.packageName),
      );
    }
    // _bytes = IconStore().cache(
    //   widget.packageName,
    //   await AppUtils.getAppIconBytes(widget.packageName),
    // );
    // Log.w('loadAppIcon $_bytes');
    // }
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
        width: 54,
        height: 54,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.file(
            File(RuntimeEnvir.filesPath +
                '/AppManager/.icon/${widget.packageName}'),
            gaplessPlayback: true,
          ),
        ),
      );
    }
  }
}
