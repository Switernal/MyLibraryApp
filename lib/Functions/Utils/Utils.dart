import 'package:city_pickers/city_pickers.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:convert/convert.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:my_library/Home/Controller/ScannerPage.dart';
import 'package:yaml/yaml.dart';
import 'package:loading_indicator_view/loading_indicator_view.dart';
import 'package:flash/flash.dart';
import 'package:my_library/Functions/Widgets/CustomPicker.dart' as CustomPicker;


enum ToastMode {
  Success,
  Warning,
  Error,
  Loading,
  Message,
}

Map<ToastMode, dynamic> backgroundColors = {
  ToastMode.Success : Colors.green,
  ToastMode.Warning : Colors.yellow,
  ToastMode.Error : Colors.redAccent,
  ToastMode.Loading : Colors.white,
  ToastMode.Message : Colors.white,
};

Map<ToastMode, dynamic> textColors = {
  ToastMode.Success : Colors.white,
  ToastMode.Warning : Colors.black,
  ToastMode.Error : Colors.white,
  ToastMode.Loading : Colors.black,
  ToastMode.Message : Colors.black,
};

Map<ToastMode, dynamic> iconColors = {
  ToastMode.Success : Colors.green,
  ToastMode.Warning : Colors.amber,
  ToastMode.Error : Colors.red,
  ToastMode.Loading : Colors.black26,
  ToastMode.Message : Colors.black26,
};

Map<ToastMode, dynamic> icons = {
  ToastMode.Success : Icons.check,
  ToastMode.Warning : Icons.warning_amber_outlined,
  ToastMode.Error : Icons.close,
  ToastMode.Loading : Icons.rotate_right,
  ToastMode.Message : Icons.message,
};

/// 全局工具类
class Utils {

  static final String Version = "0.1 (1B102)";
  static final String UpdateDate = "2021.06.16";
  static final String VersionNote = "0.1 Beta Build 2";

  /// ai_barcode 扫描条码[安卓]
  static Future<String> scanBarcode_Android({@required BuildContext context}) async {
    var result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => ScannerPage()));
    return result;
  }

  // TODO: 苹果扫描条码的动作[安卓有问题]
  static Future<String> scanBarcode_iOS({@required bool mounted}) async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return "";

    // 返回给ISBN字符串
    return barcodeScanRes;
  }

  static void showToast(String text, BuildContext context, {ToastMode mode, int duration = 3}) {

    FToast fToast = FToast()..init(context);

    fToast.removeCustomToast();

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        // border: Border.all(color: Colors.black26),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            spreadRadius: 2,
            color: Color.fromARGB(20, 0, 0, 0),
          ),
        ],
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          mode == null ? Container() :
            Padding(padding: EdgeInsets.only(right: 10), child: Icon( icons[mode], color: iconColors[mode],), ),
          Text(
            text,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 15
            ),
          )
        ],
      ),
    );
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.TOP,
      toastDuration: Duration(seconds: duration),
    );
  }



  static void showToast_withDuration({@required String text, @required BuildContext context, @required int duration = 1}) {
    FToast fToast = FToast()..init(context);
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.black87,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
            ),
          )
        ],
      ),
    );
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.CENTER,
      toastDuration: Duration(seconds: duration),
    );
  }

  static Future<String> showPicker(List options, BuildContext context) async {
    String result;
    await Picker(
        height: 220,
        itemExtent: 38,
        adapter: PickerDataAdapter<String>(pickerdata: options),
        onConfirm: (Picker picker, List value) {
          result = options[value.first];
        }).showModal(context);
    return result ?? "";
  }

// 不知道怎么修改语言的日期选择器
  static Future<String> showPickerDate(BuildContext context) async {
    String result;
    await Picker(
        height: 220,
        itemExtent: 38,
        adapter: DateTimePickerAdapter(),
        onConfirm: (Picker picker, List value) {
          result = formatDate((picker.adapter as DateTimePickerAdapter).value,
              [yyyy, '-', mm, '-', dd]);
          print((picker.adapter as DateTimePickerAdapter).value.toString());
        }).showModal(context);
    return result ?? "";
  }


