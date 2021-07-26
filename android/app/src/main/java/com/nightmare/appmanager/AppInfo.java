package com.nightmare.appmanager;

/**
 * Created by xdj on 2017/3/7.
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
    private static final int MESSAGE_MAX_SIZE = 1 << 18; // 256k

    public AppInfo(Context context) {
        this.context = context;
        pm = context.getPackageManager();
    }

    private static Socket connect() throws IOException {
        Socket socket = new Socket();
        socket.connect(new InetSocketAddress("localhost", 4041));
        return socket;
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

        System.out.println("执行中");
        System.out.println(ctx);
        new Thread(() -> {
            try {
                System.out.println("startIconServer");
                AppInfo.startIconServer(ctx);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }).start();
        new Thread(() -> {
            try {
                System.out.println("startAppInfoServer");
                AppInfo.startAppInfoServer(ctx);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }).start();

        System.out.println("wait");
        System.in.read();

    }

    public static void startIconServer(Context context) throws IOException {
        @SuppressLint("PrivateApi")
        ServerSocket serverSocket = new ServerSocket(4041);
        while (true) {
            Log.e("socket启动", "socket启动");
            Socket socket = serverSocket.accept();

            InputStream is = socket.getInputStream();
            BufferedReader br = new BufferedReader(new InputStreamReader(is));
            String packageName = br.readLine();
            OutputStream os = socket.getOutputStream();
            AppInfo appInfo = new AppInfo(context);
            Bitmap bitmap = appInfo.getBitmap(packageName);
            if (bitmap != null) {
                os.write(Bitmap2Bytes(bitmap));
            }
            socket.close();
        }
    }

    private static List<String> stringToList(String strs) {
        String[] str = strs.split(" ");
        return Arrays.asList(str);
    }

    public static void startAppInfoServer(Context context) throws IOException {
        @SuppressLint("PrivateApi")
        ServerSocket serverSocket = new ServerSocket(4042);
        while (true) {
//        Class<?> activityThreadClass = Class.forName("android.app.ActivityThread");
//        Constructor<?> activityThreadConstructor = activityThreadClass.getDeclaredConstructor();
//        activityThreadConstructor.setAccessible(true);
//        Object activityThread = activityThreadConstructor.newInstance();
            Log.e("socket启动", "socket启动");
            Socket socket = serverSocket.accept();

            InputStream is = socket.getInputStream();
            BufferedReader br = new BufferedReader(new InputStreamReader(is));
            OutputStream os = socket.getOutputStream();
            List<String> id = stringToList(br.readLine());
            StringBuilder builder = new StringBuilder();
            for (String packageName : id) {
                try {
                    PackageInfo packages = context.getPackageManager().getPackageInfo(packageName, 0);
                    builder.append(packages.applicationInfo.loadLabel(context.getPackageManager()));
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                        builder.append(" ").append(packages.applicationInfo.minSdkVersion);
                    }else{
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
            os.write(builder.toString().getBytes());
            socket.close();
        }
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


    /*
     * 获取程序的权限
     */
    public String[] getAppPremission(String packname) {
        try {
            PackageInfo packinfo = pm.getPackageInfo(packname, PackageManager.GET_PERMISSIONS);
            //获取到所有的权限
            return packinfo.requestedPermissions;

        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();

        }
        return null;
    }


    /*
     * 获取程序的签名
     */
    public String getAppSignature(String packname) {
        try {
            PackageInfo packinfo = pm.getPackageInfo(packname, PackageManager.GET_SIGNATURES);
            //获取到所有的权限
            return packinfo.signatures[0].toCharsString();

        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();

        }
        return null;
    }
}
