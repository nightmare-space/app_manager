package com.nightmare.appmanager;

import android.content.ComponentName;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;

import androidx.annotation.NonNull;
import androidx.core.content.FileProvider;

import java.io.File;
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
                AppChannel.startServer(getApplicationContext());
            } catch (Exception e) {
                e.printStackTrace();
            }
        }).start();
    }


    void GetApp(@NonNull FlutterEngine flutterEngine) {

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "jump").setMethodCallHandler((call, result) -> {
            new Thread(() -> {
                // try catch 一下
                try {
                    List<String> arg = stringToList(call.method);
                    Intent intent = new Intent();
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    ComponentName cName = new ComponentName(arg.get(0), arg.get(1));
                    intent.setComponent(cName);
                    startActivity(intent);
                } catch (Exception e) {
                    e.printStackTrace();
                }
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
                case "shareApk":
                    String path = (String) call.arguments;
                    Intent shareIntent = new Intent(Intent.ACTION_SEND);
                    File file = new File(path);
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                        Uri contentUri = FileProvider.getUriForFile(this, "com.nightmare.appmanager" + ".fileprovider", file);
                        shareIntent.putExtra(Intent.EXTRA_STREAM, contentUri);
                        shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                    } else {
                        shareIntent.putExtra(Intent.EXTRA_STREAM, Uri.fromFile(new File(path)));
                    }
                    shareIntent.setType("*/*");//此处可发送多种文件
                    startActivity(Intent.createChooser(shareIntent, "分享到"));
                    break;

            }
        }).start());
    }
}