// 支持中文的日期选择器, 使用flutter_datetime_picker
  static Future<String> showPickerDate_Chinese(BuildContext context, {String current}) async {
    String result;



    await DatePicker.showDatePicker(context,
      locale: LocaleType.zh,
      currentTime: DateTime.tryParse(current) ?? DateTime.now(),
      onConfirm: (date) {
        result = formatDate(date ,['yyyy', '-', 'mm', '-', 'dd']);;
      },
      // 取消直接返回原串
      onCancel: () => result = current,
    );

    return result ?? "";
  }

  // 支持中文的日期选择器, 仅有年份和月份
  static Future<String> showPickerDate_Chinese_OnlyYearAndMonth(BuildContext context, {String current}) async {
    String result;

    await DatePicker.showDatePicker(context,
      currentTime: DateTime.tryParse(current) ?? DateTime.now(),
      locale: LocaleType.zh,
      onConfirm: (date) {
        result = formatDate(date ,['yyyy', '-', 'mm']);;
      },
      onCancel: () => result = current,
    );
    return result ?? "";
  }

  static Future<String> showPickerDate_OnlyYearAndMonth(BuildContext context) async {
    String result;
    await Picker(
        height: 220,
        itemExtent: 38,
        adapter: DateTimePickerAdapter(),
        onConfirm: (Picker picker, List value) {
          result = formatDate((picker.adapter as DateTimePickerAdapter).value,
              [yyyy, '-', mm]);
          print((picker.adapter as DateTimePickerAdapter).value.toString());
        }).showModal(context);
    return result ?? "";
  }

// 生成 md5
  static String md5_generator(var data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    // 这里其实就是 digest.toString()
    return hex.encode(digest.bytes);
  }

// 生成 SHA256
  static String sha256_generator(var data) {
    var content = new Utf8Encoder().convert(data);
    var digest = sha256.convert(content);
    // 这里其实就是 digest.toString()
    return hex.encode(digest.bytes);
  }

// 生成 SHA256
  static String sha512_generator(var data) {
    var content = new Utf8Encoder().convert(data);
    var digest = sha512.convert(content);
    // 这里其实就是 digest.toString()
    return hex.encode(digest.bytes);
  }

// 对密码进行加密
  static String EncryptPassword(String password) {
    password = password + "\u0066\u0077\u0073\u0062";
    var passwd1 = sha256_generator(password);
    var passwd2 = sha512_generator(passwd1);
    var passwd3 = md5_generator(passwd2);
    return passwd3;
  }

