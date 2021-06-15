import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_library/Functions/Network/UploadImage.dart';
import 'package:my_library/Functions/Utils/LocalStorageUtils.dart';
import 'package:my_library/Functions/Utils/Picker.dart';
import 'package:my_library/Functions/Utils/Utils.dart';
import 'package:my_library/Shop/Function/ShopRequest.dart';
import 'package:my_library/Shop/Model/ShopBookModel.dart';
import 'package:tform/tform.dart';

// 进入页面的模式
enum PublishMode {
  add,
  edit,
}

/// 更新封面菜单
enum ChooseImage {
  Camera,
  Album,
}

class PublishBookPage extends StatefulWidget {

  // 编辑模式
  PublishMode publishMode;
  
  // 要发布的图书信息
  ShopBookModel bookToPublish;

  // 刷新 我发布的 页面
  dynamic refreshGoodsList;

  PublishBookPage({@required this.bookToPublish, 
                   this.publishMode = PublishMode.add,
                   this.refreshGoodsList
  });

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PublishBookPageState();
  }
}

class PublishBookPageState extends State<PublishBookPage> {

  // 品相控制
  int appearance = -1;

  // 是否免费
  bool isFree = false;
  // 是否包邮
  bool isNoExpressPrice = false;

  // 输入控制器(2个, 控制价格和运费)
  List<TextEditingController> _textControllers = [TextEditingController(), TextEditingController(), TextEditingController(),];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _textControllers[0].text = widget.bookToPublish.introduction;

