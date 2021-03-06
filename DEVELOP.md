## 对外暴露的方法
此项目是一个Flutter Package，除了可以独立的运行外，还可以被其他的 Flutter Applicition 集成。

## App信息获取协议
反复的尝试 MethodChannel 和 Socket后，最后选择了 Socket，因为在大量数据的情况下，MethodChannel 中 result.success 语句总是在主线程中执行，这
会直接使我们的 flutter app 处于卡死状态。
并且，不仅是Flutter会用到这个功能，它的场景也越来越复杂，最后使用Socket实现一个服务端，任何的语言都能与此通信。
分以下几种数据响应:

**1.getIconData**

获取单个App Icon字节流，例如 `getIconData com.nightmare`
```sh
// 直接返回字节流
```

**2.getAllAppInfo**

获取多个App简略信息，例如 `getAllAppInfo com.nightmare com.nightmare.adbtool`
```sh
// 返回下列信息拼接的字符串
apkLabel minSdkVersion targetSdkVersion versionName versionCode
```

**3.getAllIconData**

获取多个App Icon字节流。
```sh
// 返回所有图片拼接的字节流，所以需要根据 PNG 图片的编码的图片头进行拆分。
```

**4.getAppActivity**

获取单个App的activity的列表。
```sh
// 例如
["com.nightmare.MainActivity","com.nightmare.termare"]
```

**5.getAppDetail**

获取App详细信息
```sh
// 返回下列信息拼接的字符串
应用安装时间 最近更新时间 Apk大小 ApkMd5 ApkSha1 ApkSha256 私有文件路径 lib路径
```
## PC端信息获取
pm 命令不支持详细信息，图标的获取，所以还是通过套接字收发消息的机制，
App 运行在安卓上时，会有套接字的服务端，而运行在 PC 平台的时候，我们
又如何运行这个套接字服务端呢？

分以下几步:

**1.Adb push apk 内的精简 dex 到安卓设备的 /data/loacl/tmp 文件夹**

**2.用 app_process 命令执行 dex，服务端运行。**

**3.PC 端执行 Adb forward 进行端口转发**

**4.连接 Socket，获取数据。**

## 隐藏/冻结类 App 筛选


## 备份功能实现
需要关注的细节是，当 App 被卸载重新安装后，App uid 是会改变的，
tar 解压会回复重装前 app 的 uid。

### 备份
```sh
tar -zcvf $gz $dataDir
```

### 恢复
```sh
tar -xvf     sysconfig.tar -C /
chown -R  10590:10590 /data/data/com.nightmare.adbtools/
```