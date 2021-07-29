package com.nightmare.appmanager;

import android.annotation.SuppressLint;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.drawable.AdaptiveIconDrawable;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.Build;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import static com.nightmare.appmanager.AppInfo.Bitmap2Bytes;

public class MainActivity extends FlutterActivity {


    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        initPlugin(flutterEngine);
    }

    void initPlugin(@NonNull FlutterEngine flutterEngine) {
        new Thread(() -> {
            GetApp(flutterEngine);
            App(flutterEngine);
        }).start();

        new Thread(() -> {
            try {
                AppInfo.startServer(getApplicationContext());
            } catch (Exception e) {
                e.printStackTrace();
            }
        }).start();
    }


    void GetApp(@NonNull FlutterEngine flutterEngine) {

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "jump").setMethodCallHandler((call, result) -> {
            new Thread(() -> {
                // try catch 一下
                List<String> arg = stringToList(call.method);
                Intent intent = new Intent();
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                ComponentName cName = new ComponentName(arg.get(0), arg.get(1));
                intent.setComponent(cName);
                startActivity(intent);
            }).start();
        });
    }


    private List<String> stringToList(String strs) {
        String[] str = strs.split("\n");
        return Arrays.asList(str);
    }

    void App(@NonNull FlutterEngine flutterEngine) {
        MethodChannel appChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "app_manager");
        appChannel.setMethodCallHandler((call, result) -> new Thread(() -> {
            switch (call.method) {
                case "getAppIcon":
                    String packageName = (String) call.arguments;
                    AppInfo iconInfo = new AppInfo(this);
                    byte[] bytes = iconInfo.getBitmapBytes(packageName);
                    if (bytes.length != 0) {
                        runOnUiThread(() -> {
                            result.success(bytes);
                        });
                    }
                    break;
                case "getAppInfo":
                    AppInfo appInfo = new AppInfo(this);
                    String res = (String) call.arguments;
                    runOnUiThread(() -> {
                        result.success(appInfo.getAppInfo(res));
                    });
                    break;
                case "getMainActivity":
                    try {
                        PackageInfo packages = getPackageManager().getPackageInfo(call.method, 0);
                        ActivityInfo[] actInfo = getPackageManager().getPackageInfo(packages.packageName, PackageManager.GET_ACTIVITIES).activities;
                        StringBuilder builder = new StringBuilder();
//                if(actInfo!=null)
//                for (ActivityInfo a : actInfo) {
//                    list.append(a.name).append("\n");
//                }
                        Intent mainIntent = new Intent(Intent.ACTION_MAIN, null);
                        mainIntent.addCategory(Intent.CATEGORY_LAUNCHER);
                        @SuppressLint("QueryPermissionsNeeded")
                        List<ResolveInfo> appList = getPackageManager().queryIntentActivities(mainIntent, 0);
                        for (int i = 0; i < appList.size(); i++) {
                            ResolveInfo resolveInfo = appList.get(i);
                            String packageStr = resolveInfo.activityInfo.packageName;
                            if (packageStr.equals(call.method)) {
                                //这个就是你想要的那个Activity
                                builder.append(resolveInfo.activityInfo.name).append("\n");
                                break;
                            }
                        }
                        runOnUiThread(() -> result.success(builder.toString()));
                    } catch (PackageManager.NameNotFoundException e) {
                        e.printStackTrace();
                    }
                    break;
            }
        }).start());
    }
}