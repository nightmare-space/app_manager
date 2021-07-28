import 'dart:io';

import 'package:app_manager/utils/socket_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'global/global.dart';
import 'page/already_install.dart';
import 'page/common_app_page.dart';
import 'provider/app_manager_controller.dart';
import 'utils/app_utils.dart';

class AppManager extends StatefulWidget {
  AppManager({Key key, this.process}) : super(key: key) {
    if (process != null) {
      Global().process = process;
      // 放这儿是对的
      Global().initProcess();
    }
    Get.put(AppManagerController());
  }
  final Executable process;
  @override
  _AppManagerState createState() => _AppManagerState();
}

class _AppManagerState extends State<AppManager>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<Color> _colorAnimation;
  int _currentIndex = 0;
  Color currentColor;
  List<Color> colors = <Color>[
    Colors.indigo,
    Colors.deepPurple,
    // Colors.blueGrey,
    // const Color(0xff25816b),
    // Colors.pink,
    Colors.brown,
  ];
  @override
  void initState() {
    super.initState();
    currentColor = colors[0];
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _colorAnimation = ColorTween(
      begin: currentColor,
      end: currentColor,
    ).animate(animationController);
    _colorAnimation.addListener(() {
      setState(() {});
    });
    animationController.forward();
    init();
  }

  Future<void> init() async {
    // final Directory workDir = Directory(RuntimeEnvir.filesPath + '/AppManager');
    // final bool exists = workDir.existsSync();
    // if (!exists) {
    //   await workDir.create(recursive: true);
    // }
    // await Directory(workDir.path + '/.icon').create();
    appManagerProvider.getUserApp();
    appManagerProvider.getSysApp();
  }

  AppManagerController appManagerProvider = Get.find();
  @override
  Widget build(BuildContext context) {
    currentColor = _colorAnimation.value;
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        // appBar: AppBar(
        //   backgroundColor: currentColor,
        //   elevation: 0.0,
        //   title: const Text('应用管理'),
        //   centerTitle: true,
        // ),
        body: GetBuilder<AppManagerController>(builder: (ctl) {
          return SafeArea(
            child: <Widget>[
              CommonAppPage(
                appList: ctl.userApps,
              ),
              CommonAppPage(
                appList: ctl.sysApps,
              ),
              CommonAppPage(),
              CommonAppPage(),
            ][_currentIndex],
          );
        }),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/app.svg',
                width: 24,
              ),
              title: Text(
                '用户',
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.pages,
              ),
              title: Text(
                '系统',
              ),
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(
            //     Icons.pages,
            //   ),
            //   title: Text(
            //     '已冻结',
            //   ),
            // ),
          ],
          unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.indigo,
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (int index) {
            _colorAnimation = ColorTween(
              begin: currentColor,
              end: colors[index],
            ).animate(animationController);
            animationController.reset();
            animationController.forward();
            setState(
              () {
                _currentIndex = index;
              },
            );
          },
        ),
      ),
    );
  }
}
