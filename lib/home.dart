import 'package:app_manager/global/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'global/global.dart';
import 'modules/app_page/app_list_page.dart';
import 'controller/app_manager_controller.dart';
import 'controller/check_controller.dart';
import 'widgets/search_box.dart';

class AppManagerWithoutMaterialpp extends StatelessWidget {
  const AppManagerWithoutMaterialpp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class AppManagerEntryPoint extends StatefulWidget {
  AppManagerEntryPoint({Key? key, this.process}) : super(key: key) {
    if (process != null) {
      Global().process = process as YanProcess?;
    } else {
      // 放这儿是对的
    }
    // hide 命令要root
    if (Get.arguments != null) {
      Global().process = Get.arguments;
    }
  }
  final Executable? process;
  @override
  State createState() => _AppManagerEntryPointState();
}

class _AppManagerEntryPointState extends State<AppManagerEntryPoint> with SingleTickerProviderStateMixin {
  AppManagerController controller = Get.find();
  int _currentIndex = 0;
  String filter = '';

  @override
  void initState() {
    super.initState();
    controller.init();
  }

  AppManagerController appManagerProvider = Get.find();
  CheckController checkController = Get.find();
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: OverlayStyle.dark,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SearchBox(
                        onInput: (data) {
                          filter = data;
                          setState(() {});
                        },
                      ),
                    ),
                    SizedBox(
                      width: 8.w,
                    ),
                    NiIconButton(
                      onTap: () {},
                      child: const Icon(Icons.more_vert),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GetBuilder<AppManagerController>(builder: (ctl) {
                  return SafeArea(
                    child: <Widget>[
                      AppListPage(
                        key: const Key('user'),
                        appInfos: ctl.userApps,
                        filter: filter.toLowerCase(),
                      ),
                      AppListPage(
                        key: const Key('sys'),
                        appInfos: ctl.sysApps,
                        filter: filter.toLowerCase(),
                      ),
                      // const MarkPage(),
                      // const BackupListPage(),
                    ][_currentIndex],
                  );
                }),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xfff5f5f7),
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
            // BottomNavigationBarItem(
            //   icon: SvgPicture.asset(
            //     '${Config.flutterPackage}assets/market1.svg',
            //     width: 24,
            //   ),
            //   label: '收藏',
            // ),
            // BottomNavigationBarItem(
            //   icon: SvgPicture.asset(
            //     '${Config.flutterPackage}assets/backup2.svg',
            //     width: 24,
            //   ),
            //   label: '备份',
            // ),
          ],
          unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.indigo,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (int index) {
            _currentIndex = index;
            if (index == 1) {
              // controller.cacheSysIcon();
            }
            setState(() {});
          },
        ),
        // floatingActionButton: GetBuilder<CheckController>(builder: (_) {
        //   if (checkController.check.length > 1) {
        //     return FloatingActionButton(
        //       child: const Icon(Icons.more_vert),
        //       onPressed: () {
        //         Get.bottomSheet(const LongPress());
        //       },
        //     );
        //   } else {
        //     return const SizedBox();
        //   }
        // }),
      ),
    );
  }
}
