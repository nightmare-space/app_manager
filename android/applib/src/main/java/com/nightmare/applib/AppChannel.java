package com.nightmare.applib;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PermissionInfo;
import android.content.pm.ResolveInfo;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.drawable.AdaptiveIconDrawable;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
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
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Arrays;
import java.util.List;

/**
 * Created by Nightmare on 2021/7/29.
 */

public class AppChannel {
    Context context;
    PackageManager pm;

    static final String SOCKET_NAME = "app_manager";

    public AppChannel(Context context) {
        this.context = context;
        pm = context.getPackageManager();
    }


    static public byte[] Bitmap2Bytes(Bitmap bm) {
        if (bm == null) {
            return new byte[0];
        }
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        bm.compress(Bitmap.CompressFormat.PNG, 100, baos);
        return baos.toByteArray();
    }

    public static void main(String[] arg) throws Exception {
        Looper.prepareMainLooper();
        @SuppressLint("PrivateApi")
        Class<?> activityThreadClass = Class.forName("android.app.ActivityThread");
        Constructor<?> activityThreadConstructor = activityThreadClass.getDeclaredConstructor();
        activityThreadConstructor.setAccessible(true);
        Object activityThread = activityThreadConstructor.newInstance();
        @SuppressLint("DiscouragedPrivateApi")
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
        // 不能让进程退了
        int placeholder = System.in.read();

    }

    public static void startServer(Context context) throws IOException {
        ServerSocket serverSocket = new ServerSocket(6000);
        while (true) {
            System.out.println("等待连接");
            System.out.flush();
            Socket socket = serverSocket.accept();
            System.out.println("连接成功");
            System.out.flush();
            InputStream is = socket.getInputStream();
            OutputStream os = socket.getOutputStream();
            BufferedReader br = new BufferedReader(new InputStreamReader(is));
            String data = br.readLine();
            String type = data.replaceAll(":.*", ":");
            AppChannel appInfo = new AppChannel(context);
            switch (type) {
                case AppChannelProtocol.getIconData:
                    System.out.println("响应Icon信息");
                    System.out.flush();
                    Log.d("Nightmare", "响应Icon信息");
                    handleIcon(os, context, data.replace(AppChannelProtocol.getIconData, ""));
                    break;
                case AppChannelProtocol.getAllAppInfo:
                    System.out.println("响应AllAppInfo");
                    Log.d("Nightmare", "响应AllAppInfo");
                    System.out.flush();
                    handleAllAppInfo(os, context, data.replace(AppChannelProtocol.getAllAppInfo, ""));
                    break;
                case AppChannelProtocol.getAllIconData:
                    System.out.println("响应AllAppIcon");
                    System.out.flush();
                    handleAllAppIcon(os, context, data.replace(AppChannelProtocol.getAllIconData, ""));
                    break;
                case AppChannelProtocol.getAppActivity:
                    System.out.println("响应getAppActivity");
                    System.out.flush();
                    os.write(appInfo.getAppActivitys(data.replace(AppChannelProtocol.getAppActivity, "")).getBytes());
                case AppChannelProtocol.getAppPermissions:
                    System.out.println("响应getAppPermissions");
                    System.out.flush();
                    os.write(appInfo.getAppPermissions(data.replace(AppChannelProtocol.getAppPermissions, "")).getBytes());
                    break;
                case AppChannelProtocol.getAppDetail:
                    System.out.println("响应getAppDetail");
                    System.out.flush();
                    os.write(appInfo.getAppDetail(data.replace(AppChannelProtocol.getAppDetail, "")).getBytes());
                    break;
                case AppChannelProtocol.getAppMainActivity:
                    System.out.println("响应getAppMainActivity");
                    System.out.flush();
                    os.write(appInfo.getAppMainActivity(data.replace(AppChannelProtocol.getAppMainActivity, "")).getBytes());
                    break;
                default:
                    socket.close();
                    return;
            }
            socket.setReuseAddress(true);
            socket.close();
        }
    }

    public static void handleIcon(OutputStream outputStream, Context context, String packageName) throws IOException {
        System.out.println("包名:" + packageName);
        AppChannel appInfo = new AppChannel(context);
        outputStream.write(appInfo.getBitmapBytes(packageName));
    }

    public static void handleAllAppIcon(OutputStream outputStream, Context context, String data) throws IOException {
        List<String> id = stringToList(data);
        AppChannel appInfo = new AppChannel(context);
        for (String packageName : id) {
            outputStream.write(appInfo.getBitmapBytes(packageName));
            outputStream.flush();
        }
    }


    public static void handleAllAppInfo(OutputStream outputStream, Context context, String data) throws IOException {
        AppChannel appInfo = new AppChannel(context);
        outputStream.write(appInfo.getAllAppInfo(data).getBytes());
    }

