import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'page/already_install.dart';
import 'provider/app_manager_provider.dart';
import 'utils/app_utils.dart';

class AppManager extends StatefulWidget {
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
    final Directory workDir = Directory(RuntimeEnvir.filesPath + '/AppManager');
    final bool exists = workDir.existsSync();
    if (!exists) {
      await workDir.create(recursive: true);
    }
    await Directory(workDir.path + '/.icon').create();
    appManagerProvider.setUserApps(await AppUtils.getUserApps());
    appManagerProvider.setSysApps(await AppUtils.getSysApps());
  }

  AppManagerController appManagerProvider = Get.find();
  @override
  Widget build(BuildContext context) {
    currentColor = _colorAnimation.value;
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: currentColor,
      //   elevation: 0.0,
      //   title: const Text('应用管理'),
      //   centerTitle: true,
      // ),
      body: <Widget>[
        AlreadyInstall(),
        AlreadyInstall(),
        AlreadyInstall(),
      ][_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            title: Text(
              '已安装',
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.pages,
            ),
            title: Text(
              '运行中',
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.pages,
            ),
            title: Text(
              '已冻结',
            ),
          ),
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
    );
  }
}
