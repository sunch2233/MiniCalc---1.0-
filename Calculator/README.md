# MiniCalc - 安卓1.0计算器
- 支持 Android 1.0 (API Level 1)，minSdkVersion=1
- 源码约 **2.9KB**，APK仅 **5.3KB**
## 项目结构
```
Calculator/
├── LICENSE                        # MIT开源许可证
├── AndroidManifest.xml            # 清单
├── build.sh                       # 一键构建脚本
├── MiniCalc.apk                   # 预编译APK（5.3KB）
├── res/drawable/icon.xml          # 计算器图标（XML shape绘制）
└── src/com/minicalc/
    └── CalculatorActivity.java    # 主Activity，纯代码UI
```

## 图标设计
用 `layer-list` + `shape` + `inset` 纯XML绘制，API 1兼容：
- 深灰色圆角矩形外壳
- 顶部亮绿色LCD显示屏
- 底部三个浅灰色按键

## 体积优化手段
1. **纯代码创建UI**：无XML布局文件，用Java代码new控件
2. **XML shape图标**：比PNG小，且无需多密度资源
3. **label直接写死**：不引用@string资源
4. **SHA1签名**：兼容API 1，签名文件更小
5. **无signed attributes**：openssl -noattr 减小PKCS#7体积
6. **1024位RSA密钥**：比2048位证书小约40%

## 构建方法
```bash
export ANDROID_HOME=/path/to/android-sdk
./build.sh
```
## 体积统计
| 项目 | 大小 |
|------|------|
| 源码 | 2.9KB |
| APK | 5.3KB |
| classes.dex | 3.3KB |
| icon.xml | 2.5KB |
| AndroidManifest.xml | 1.9KB |
| 签名文件（META-INF） | 1.8KB |

## 安装
```bash
adb install MiniCalc.apk
```

## 开源协议
本项目采用 **MIT License** 开源，详见 [LICENSE](LICENSE) 文件。
您可以自由使用、修改、分发本项目源码及衍生作品。

