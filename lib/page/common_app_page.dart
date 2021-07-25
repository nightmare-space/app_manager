import 'package:app_manager/model/app.dart';
import 'package:app_manager/provider/app_manager_provider.dart';
import 'package:app_manager/theme/app_colors.dart';
import 'package:app_manager/widgets/item_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

import 'already_install.dart';
import 'long_press_dialog.dart';

class CommonAppPage extends StatefulWidget {
  @override
  CommonAppPageState createState() => CommonAppPageState();
}

class CommonAppPageState extends State<CommonAppPage> {
  final AppManagerController appManagerProvider = Get.find();
  AppType appType = AppType.USER;
  List<String> check = <String>[];

  @override
  void initState() {
    super.initState();
    appManagerProvider.addListener(update);
  }

  void update() {
    if (appManagerProvider.userApps.isNotEmpty) {
      appManagerProvider.cacheUserIcons();
    }
  }

  @override
  void dispose() {
    appManagerProvider.removeListener(update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppManagerController>(builder: (_) {
      final List<AppEntity> apps = appManagerProvider.userApps;
      if (apps.isEmpty) {
        return SpinKitThreeBounce(
          color: AppColors.accentColor,
          size: 16.0,
        );
      } else {
        return ListView.builder(
          itemCount: apps.length,
          padding: EdgeInsets.only(bottom: 60),
          physics: BouncingScrollPhysics(),
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
                showCustomDialog<void>(
                    context: context,
                    child: LongPress(
                      apps: <AppEntity>[apps[i]],
                    ));
              },
              child: SizedBox(
                height: 54.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        AppIconHeader(
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
    });
  }
}
