import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

import 'global/config.dart';
import 'routes/app_pages.dart';

//                            _ooOoo_
//                           o8888888o
//                           88" . "88
//                           (| -_- |)
//                            O\ = /O
//                        ____/`---'\____
//                      .   ' \\| |// `.
//                       / \\||| : |||// \
//                     / _||||| -:- |||||- \
//                       | | \\\ - /// | |
//                     | \_| ''\---/'' | |
//                      \ .-\__ `-` ___/-. /
//                   ___`. .' /--.--\ `. . __
//                ."" '< `.___\_<|>_/___.' >'"".
//               | | : `- \`.;`\ _ /`;.`/ - ` : | |
//                 \ \ `-. \_ __\ /__ _/ .-` / /
//         ======`-.____`-.___\_____/___.-`____.-'======
//                            `=---='
//
//         .............................................
//                  佛祖保佑             永无BUG
Future<void> main() async {
  RuntimeEnvir.initEnvirWithPackageName(Config.packageName);
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppManager());
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  // await FlutterDisplayMode.setHighRefreshRate();
}

class AppManager extends StatefulWidget {
  const AppManager({Key? key}) : super(key: key);

  @override
  State<AppManager> createState() => _AppManagerState();
}

class _AppManagerState extends State<AppManager> {
  @override
  Widget build(BuildContext context) {
    return ToastApp(
      child: LayoutBuilder(
        builder: (context, con) {
          return ScreenQuery(
            uiWidth: 414,
            screenWidth: con.maxWidth,
            child: GetMaterialApp(
              getPages: AppPages.routes,
              initialRoute: AppManagerRoutes.home,
              builder: (context, child) {
                return child ?? const SizedBox();
              },
            ),
          );
        },
      ),
    );
  }
}