// 显示对话框
  static void showMessageDialog(String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text('提示'),
          content: new Text(message),
          actions: <Widget>[
            new FlatButton(
              child: new Text("好"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// 文本转json数据
  static dynamic textToJson(String text) {
    return json.decode(text);
  }

    /// 计算时间差(String格式: "yyyy-MM-dd HH:mm")
    static String timeDiffrence_String(String oldTime) {
      String nowTime = new DateTime.now().toString().split('.')[0].replaceAll('-', '/');

      int nowyear = int.parse(nowTime.split(" ")[0].split('/')[0]);
      int nowmonth = int.parse(nowTime.split(" ")[0].split('/')[1]);
      int nowday = int.parse(nowTime.split(" ")[0].split('/')[2]);
      int nowhour = int.parse(nowTime.split(" ")[1].split(':')[0]);
      int nowmin = int.parse(nowTime.split(" ")[1].split(':')[1]);

      int oldyear = int.parse(oldTime.split(" ")[0].split('/')[0]);
      int oldmonth = int.parse(oldTime.split(" ")[0].split('/')[1]);
      int oldday = int.parse(oldTime.split(" ")[0].split('/')[2]);
      int oldhour = int.parse(oldTime.split(" ")[1].split(':')[0]);
      int oldmin = int.parse(oldTime.split(" ")[1].split(':')[1]);

      var now = new DateTime(nowyear, nowmonth, nowday, nowhour, nowmin);
      var old = new DateTime(oldyear, oldmonth, oldday, oldhour, oldmin);
      var difference = now.difference(old);

      if(difference.inDays > 1) {
        return (difference.inDays).toString() + '天前';
      } else if(difference.inDays == 1) {
        return '昨天'.toString();
      } else if(difference.inHours >= 1 && difference.inHours < 24) {
        return (difference.inHours).toString() + '小时前';
      } else if(difference.inMinutes > 5 && difference.inMinutes < 60) {
        return (difference.inMinutes).toString() + '分钟前';
      } else if(difference.inMinutes <= 5) {
        return '刚刚';
      }
    }

    /// 计算时间差(DateTime)
    static String timeDiffrence_DateTime(DateTime oldDateTime) {
      String oldTime = oldDateTime.toString().split('.')[0].replaceAll('-', '/');
      String nowTime = new DateTime.now().toString().split('.')[0].replaceAll('-', '/');

      int nowyear = int.parse(nowTime.split(" ")[0].split('/')[0]);
      int nowmonth = int.parse(nowTime.split(" ")[0].split('/')[1]);
      int nowday = int.parse(nowTime.split(" ")[0].split('/')[2]);
      int nowhour = int.parse(nowTime.split(" ")[1].split(':')[0]);
      int nowmin = int.parse(nowTime.split(" ")[1].split(':')[1]);

      int oldyear = int.parse(oldTime.split(" ")[0].split('/')[0]);
      int oldmonth = int.parse(oldTime.split(" ")[0].split('/')[1]);
      int oldday = int.parse(oldTime.split(" ")[0].split('/')[2]);
      int oldhour = int.parse(oldTime.split(" ")[1].split(':')[0]);
      int oldmin = int.parse(oldTime.split(" ")[1].split(':')[1]);

      var now = new DateTime(nowyear, nowmonth, nowday, nowhour, nowmin);
      var old = new DateTime(oldyear, oldmonth, oldday, oldhour, oldmin);
      var difference = now.difference(old);

      if(difference.inDays > 1) {
        return (difference.inDays).toString() + '天前';
      } else if(difference.inDays == 1) {
        return '昨天'.toString();
      } else if(difference.inHours >= 1 && difference.inHours < 24) {
        return (difference.inHours).toString() + '小时前';
      } else if(difference.inMinutes > 5 && difference.inMinutes < 60) {
        return (difference.inMinutes).toString() + '分钟前';
      } else if(difference.inMinutes <= 5) {
        return '刚刚';
      }
    }

    /// 显示警告对话框
    static void ShowAlertDialog({
      @required BuildContext context,
      @required String title,
      String content = "",
      String buttonText1 = "确定", @required dynamic Action1, Color color1 = Colors.red,
      String buttonText2 = "取消", @required dynamic Action2, Color color2 = Colors.blue}) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(title),
              content: Text(content, style: TextStyle(fontSize: 15),),
              actions: [
                TextButton(onPressed: Action1,
                    child: Text(buttonText1,
                      style: TextStyle(color: color1, fontSize: 17),)),
                TextButton(onPressed: Action2,
                    child: Text(buttonText2,
                      style: TextStyle(color: color2, fontSize: 17),)),
              ],
            );
          }
      );
    }

    /// 加载网络图片状态
    static Widget loadNetWorkImage(ExtendedImageState state) {
      switch (state.extendedImageLoadState) {
        case LoadState.loading:
          return BallClipRotateIndicator();
          break;
        case LoadState.failed:
          return Icon(Icons.error_outline, color: Colors.red,);
      }
    }


    /// 自定义Picker(一层)
  static Widget picker_oneLevel(List<dynamic> dataList, BuildContext context) {

  }


  /// 弹出地址选择框
  static Future<Result> showCityPicker(BuildContext context, {String areaID = "210000", dynamic finishAction}) async {
    Result result = await CityPickers.showCityPicker(
      context: context,
      locationCode: areaID
    );

    if (finishAction != null) {
      finishAction();
    }

    return result;
  }

  /// 格式化日期(注意: 分钟为nn, 而不是mm)
  static String dateTimeToString(DateTime time) {
    return formatDate(time, ['yyyy','-','mm','-','dd',' ','HH',':','nn',':','ss']);
  }


  /// 获取文字中的double正则表达式
  static double getDoubleFromString(String text) {
    var reg = RegExp('[0-9]+(\\.[0-9]+)?', multiLine: true);
    return double.tryParse(reg.firstMatch(text).group(0)) ?? 0.0;
  }

  /// 检查手机号是否合法的正则表达式
  static bool isPhoneValid(String phone) {
    return RegExp(
        r'^((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9]))\d{8}$')
        .hasMatch(phone);
  }

    /*
    // 显示SnackBar(默认floating)
    static void showSnackBar(String text, BuildContext context, {Icon icon, int duration = 1, SnackBarBehavior style = SnackBarBehavior.floating}) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Row(
          children: <Widget>[
            icon == null ? icon : Container(),
            Text(text)],
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: duration),
      ));
    }

  // 显示SnackBar(默认floating)
  static void showSnackBar_withAction(String text, BuildContext context, {Icon icon, int duration = 1, SnackBarAction action, SnackBarBehavior style = SnackBarBehavior.floating}) {
    Builder(
      builder: (context) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Row(
            children: <Widget>[
              icon == null ? icon : Container(),
              Padding(padding: EdgeInsets.all(3)),
              Text(text)],
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: duration),
          action: action,
        ));
      }
    );
  }

     */

}