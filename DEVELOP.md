## 关于 app 信息获取
反复的尝试 MethodChannel 和 Socket后，最后选择了 Socket，因为在大量数据的情况下，MethodChannel 中 result.success 语句总是在主线程中执行，这
会直接使我们的 flutter app 处于卡死状态。

## 获取协议
**getIconData**:获取单个App Icon字节流，例如 getIconData com.nightmare

**getAllAppInfo**:获取多个App简略信息，例如 getAllAppInfo com.nightmare com.nightmare.adbtool
返回结构：
apkLabel minSdkVersion targetSdkVersion versionName versionCode

**getAllIconData**:获取多个App Icon字节流。
**getAppActivity**:获取单个App的activity的列表。
**getLibDir**:获取单个App的 lib 文件夹路径。