    public String getAppActivitys(String data) {
        StringBuilder builder = new StringBuilder();
        {
            List<PackageInfo> packages = context.getPackageManager().getInstalledPackages(PackageManager.GET_UNINSTALLED_PACKAGES);
            for (PackageInfo pack : packages) {
                if (pack.packageName.equals(data)) {
                    try {
                        PackageInfo packageInfo = context.getPackageManager().getPackageInfo(data, PackageManager.GET_ACTIVITIES);
                        Log.w("nightmare", Arrays.toString(packageInfo.activities));
                        if (packageInfo.activities == null) {
                            return "";
                        }
                        for (ActivityInfo info : packageInfo.activities) {
                            builder.append(info.name).append("\n");
                        }

                    } catch (PackageManager.NameNotFoundException e) {
                        e.printStackTrace();
                        return builder.toString();
                    }
                }
            }
        }
        return builder.toString();

    }

    public String getAppPermissions(String data) {
        StringBuilder builder = new StringBuilder();
        try {
            PackageManager packageManager = context.getPackageManager();
            PackageInfo packageInfo = packageManager.getPackageInfo(data, PackageManager.GET_UNINSTALLED_PACKAGES | PackageManager.GET_PERMISSIONS);
            String[] usesPermissionsArray = packageInfo.requestedPermissions;
            for (String usesPermissionName : usesPermissionsArray) {

                //得到每个权限的名字,如:android.permission.INTERNET
                System.out.println("usesPermissionName=" + usesPermissionName);
                builder.append(usesPermissionName);
                //通过usesPermissionName获取该权限的详细信息
                PermissionInfo permissionInfo = packageManager.getPermissionInfo(usesPermissionName, 0);

                //获得该权限属于哪个权限组,如:网络通信
//                PermissionGroupInfo permissionGroupInfo = packageManager.getPermissionGroupInfo(permissionInfo.group, 0);
//                System.out.println("permissionGroup=" + permissionGroupInfo.loadLabel(packageManager).toString());

                //获取该权限的标签信息,比如:完全的网络访问权限
                String permissionLabel = permissionInfo.loadLabel(packageManager).toString();
                System.out.println("permissionLabel=" + permissionLabel);

                //获取该权限的详细描述信息,比如:允许该应用创建网络套接字和使用自定义网络协议
                //浏览器和其他某些应用提供了向互联网发送数据的途径,因此应用无需该权限即可向互联网发送数据.
                String permissionDescription = permissionInfo.loadDescription(packageManager).toString();

                builder.append(" ").append(permissionDescription);
                boolean isHasPermission = PackageManager.PERMISSION_GRANTED == pm.checkPermission(permissionInfo.name, data);
                builder.append(" ").append(isHasPermission).append("\r");
                System.out.println("permissionDescription=" + permissionDescription);
                System.out.println("===========================================");
            }

        } catch (Exception e) {
            // TODO: handle exception
        }
        return builder.toString();

    }

    public String getAppMainActivity(String packageName) {
        StringBuilder builder = new StringBuilder();
        Intent mainIntent = new Intent(Intent.ACTION_MAIN, null);
        mainIntent.addCategory(Intent.CATEGORY_LAUNCHER);
        List<ResolveInfo> appList = context.getPackageManager().queryIntentActivities(mainIntent, 0);
        for (int i = 0; i < appList.size(); i++) {
            ResolveInfo resolveInfo = appList.get(i);
            String packageStr = resolveInfo.activityInfo.packageName;
            if (packageStr.equals(packageName)) {
                builder.append(resolveInfo.activityInfo.name).append("\n");
                break;
            }
        }
        return builder.toString();
    }

    public String getAppDetail(String data) {
        StringBuilder builder = new StringBuilder();
        try {
            PackageInfo packageInfo = context.getPackageManager().getPackageInfo(data, PackageManager.GET_UNINSTALLED_PACKAGES);
            builder.append(packageInfo.firstInstallTime).append("\r");
            builder.append(packageInfo.lastUpdateTime).append("\r");
            builder.append(packageInfo.applicationInfo.dataDir).append("\r");
            builder.append(packageInfo.applicationInfo.nativeLibraryDir);
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        return builder.toString();
    }

    public String getAllAppInfo(String data) {
        List<String> id = stringToList(data);
        StringBuilder builder = new StringBuilder();
        for (String packageName : id) {
            try {
                PackageInfo packages = context.getPackageManager().getPackageInfo(packageName, PackageManager.GET_UNINSTALLED_PACKAGES);
                builder.append(packages.applicationInfo.loadLabel(context.getPackageManager()));
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    builder.append("\r").append(packages.applicationInfo.minSdkVersion);
                } else {
                    builder.append("\r").append("null");
                }
//                Log.w("nightmare", packages.applicationInfo.nativeLibraryDir);
                builder.append("\r").append(packages.applicationInfo.targetSdkVersion);
                builder.append("\r").append(packages.versionName);
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    builder.append("\r").append(packages.getLongVersionCode()).append("\n");
                } else {
                    builder.append("\r").append(packages.versionCode).append("\n");
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
                    packname, PackageManager.GET_UNINSTALLED_PACKAGES);
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
