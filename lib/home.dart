import 'dart:io';

import 'package:app_manager/global/config.dart';
import 'package:app_manager/utils/socket_util.dart';
import 'package:app_manager/widgets/custom_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'global/global.dart';
import 'page/already_install.dart';
import 'page/common_app_page.dart';
import 'page/long_press_dialog.dart';
import 'controller/app_manager_controller.dart';
import 'controller/check_controller.dart';
import 'utils/app_utils.dart';

class AppManagerWithoutMaterialpp extends StatelessWidget {
  const AppManagerWithoutMaterialpp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class AppManager extends StatefulWidget {
  AppManager({Key key, this.process}) : super(key: key) {
    if (process != null) {
      Global().process = process;
    } else {
      // 放这儿是对的
    }
    // hide 命令要root
    Global().initProcess();
    Get.put(AppManagerController());
    Get.put(CheckController());
    if (RuntimeEnvir.packageName != Config.packageName) {
      // 如果这个项目是独立运行的，那么RuntimeEnvir.packageName会在main函数中被设置成Config.packageName
      Config.flutterPackage = 'packages/app_manager/';
    }
  }
  final Executable process;
  @override
  _AppManagerState createState() => _AppManagerState();
}

class _AppManagerState extends State<AppManager>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  String filter = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final Directory workDir = Directory(RuntimeEnvir.filesPath + '/AppManager');
    final bool exists = workDir.existsSync();
    if (!exists) {
      await workDir.create(recursive: true);
    }
    await Directory(workDir.path + '/.icon').create();
    appManagerProvider.getUserApp();
    appManagerProvider.getSysApp();
  }

  AppManagerController appManagerProvider = Get.find();
  CheckController checkController = Get.find();
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Color(0xfff5f5f7),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (data) {
                          filter = data;
                          setState(() {});
                        },
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          fillColor: Color(0xffeeeeee),
                          hintText: '过滤',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            gapPadding: 0,
                            borderSide: BorderSide(
                              width: 0,
                              color: Colors.transparent,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            gapPadding: 0,
                            borderSide: BorderSide(
                              width: 0,
                              color: Colors.transparent,
                            ),
                          ),
                          filled: true,
                        ),
                      ),
                    ),
                    NiIconButton(
                      onTap: () {},
                      child: Icon(Icons.more_vert),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GetBuilder<AppManagerController>(builder: (ctl) {
                  return SafeArea(
                    child: <Widget>[
                      CommonAppPage(
                        appList: ctl.userApps,
                        filter: filter.toLowerCase(),
                      ),
                      CommonAppPage(
                        appList: ctl.sysApps,
                        filter: filter.toLowerCase(),
                      ),
                      CommonAppPage(),
                      CommonAppPage(),
                    ][_currentIndex],
                  );
                }),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color(0xfff5f5f7),
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                '${Config.flutterPackage}assets/app.svg',
                width: 24,
              ),
              label: '用户',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                '${Config.flutterPackage}assets/safe.svg',
                width: 24,
              ),
              label: '系统',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                '${Config.flutterPackage}assets/safe.svg',
                width: 24,
              ),
              label: '已冻结',
            ),
          ],
          unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.indigo,
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (int index) {
            _currentIndex = index;
            setState(
              () {},
            );
          },
        ),
        floatingActionButton: GetBuilder<CheckController>(builder: (_) {
          if (checkController.check.length > 1) {
            return FloatingActionButton(
              child: Icon(Icons.more_vert),
              onPressed: () {
                Get.bottomSheet(LongPress());
              },
            );
          } else {
            return SizedBox();
          }
        }),
      ),
    );
  }
}
