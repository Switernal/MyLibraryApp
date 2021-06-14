import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class ImageUtils {

// TODO: 处理图片
// 参数：原图路径
// 返回值：处理好的图片目录
  static Future<String> processImage(String originImagePath, String ISBN, String user_id) async {

    print(ISBN);

    File _originImage = File(originImagePath); // 原图文件
    var _compress; // 压缩操作
    File _compressedImage; // 压缩好的图片

    // 返回压缩后的图片,并赋值给_compressedImage
    _compress = _compressImage(originImagePath).then((value) => _compressedImage = value);

    // 获取文件路径
    // Directory tempDir = await getTemporaryDirectory(); // 临时目录
    // Directory appDir = await getApplicationDocumentsDirectory(); // 应用目录

    Directory extCacheDir;

    if (Platform.isIOS) {
      // iOS
      Directory getDirectory = await getTemporaryDirectory(); // 程序临时目录
      extCacheDir = getDirectory;
    } else {
      // 仅可用于 Android [iOS禁止访问外部存储]
      var extCacheDirList = await getExternalCacheDirectories(); // 外部存储Cache目录List
      // Directory getDirectory = await getTemporaryDirectory(); // 程序临时目录
      extCacheDir = extCacheDirList[0]; // 外存目录对象
    }

    // 外存目录字符串
    String cacheDir = extCacheDir.toString();

    // 字符串为：Directory = '...'，从中截取出...部分
    cacheDir = cacheDir.substring(cacheDir.indexOf("\'")+1, cacheDir.lastIndexOf("\'"));

    print(cacheDir);

    // 对压缩后的图片重命名
    _compressedImage.renameSync("${cacheDir}/${user_id}_${ISBN}.jpg");

    // 获取原图大小（单位: Byte）
    _originImage.length().then((value) => print("Origin: " + value.toString()));

    // 获取压缩后的图片大小（单位: Byte）
    //  _compress.then((value) {
    //    print("Compressed: " + value.lengthSync().toString());
    //  });

    // 删除原图
    _originImage.deleteSync();

    return "${cacheDir}/${user_id}_${ISBN}.jpg";
  }


// TODO:压缩图片函数
  static Future<File> _compressImage(String filePath) async {
    File compressedImage = await FlutterNativeImage.compressImage(filePath,
        quality: 50, percentage: 50);
    return compressedImage;
  }

  // 清除iOS的tmp目录,拍照会存在此目录中并且不会删除
  static Future<void> clearTmpFiles(FileSystemEntity file) async {
    if (Platform.isIOS) {
      if (file is Directory) {
        final List<FileSystemEntity> children = file.listSync();
        for (final FileSystemEntity child in children) {
          await clearTmpFiles(child);
          await child.delete();
        }
      }
    } else {
      print(Platform.environment);
      return;
    }
  }

  // 清除iOS的tmp目录下的图片,拍照会存在此目录中并且不会删除
  static Future<void> clearTmpImages(FileSystemEntity file) async {
    if (Platform.isIOS) {
      if (file is Directory) {
        final List<FileSystemEntity> children = file.listSync();
        for (final FileSystemEntity child in children) {
          if (child.path.contains(".jpg") || child.path.contains(".jpeg") || child.path.contains(".png")) {
            await child.delete();
          }
        }
      }
    } else {
      print(Platform.environment);
      return;
    }
  }
}