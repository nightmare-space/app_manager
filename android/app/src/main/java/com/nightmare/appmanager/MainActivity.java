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
                AppInfo.startIconServer(getApplicationContext());
            } catch (Exception e) {
                e.printStackTrace();
            }
        }).start();
        new Thread(() -> {
            try {
                AppInfo.startAppInfoServer(getApplicationContext());
            } catch (Exception e) {
                e.printStackTrace();
            }
        }).start();
    }


    void GetApp(@NonNull FlutterEngine flutterEngine) {
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "GetAppIcon").setMethodCallHandler((call, result) -> {
            new Thread(() -> {
                AppInfo info = new AppInfo(getApplicationContext());
                Bitmap bitmap = info.getBitmap(call.method);
                runOnUiThread(() -> result.success(Bitmap2Bytes(bitmap)));
            }).start();
        });
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "jump").setMethodCallHandler((call, result) -> {
            new Thread(() -> {
                List<String> arg = stringToList(call.method);
                Intent intent = new Intent();
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                ComponentName cName = new ComponentName(arg.get(0), arg.get(1));
                intent.setComponent(cName);
                startActivity(intent);
            }).start();
        });
    }

    public byte[] Bitmap2Bytes(Bitmap bm) {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        bm.compress(Bitmap.CompressFormat.PNG, 100, baos);
        return baos.toByteArray();
    }

    private List<String> stringToList(String strs) {
        String[] str = strs.split("\n");
        return Arrays.asList(str);
    }

    void App(@NonNull FlutterEngine flutterEngine) {
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "App").setMethodCallHandler((call, result) -> new Thread(() -> {
            List<String> id = stringToList(call.method);
            StringBuilder builder = new StringBuilder();
            for (String packageName : id) {
                try {
                    PackageInfo packages = getPackageManager().getPackageInfo(packageName, 0);
                    builder.append(packages.applicationInfo.loadLabel(getPackageManager()));
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                        builder.append(" ").append(packages.applicationInfo.minSdkVersion);
                        builder.append(" ").append(packages.applicationInfo.targetSdkVersion);
                        builder.append(" ").append(packages.versionName);
                        builder.append(" ").append(packages.getLongVersionCode()).append("\n");
                    }
                } catch (PackageManager.NameNotFoundException e) {
                    e.printStackTrace();
                }
            }
            runOnUiThread(() -> result.success(builder.toString()));

        }).start());
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "GetAppInfo").setMethodCallHandler((call, result) -> new Thread(() -> {
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


        }).start());
    }
}