import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_toolkit/config/toolkit_colors.dart';
import 'package:flutter_toolkit/modules/app_manager/model/app.dart';
import 'package:flutter_toolkit/modules/app_manager/provider/app_manager_provider.dart';
import 'package:flutter_toolkit/modules/app_manager/widgets/item_header.dart';
import 'package:flutter_toolkit/utils/global_function.dart';
import 'package:provider/provider.dart';

import 'long_press_dialog.dart';

class AlreadyInstall extends StatefulWidget {
  @override
  _AlreadyInstallState createState() => _AlreadyInstallState();
}

class _AlreadyInstallState extends State<AlreadyInstall>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(22.0),
        child: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          primary: true,
          bottom: TabBar(
            controller: tabController,
            tabs: const <Widget>[
              Text(
                '用户应用',
                style: TextStyle(color: Colors.black),
              ),
              Text(
                '系统应用',
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: <Widget>[
          _UserApps(),
          _SysApps(),
        ],
      ),
    );
  }
}

class _UserApps extends StatefulWidget {
  @override
  _UserAppsState createState() => _UserAppsState();
}

class _UserAppsState extends AppsEntityState<_UserApps> {
  @override
  AppType get appType => AppType.USER;
}

enum AppType {
  SYSTEM,
  USER,
}

class AppsEntityState<E extends StatefulWidget> extends State<E> {
  AppType appType;
  List<String> check = <String>[];
  @override
  Widget build(BuildContext context) {
    final AppManagerProvider appManagerProvider =
        Provider.of<AppManagerProvider>(context);
    final List<AppEntity> apps = appType == AppType.USER
        ? appManagerProvider.userApps
        : appManagerProvider.sysApps;
    if (apps.isEmpty) {
      return const SpinKitThreeBounce(
        color: YanToolColors.appColor,
        size: 16.0,
      );
    } else {
      return ListView.builder(
        itemCount: apps.length,
        itemBuilder: (BuildContext c, int i) {
          final String packageName = apps[i].packageName;
          return InkWell(
            onTap: () {
              if (check.contains(packageName)) {
                check.remove(packageName);
              } else {
                check.add(packageName);
              }
              setState(() {});
            },
            onLongPress: () {
              showCustomDialog2<void>(
                  child: LongPress(
                apps: <AppEntity>[apps[i]],
              ));
            },
            child: SizedBox(
              height: 48.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      ItemHeader(
                        packageName: apps[i].packageName,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(apps[i].appName),
                          Text(apps[i].packageName),
                        ],
                      ),
                    ],
                  ),
                  Checkbox(
                    value: check.contains(packageName),
                    onChanged: (bool v) {
                      if (check.contains(packageName)) {
                        check.remove(packageName);
                      } else {
                        check.add(packageName);
                      }
                      setState(() {});
                    },
                  )
                ],
              ),
            ),
          );
        },
      );
    }
  }
}

// class _SysApps extends StatefulWidget {
//   @override
//   _SysAppsState createState() => _SysAppsState();
// }
class _SysApps extends StatefulWidget {
  @override
  AppsEntityState<_SysApps> createState() => AppsEntityState<_SysApps>();
}
