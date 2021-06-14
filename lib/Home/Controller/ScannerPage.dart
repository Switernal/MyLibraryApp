
import 'package:flutter/material.dart';


// Packages
import 'package:ai_barcode/ai_barcode.dart';
import 'package:permission_handler/permission_handler.dart';


// Pages
import '../../Functions/Utils/ScannerUtil.dart';

// Functions
import 'package:my_library/Functions/Utils/Utils.dart';
import 'package:my_library/MyBook/Function/SearchBookByISBN_Bamboo.dart';

class ScannerPage extends StatefulWidget {


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ScannerPageState();
  }
}

class ScannerPageState extends State<ScannerPage> {

  // 扫码控制器
  ScannerController _scannerController;

  // 闪光灯是否开启
  bool isFlashOpen = false;

  // 闪光灯按钮文字
  String flashText = "打开闪光灯";

  // 闪光灯按钮(默认为点击开启)
  Icon flashIcon = Icon(Icons.flash_on, color: Colors.white,);

  void _requestMobilePermission() async {
    var result = await Permission.camera.request();
    print(result);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _requestMobilePermission();

    _scannerController = ScannerController(
        scannerResult: (result) {
          print(result);
        },
        scannerViewCreated: () {
          TargetPlatform platform = Theme.of(context).platform;
          if (TargetPlatform.iOS == platform) {
            Future.delayed(Duration(seconds: 2), () {
              _scannerController.startCamera();
              _scannerController.startCameraPreview();

            });

          } else {
            _scannerController.startCamera();
            _scannerController.startCameraPreview();
          }
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("扫描条码"),
        actions: [
          FlatButton(
              child: Row(
                children: [
                  flashIcon,
                  Text(flashText, style: TextStyle(color: Colors.white),),
                ],
              ),
              onPressed: () {
            _scannerController.toggleFlash();
            isFlashOpen = !isFlashOpen;
            setState(() {
              flashIcon = isFlashOpen ?
                          Icon(Icons.flash_off, color: Colors.white,) :
                          Icon(Icons.flash_on, color: Colors.white,);
              flashText = isFlashOpen ? "关闭闪光灯" : "打开闪光灯";
            });
            // 如果开启闪光灯, 则关闭
            /*
            if (_scannerController.isOpenFlash) {
              setState(() {
                _scannerController.closeFlash();
                flashIcon = Icon(Icons.flash_on);
                print("Flash closed");
              });
            } else {
              // 如果关闭闪光灯, 则打开
              setState(() {
                _scannerController.openFlash();
                flashIcon = Icon(Icons.flash_off);
                print("Flash open");
              });
            }

             */
          })
        ],
      ),
      body: AppBarcodeScannerWidget.defaultStyle(resultCallback: (result) {
          Navigator.of(context).pop(result);
        },
      ),
          /*
      Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            //Expanded(flex: 1,child: Text("相机是否启动: " )),
            Expanded(flex: 1, child: PlatformAiBarcodeScannerWidget(
              platformScannerController: _scannerController,
            ),),
          ],
        )
      ),

           */
    );
  }
}