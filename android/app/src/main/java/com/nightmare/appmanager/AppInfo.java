package com.nightmare.appmanager;


/**
 * Created by Nightmare on 2021/7/29.
 */

import android.annotation.SuppressLint;
import android.content.*;
import android.content.pm.*;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.drawable.*;
import android.net.LocalServerSocket;
import android.net.LocalSocket;
import android.os.Build;
import android.os.Looper;
import android.util.Log;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.net.InetSocketAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Arrays;
import java.util.List;

public class AppInfo {
    Context context;
    PackageManager pm;

    static final String SOCKET_NAME = "app_manager";

    public AppInfo(Context context) {
        this.context = context;
        pm = context.getPackageManager();
    }


    static public byte[] Bitmap2Bytes(Bitmap bm) {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        bm.compress(Bitmap.CompressFormat.PNG, 100, baos);
        return baos.toByteArray();
    }

    public static void main(String[] arg) throws Exception {
        Looper.prepareMainLooper();
        Class<?> activityThreadClass = Class.forName("android.app.ActivityThread");
        Constructor<?> activityThreadConstructor = activityThreadClass.getDeclaredConstructor();
        activityThreadConstructor.setAccessible(true);
        Object activityThread = activityThreadConstructor.newInstance();
        Method getSystemContextMethod = activityThreadClass.getDeclaredMethod("getSystemContext");
        Context ctx = (Context) getSystemContextMethod.invoke(activityThread);
        new Thread(() -> {
            try {
                startServer(ctx);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }).start();
        System.out.println("wait");
        System.out.flush();
        System.in.read();

    }

    public static void startServer(Context context) throws IOException {
        LocalServerSocket localServerSocket = new LocalServerSocket(SOCKET_NAME);
        while (true) {
            System.out.println("等待连接");
            System.out.flush();
            LocalSocket socket = localServerSocket.accept();
            System.out.println("连接成功");
            System.out.flush();
            InputStream is = socket.getInputStream();
            OutputStream os = socket.getOutputStream();
            BufferedReader br = new BufferedReader(new InputStreamReader(is));
            String data = br.readLine();
            if (data.startsWith("getIconData")) {
                System.out.println("响应Icon信息");
                System.out.flush();
                Log.d("nightmare", "响应Icon信息");
                handleIcon(os, context, data.replace("getIconData ", ""));
            } else if (data.startsWith("getAppInfo")) {
                System.out.println("响应AppInfo");
                System.out.flush();
                handleAppInfo(os, context, data.replace("getAppInfo ", ""));
            } else if (data.startsWith("getAllIconData")) {
                System.out.println("响应AllAppInfo");
                System.out.flush();
                handleAllAppInfo(os, context, data.replace("getAllIconData ", ""));
            }
            socket.close();
        }
    }

    public static void handleIcon(OutputStream outputStream, Context context, String packageName) throws IOException {
        System.out.println("包名:" + packageName);
        AppInfo appInfo = new AppInfo(context);

        System.out.println("发送的第一个字节为" + appInfo.getBitmapBytes(packageName)[0]);
        System.out.flush();

        outputStream.write(appInfo.getBitmapBytes(packageName));
    }

    public static void handleAllAppInfo(OutputStream outputStream, Context context, String data) throws IOException {
        List<String> id = stringToList(data);
        AppInfo appInfo = new AppInfo(context);
        System.out.println("第一个包名为" + id.get(0) + "发送的第一个字节为" + appInfo.getBitmapBytes(id.get(0))[0]);
        System.out.flush();
        for (String packageName : id) {
            outputStream.write(appInfo.getBitmapBytes(packageName));
            outputStream.flush();
        }
    }

    public static void handleAppInfo(OutputStream outputStream, Context context, String data) throws IOException {
        AppInfo appInfo = new AppInfo(context);
        outputStream.write(appInfo.getAppInfo(data).getBytes());
    }

    public String getAppInfo(String data) {
        List<String> id = stringToList(data);
        StringBuilder builder = new StringBuilder();
        for (String packageName : id) {
            try {
                PackageInfo packages = context.getPackageManager().getPackageInfo(packageName, 0);
                builder.append(packages.applicationInfo.loadLabel(context.getPackageManager()));
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    builder.append(" ").append(packages.applicationInfo.minSdkVersion);
                } else {
                    builder.append(" ").append("null");
                }
                builder.append(" ").append(packages.applicationInfo.targetSdkVersion);
                builder.append(" ").append(packages.versionName);
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    builder.append(" ").append(packages.getLongVersionCode()).append("\n");
                } else {
                    builder.append(" ").append(packages.versionCode).append("\n");
                }

            } catch (PackageManager.NameNotFoundException e) {
                e.printStackTrace();
            }
        }
        return builder.toString();

    }

    private static List<String> stringToList(String strs) {
        String[] str = strs.split(" ");
        return Arrays.asList(str);
    }

    public byte[] getBitmapBytes(String packname) {
        return Bitmap2Bytes(getBitmap(packname));
    }

    public synchronized Bitmap getBitmap(String packname) {
        ApplicationInfo applicationInfo = null;
        try {
            applicationInfo = pm.getApplicationInfo(
                    packname, 0);
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        if (applicationInfo == null) {
            return null;
        }
        Drawable icon = applicationInfo.loadIcon(pm); //xxx根据自己的情况获取drawable
        try {
            if (icon == null) {
                return null;
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && icon instanceof AdaptiveIconDrawable) {
                Bitmap bitmap = Bitmap.createBitmap(icon.getIntrinsicWidth(), icon.getIntrinsicHeight(), Bitmap.Config.ARGB_8888);
                Canvas canvas = new Canvas(bitmap);
                icon.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
                icon.draw(canvas);
                return bitmap;
            } else {
                return ((BitmapDrawable) icon).getBitmap();
            }
        } catch (Exception e) {
            return null;
        }
    }

}