    if (widget.publishMode == PublishMode.edit) {
      appearance = widget.bookToPublish.appearance;
      _textControllers[1].text = widget.bookToPublish.price_now.toString();
      _textControllers[2].text = widget.bookToPublish.expressPrice.toString();
    }

  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text(widget.publishMode == PublishMode.add ? "发布二手书" : "编辑二手书"),),
      bottomNavigationBar: BottomNavigationArea(context),
      body: TForm.builder(
        rows: buildFormRows(),
      ),
    );
  }

  /// 上传封面
  PopupMenuButton<ChooseImage> selectPhotoMenu(BuildContext context) {
    return PopupMenuButton<ChooseImage>(

      child: Text("上传封面", style: TextStyle(color: Colors.white),),

      //icon: Icon(Icons.upload_file),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<ChooseImage>>[
        const PopupMenuItem<ChooseImage>(
          value: ChooseImage.Camera,
          child: Text("拍照"),
        ),
        const PopupMenuItem<ChooseImage>(
          value: ChooseImage.Album,
          child: Text('从相册选择'),
        )
      ],
      onSelected: (option) async {
        // var picker = ImagePicker();
        var image = null;
        if (option == ChooseImage.Camera) {

          image = await ImagePicker().getImage(source: ImageSource.camera);
        } else {
          image = await ImagePicker().getImage(source: ImageSource.gallery);
        }

        // print(image.path.substring(0, image.path.lastIndexOf('/')));

        image = await ImageCropper.cropImage(
            sourcePath: image.path,
            aspectRatio: CropAspectRatio(ratioX: 3, ratioY: 4.25),
            // aspectRatioPresets: [
            //   CropAspectRatioPreset.square,
            //   CropAspectRatioPreset.ratio3x2,
            //   CropAspectRatioPreset.original,
            //   CropAspectRatioPreset.ratio4x3,
            //   CropAspectRatioPreset.ratio16x9
            // ],
            androidUiSettings: AndroidUiSettings(
                toolbarTitle: '剪裁封面图片',
                toolbarColor: Colors.blue,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: true
            ),
            iosUiSettings: IOSUiSettings(
              minimumAspectRatio: 1.0,
              aspectRatioPickerButtonHidden: true,
            )
        );

        if (image != null) {
          Utils.showToast("上传中...", context, mode: ToastMode.Loading, duration: 5);

          var result = await UploadImage.upload(imagePath: image.path, ISBN: widget.bookToPublish.ISBN);
          if (result["code"] == 400) {
            Utils.showToast("上传失败, 请再试一次", context, mode: ToastMode.Error);
          } else {
            setState(() {
              widget.bookToPublish.coverURL = result["url"];
            });
            Utils.showToast("上传成功", context, mode: ToastMode.Success);
          }
          // var result = await ImageUtils.processImage(image.path, widget.book.ISBN, "1");
          //ImageUtils.clearTmpImages(Directory(image.path.substring(0, image.path.lastIndexOf('/'))));
        }
      },
    );
  }

  /// 商品详情区域
  Widget BookDetailArea() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 3.0 / 3.8, // 宽高比
                  child: Container(
                    //height: 20,
                    //padding: EdgeInsets.zero,
                    child: ExtendedImage.network(
                      widget.bookToPublish.coverURL,
                      cache: true,
                      fit: BoxFit.fitHeight,
                      mode: ExtendedImageMode.gesture,
                      enableLoadState: true,
                      loadStateChanged: (state) {
                        return Utils.loadNetWorkImage(state);
                      },
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 15),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    //设置四周圆角 角度
                    borderRadius: BorderRadius.all(Radius.circular(3.0)),
                    //设置四周边框
                    border: new Border.all(width: 1, color: Colors.transparent),
                    boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 1.0)],
                  ),
                  height: 30,
                  width: double.infinity,
                  child: Center(child: selectPhotoMenu(context),),
                ),
              ],
            )
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.only(left: 20,),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.bookToPublish.bookName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),),
                      Padding(padding: EdgeInsets.all(3),),
                      Text(
                        "作者：" + widget.bookToPublish.author,
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(3),),
                      Text(
                        "ISBN：" + widget.bookToPublish.ISBN,
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(3),),
                      Text("原价 ￥" + widget.bookToPublish.price_origin.toStringAsFixed(2)),

                    ],
                  ),),


                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 整体图书区域
  /*
  Widget BookArea() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("订单详情", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
              Divider(),
            ],
          ),
        ),
        BookDetailArea(),
      ],
    );
  }
  */

  // 底部固定栏,购买和购物车按钮
  Widget BottomNavigationArea(BuildContext context) {
    return Container(
      //height: 85,
      padding: EdgeInsets.fromLTRB(30, 5, 30, 20),
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide( // 设置单侧边框的样式
                color: Colors.grey,
                width: 0.3,
                style: BorderStyle.solid,
              )
          )
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [

          FlatButton(
            //colorBrightness: Brightness.dark,
            //splashColor: Colors.blueAccent,
            color: Colors.blue,
            shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            child: Text("发布", style: TextStyle(color: Colors.white),),
            onPressed: () async {

              print(this.appearance);

              // 先对表单进行合法性判断
              if (appearance == -1) {
                Utils.showToast("请选择图书的品相", context, mode: ToastMode.Warning);
                return;
              }

              // 如果没填写价格
              if (_textControllers[1].text == "") {
                if (isFree == false) {
                  Utils.showToast("价格不能为空", context, mode: ToastMode.Warning);
                  return;
                }

              } else {
                // 如果价格填的不是数字
                if (double.tryParse(_textControllers[1].text) == null) {
                  Utils.showToast("请输入正确的价格", context, mode: ToastMode.Warning);
                  return;
                } else {
                  // 如果价格填了负数
                  if (double.tryParse(_textControllers[1].text) < 0) {
                    Utils.showToast("请输入正确的价格", context, mode: ToastMode.Warning);
                    return;
                  }
                }
              }

              // 如果没填写运费, 默认包邮
              if (_textControllers[2].text == "") {
                if (isNoExpressPrice == false) {
                  Utils.showToast("请输入运费", context, mode: ToastMode.Warning);
                  return;
                }

              } else {
                // 如果价格填的不是运费
                if (double.tryParse(_textControllers[2].text) == null) {
                  Utils.showToast("请输入正确的运费", context, mode: ToastMode.Warning);
                  return;
                } else {
                  // 如果运费填了负数
                  if (double.tryParse(_textControllers[2].text) < 0) {
                    Utils.showToast("请输入正确的运费", context, mode: ToastMode.Warning);
                    return;
                  }
                }
              }

              // 如果上面没有错误, 执行下面的购买操作

              // 1. 设置品相
              widget.bookToPublish.appearance = this.appearance;
              // 2. 设置简介
              widget.bookToPublish.introduction = _textControllers[0].text;
              // 2. 设置发布时间
              widget.bookToPublish.createTime = DateTime.now();
              // 3. 设置发布价格
              widget.bookToPublish.price_now = double.tryParse(_textControllers[1].text) ?? 0.0;
              // 4. 设置运费
              widget.bookToPublish.expressPrice = double.tryParse(_textControllers[2].text) ?? 0.0;
              // 5. 设置发布者ID
              int publisherID = await LocalStorageUtils.getUserID_Local();
              widget.bookToPublish.userID = publisherID;

              switch (widget.publishMode) {
                /// * 新增请求
                case PublishMode.add:
                  // 向服务器发送发布商品请求
                  int result = await ShopRequest().addShopBook(good: widget.bookToPublish);
                  // 根据订单创建结果执行操作
                  switch (result) {
                    case 1:
                      Utils.showToast("发布成功", context, mode: ToastMode.Success);
                      // 刷新商店首页
                      //widget.refreshShopHomeData();
                      Navigator.pop(context);
                      break;

                    default:
                      Utils.showToast("发布失败", context, mode: ToastMode.Error);
                      return;
                  }
                  break;


                /// * 修改请求
                case PublishMode.edit:
                  // 向服务器发送发布商品请求
                  int result = await ShopRequest().changeGoods(good: widget.bookToPublish);
                  // 根据订单创建结果执行操作
                  switch (result) {
                    case 1:
                      Utils.showToast("修改成功", context, mode: ToastMode.Success);
                      // 刷新商店首页
                      widget.refreshGoodsList();
                      Navigator.pop(context);
                      break;

                    default:
                      Utils.showToast("修改失败", context, mode: ToastMode.Error);
                      return;
                  }
                  break;
              } // switch mode


            },
          ),
        ],
      ),
    );
  }

  /// 表单组件
  List<TFormRow> buildFormRows() {
    return [
      // 0 图书摘要
      TFormRow.customCellBuilder(
          require: false,
          title: "图书摘要",
          tag: "blank",
          widgetBuilder: (context, row) {
            return Container(
              padding: EdgeInsets.only(left: 15, right: 15, top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("图书摘要", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                  Divider(),
                ],
              ),
            );
          }
      ),

      // 1 图书详细信息
      TFormRow.customCellBuilder(
          require: false,
          title: "图书信息",
          tag: "bookDetail",
          widgetBuilder: (context, row) {
            return BookDetailArea();
          }
      ),

      // 2 设置品相
      TFormRow.customSelector(
        require: false,
        title: "品相",
        tag: "appearance",
        placeholder: "请选择品相",
        suffixWidget: (context, row) {
          return Icon(Icons.arrow_forward_ios_outlined, size: 18,);
        },
        value: widget.publishMode == PublishMode.edit ?
          ShopBookModel.appearanceList[widget.bookToPublish.appearance] : "",
        onTap: (context, row) async {
          PickerTool.showStringPicker(context,
              title: "选择图书品相",
              data: ShopBookModel.appearanceList,
              normalIndex: 0,
              clickCallBack: (index, value) {
                setState(() {
                  row.value = value;
                  this.appearance = index;
                });

              }
          );
        },
        fieldConfig: TFormFieldConfig(
          selectorIcon: SizedBox.shrink(),
        ),
      ),

      // 内容简介
      TFormRow.customCellBuilder(
          require: true,
          title: "内容简介",
          tag: "introduction",
          widgetBuilder: (context, row) {

            var _scrollController = ScrollController();

            return Container(
              padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
              child: Row(
                children: [
                  Text("简介", style: TextStyle(fontSize: 14)),

                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: Scrollbar(
                        controller: _scrollController,
                        isAlwaysShown: true,
                        child: TextField(
                          minLines: 1,
                          maxLines: 10,
                          controller: _textControllers[0],
                          keyboardType: TextInputType.text,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          textAlign: TextAlign.start,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10.0 , vertical: 1),
                            hintText: "输入简介, 更容易卖出哦",
                            hintStyle: TextStyle(color: Colors.black38),
                            fillColor: Colors.white,
                            filled: true,
                            //未获得焦点边框设为
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 0.0, ),
                            ),
                            //获得焦点边框设为
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue,
                                width: 0.5, ),
                            ),

                          ),
                        ),
                      )
                    ),
                  ),
                ],
              ),
            );
          }
      ),

      // 3 设置价格
      TFormRow.customCellBuilder(
          require: false,
          title: "设置价格",
          tag: "blank",
          widgetBuilder: (context, row) {
            return Container(
              padding: EdgeInsets.only(left: 15, right: 15, top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("设置价格", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                  Divider(),
                ],
              ),
            );
          }
      ),

      // 4 设置售价
      TFormRow.customCellBuilder(
          require: true,
          title: "价格",
          tag: "price",
          widgetBuilder: (context, row) {
            return Container(
              padding: EdgeInsets.only(left: 15, right: 15, top: 10),
              child: Row(
                children: [
                  Text("价格", style: TextStyle(fontSize: 14)),

                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: TextField(
                        onChanged: (name) {
                          // TODO:
                        },
                        enabled: !isFree,
                        controller: _textControllers[1],
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(fontSize: 18, color: Colors.red),
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10.0 , vertical: 1),
                          hintText: "￥0.00",
                          hintStyle: TextStyle(color: Colors.black38),
                          //labelStyle: TextStyle(fontSize: 18, color: Colors.red),
                          prefixText: "￥",
                          prefixStyle: TextStyle(color: Colors.red),
                          fillColor: Colors.white,
                          filled: true,
                          //未获得焦点边框设为蓝色
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 0.0, ),
                          ),
                          //获得焦点边框设为红色
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red,
                              width: 0.5 ),
                          ),

                        ),
                      ),
                    ),
                  ),

                  IconButton(icon: Icon(isFree ? Icons.check_box_outlined: Icons.check_box_outline_blank, size: 20, color: Colors.blue,),
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        setState(() {
                          isFree = !isFree;
                          _textControllers[1].text = "";
                        });
                      }),
                  Text("免费", style: TextStyle(fontSize: 14),),

                ],
              ),
            );
          }
      ),


      // 5 设置运费
      TFormRow.customCellBuilder(
          require: true,
          title: "运费",
          tag: "expressPrice",
          widgetBuilder: (context, row) {
            return Container(
              padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
              child: Row(
                children: [
                  Text("运费", style: TextStyle(fontSize: 14)),

                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: TextField(
                        onChanged: (name) {
                          // TODO:
                        },
                        enabled: !isNoExpressPrice,
                        controller: _textControllers[2],
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(fontSize: 18, color: Colors.red),
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10.0 , vertical: 1),
                          hintText: "￥0.00",
                          hintStyle: TextStyle(color: Colors.black38),
                          //labelStyle: TextStyle(fontSize: 18, color: Colors.red),
                          prefixText: "￥",
                          prefixStyle: TextStyle(color: Colors.red),
                          fillColor: Colors.white,
                          filled: true,
                          //未获得焦点边框设为蓝色
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 0.0, ),
                          ),
                          //获得焦点边框设为蓝色
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red,
                              width: 0.5, ),
                          ),

                        ),
                      ),
                    ),
                  ),

                  IconButton(icon: Icon(isNoExpressPrice ? Icons.check_box_outlined: Icons.check_box_outline_blank, size: 20, color: Colors.blue,),
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        setState(() {
                          isNoExpressPrice = !isNoExpressPrice;
                          _textControllers[2].text = "";
                        });
                      }),
                  Text("包邮", style: TextStyle(fontSize: 14),),
                ],
              ),
            );
          }
      ),

    ];
  }
}