import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_toolkit/global/widgets/public_widgets.dart';
import 'package:flutter_toolkit/modules/app_manager/model/app.dart';
import 'package:flutter_toolkit/utils/custom_process.dart';

class LongPress extends StatefulWidget {
  const LongPress({Key key, this.apps}) : super(key: key);
  final List<AppEntity> apps;

  @override
  _LongPressState createState() => _LongPressState();
}

class _LongPressState extends State<LongPress> {
  Widget item(String title, void Function() onTap) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 32.0,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(title),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FullHeightListView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Text(widget.apps[0].appName),
          ),
          item('打开', () async {
            const MethodChannel getAppIcon = MethodChannel('GetAppInfo');
            final String activityName = await getAppIcon
                .invokeMethod<String>(widget.apps[0].packageName);
            await NiProcess.exec(
                'am start -n ${widget.apps[0].packageName}/$activityName');
            // String result = await CustomProcess.exec(
            //     "pm dump ${widget.apps[0].packageName}");
            // File("$documentsDir/YanTool/日志文件夹/a.txt")
            //     .writeAsStringSync(result);
            // print(result);
          }),
          item('清除数据', () {}),
          item('卸载', () {}),
          item('冻结', () {}),
          item('打开', () {}),
          item('导出', () {}),
        ],
      ),
    );
  }
}
