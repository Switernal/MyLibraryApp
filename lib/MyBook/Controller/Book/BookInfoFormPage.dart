import 'dart:io';
import 'dart:convert';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_library/Home/Controller/MyLibraryHomePage.dart';
import 'package:my_library/MyBook/Function/MyBookRequest.dart';
import 'package:my_library/Functions/Utils/ImageUtils.dart';

// Packages
import 'package:tform/tform.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_cropper/image_cropper.dart';

// Functions
import 'package:my_library/Functions/Utils/Utils.dart';
import 'package:my_library/Functions/Network/UploadImage.dart';
import 'package:my_library/Functions/Widgets/CustomPicker.dart';

// Models
import 'package:my_library/MyBook/Model/MyBookModel.dart';


/// 进入页面的模式
enum Mode {
  add_ISBN,
  add_Human,
  edit,
}

/// 更新封面菜单
enum ChooseImage {
  Camera,
  Album,
}

class BookInfoFormPage extends StatefulWidget {
  
  /// 进入页面的模式
  Mode mode = Mode.add_Human;
  
  /// 扫描输入的ISBN
  String ISBN = "";
  
  /// 图书对象,全局都用这个对象操作
  MyBookModel book = MyBookModel();

  /* 构造函数 */
  
  /// 从ISBN添加
  BookInfoFormPage.addfromISBN({@required this.ISBN}) {
    mode = Mode.add_ISBN;
    book.ISBN = this.ISBN;
  }
  
  /// 手动添加
  BookInfoFormPage.addfromHuman() {
    mode = Mode.add_Human;
  }
  
  /// 编辑模式
  BookInfoFormPage.edit({@required this.book}) {
    mode = Mode.edit;
    ISBN = book.ISBN;
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState

    return BookInfoFormPageState();
  }
}

class BookInfoFormPageState extends State<BookInfoFormPage> {

  // 表单通过GlobalKey获取,遍历表单组件获取值得内容
  final GlobalKey _BookInfoFormKey = GlobalKey<TFormState>();
  // form的state
  TFormState formState;

  /// 网络请求对象
  MyBookRequest request = MyBookRequest();

  /// 图书Map
  Map<String, dynamic> bookMap;

  /// 书架选择器
  List<TFormOptionModel> shelfOptions = [];

  /// 书架id和书架名对应Map
  Map<String, int> shelfMap = {};

  // 无ISBN按钮格式
  var ISBNButtonShape = RoundedRectangleBorder(
      side: BorderSide(
        color: Colors.white,
      )
  );
  Color ISBNButtonColor = Colors.blue;
  var ISBNButtonText = Text("有ISBN", style: TextStyle(color: Colors.white),);
  bool hasISBN = false;

  // 借出状态按钮格式
  var LentButtonShape = RoundedRectangleBorder(
      side: BorderSide(
          color: Colors.white
      )
  );
  Color LentButtonColor = Colors.blue;
  var LentButtonText = Text("未借出", style: TextStyle(color: Colors.white),);
  bool isLent = false;


  /// 初始化
  /// 如果是扫码添加图书模式或者是编辑模式, 则需要进行表单预填写
  void initForm() async {

    // 初始化请求
    await request.init();

    // 初始化formState
    formState = _BookInfoFormKey.currentState as TFormState;


    // book 先转 json 再转回 map
    bookMap = json.decode(json.encode(widget.book));

    // 获取书架
    var shelfs = await request.getShelfs();

    // 创建选项列表
    shelfs.forEach((shelf) {
      shelfOptions.add(TFormOptionModel(value: shelf.shelfName));
      shelfMap[shelf.shelfName] = shelf.shelfID;
    });

    switch (widget.mode) {

      // ISBN添加模式
      case Mode.add_ISBN:
        formState.rows.forEach((row) {
          if (row.tag == "ISBN") {
            row.value = widget.ISBN;
            return;
          }
        });
        break;

      // 编辑模式
      case Mode.edit:

          // 设置ISBN和借出按钮状态
          hasISBN = true;

          if (bookMap["lentOut"] == true) {
            setState(() {
              isLent = true;
              LentButtonText = Text("已借出");
              LentButtonColor = null;
              LentButtonShape = RoundedRectangleBorder(
                  side: BorderSide(
                      color: Colors.black
                  )
              );
            });
          }

          // 每行的tag和map中对应的key是一样的,直接赋值即可
          formState.rows.forEach((row) {
            if (row.tag != "blank") {
              if (bookMap[row.tag] != null) {
                row.value = bookMap[row.tag].toString();
              }

              if (row.tag == "lender") {
                setState(() {
                  row.enabled = isLent;
                });
              }

            }
          });
        setState(() {});
        return;
        break;
    }
  }


  // 完成按钮事件
  Future<void> finishEditingAction() async {
    // 设置封面url
    bookMap["coverUrl"] = widget.book.coverURL;
    // 设置是否借出字段
    bookMap["lentOut"] = isLent;
    // 设置每行对应的值, 遇到price和totalPages两行需要特别处理
    for (var row in formState.rows) {
      if (row.tag != "blank") {
        switch (row.tag) {
        // 如果设置了书柜,需要设置shelf_id
          case "shelfName":
            bookMap[row.tag] = row.value;
            if (shelfMap.containsKey(row.value)) {
              bookMap["shelf_id"] = shelfMap[row.value];
            }
            break;
          case "price":
            bookMap[row.tag] = (row.value == "" ? 0.00 : double.parse(row.value));
            break;
          case "totalPages":
            bookMap[row.tag] = (row.value == "" ? 0 : int.parse(row.value));
            break;
          case "null":
            bookMap[row.tag] = null;
            break;
          default:
            bookMap[row.tag] = row.value; break;
        }
      }
    }

    // 如果是新增图书, 需要自动生成ISBN编号,生成格式: ML-user_id-Time
    // 在按钮那里自动生成了
    /*
    if (hasISBN == false) {
      var time = (DateTime.now().millisecondsSinceEpoch).toString().substring(0, 10);
      var userID = request.UserID.toString();
      bookMap["isbn"] = "ML-" + userID + "-" + time;
    }
     */


    // 检查总页数是否为空并且需要转成int
    // 如果不转会出现 String is not a subtype of int错误

    //bookMap["price"] = (bookMap["price"] == "" ? 0.00 : double.parse(bookMap["totalPages"]));
    //bookMap["totalPages"] = (bookMap["totalPages"] == "" ? 0 : int.parse(bookMap["totalPages"]));
    // bookMap["readProgress"] = (bookMap["readProgress"] == "" ? 0 : bookMap["readProgress"]);


    // 转成MyBook对象
    widget.book = MyBookModel.fromJson_Network(bookMap);

    // 检查是否有必填行为空行
    var errors = formState.validate();
    if (errors.isNotEmpty) {
      Utils.showToast(errors.first, context, mode: ToastMode.Warning);
      return;
    }

    /// 请求结果
    var result;

    // 发送请求
    if (widget.mode == Mode.edit) {
      result = await request.updateBook(book: widget.book);
    } else {
      result = await request.addBook(newBook: widget.book);
    }

    switch (result) {
      case 1:
        Utils.showToast(widget.mode == Mode.edit ? "修改成功" : "添加成功", context, mode: ToastMode.Success);
        Navigator.pop(context, widget.book);
        break;
      case 0:
        Utils.showToast(widget.mode == Mode.edit ? "修改失败" : "添加失败", context, mode: ToastMode.Error);
        break;
      default:
        Utils.showToast("发生未知错误", context, mode: ToastMode.Error);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initForm());
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: widget.mode == Mode.edit ? Text("修改图书信息") : Text("新增书籍"),
        /*
        actions: [
          TextButton(child: Text("完成", style: TextStyle(color: Colors.white, fontSize: 15),), onPressed: () async => finishEditingAction(),),
        ],
        */
      ),
      body: TForm.builder(
        key: _BookInfoFormKey,
        rows: buildFormRows(),
        divider: Divider(
          height: 1,
        ),
      ),

      // 提交表单,通过tag字段填入Map中
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check), //Text("完成\n录入"),
        onPressed: () async => finishEditingAction(),
      ),
    );
  }


  PopupMenuButton<ChooseImage> selectPhotoMenu(BuildContext context) {
    return PopupMenuButton<ChooseImage>(
      child: TextButton(child: Text("上传封面", style: TextStyle(color: Colors.white),),),

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
          Utils.showToast("上传中...", context, mode: ToastMode.Loading, duration: 10);

          var result = await UploadImage.upload(imagePath: image.path, ISBN: widget.book.ISBN);
          if (result["code"] == 400) {
            Utils.showToast("上传失败, 请再试一次", context, mode: ToastMode.Error);
          } else {
            setState(() {
              widget.book.coverURL = result["url"];
            });
            Utils.showToast("上传成功", context, mode: ToastMode.Success);
          }
          // var result = await ImageUtils.processImage(image.path, widget.book.ISBN, "1");
          //ImageUtils.clearTmpImages(Directory(image.path.substring(0, image.path.lastIndexOf('/'))));
        }
      },
    );
  }

  List<TFormRow> buildFormRows() {

    print("buildFormRows");

    return [

      // 0 基本内容
      TFormRow.customCell(
        widget: Container(
            color: Colors.grey[100],
            height: 36,
            width: double.infinity,
            alignment: Alignment.bottomLeft,
            child: Text("基本内容"),
            padding: EdgeInsets.fromLTRB(15, 0, 0, 5),
        ),
        tag: "blank",
      ),

      // 1 书名
      TFormRow.input(
        require: true,
        requireStar: true,
        title: "书名",
        placeholder: "请输入书名",
        value: "",
        tag: "bookName",
        validator: (row) => (row != "" ? true : false),
        //clearButtonMode: OverlayVisibilityMode.editing,
        //onChanged: (row) => print(row.value),
      ),

      // 2 ISBN
      TFormRow.input(
        enabled: true,
        require: true,
        requireStar: false,
        title: "ISBN",
        tag: "isbn",
        placeholder: "请输入ISBN号",
        keyboardType: TextInputType.number,
        validator: (row) {
          if (hasISBN == true && row.value == ""){
            return false;
          }
          return true;
        },
        value: widget.mode == Mode.add_ISBN ? widget.ISBN : "",
        onChanged: (row) {
          widget.ISBN = row.value;
          widget.book.ISBN = row.value;
        },
        suffixWidget: (context, row) {

          if (widget.mode == Mode.edit) {
            row.enabled = false;
            return Container();
          }

            var noISBNButton = FlatButton(
                child: ISBNButtonText,
                shape: ISBNButtonShape,
                color: ISBNButtonColor,
                onPressed: () {
              setState(() {
                row.enabled = !row.enabled;
                hasISBN = row.enabled;

                if (row.enabled) {
                  ISBNButtonText = Text(
                    "有ISBN",
                    style: TextStyle(color: Colors.white),
                  );

                  ISBNButtonColor = Colors.blue;
                  ISBNButtonShape = RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.white,
                      ));
                  row.placeholder = "请输入ISBN号";
                  widget.book.ISBN = "";
                  row.value = widget.book.ISBN;
                  widget.ISBN = row.value;

                } else {
                  ISBNButtonText = Text(
                    "无ISBN",
                  );
                  ISBNButtonColor = null;
                  ISBNButtonShape = RoundedRectangleBorder(
                      side: BorderSide(color: Colors.black));
                  row.placeholder = "该书无ISBN号";

                  // 如果是新增图书, 需要自动生成ISBN编号,生成格式: ML-user_id-Time
                  var time = (DateTime.now().millisecondsSinceEpoch).toString().substring(0, 10);
                  var userID = request.UserID.toString();
                  widget.book.ISBN = "ML-" + userID + "-" + time;

                  row.value = widget.book.ISBN;
                  widget.ISBN = row.value;
                }
              });
            },
          );

          return noISBNButton;
        },
      ),

      // 3 上传封面
      TFormRow.customCellBuilder(
        title: "封面图片",
        tag: "blank",
        require: false,
        widgetBuilder: (context, row) {
          /// 如果没有封面图
          if (widget.book.coverURL == "https://i0.hdslb.com/bfs/album/5522dd1f5b742d1e1394a17f44d590646b63871d.gif") {//"https://www.hualigs.cn/image/60bcfe294addc.jpg") {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("封面图片"),
                  // 选择图片按钮
                  //selectPhotoMenu(context),
                  /*
                  RaisedButton(
                    padding: EdgeInsets.zero,
                    // 一个弹出菜单

                    onPressed: (){},
                  ),

                   */
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    height: 35,
                    child: selectPhotoMenu(context),
                    color: Colors.blue,
                  ),
                ],
              ),
            );
          } else {
            /// 如果有封面
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("封面图片"),
                  // 选择图片按钮

                  /*
                  RaisedButton(
                    // padding: EdgeInsets.zero,
                    // 一个弹出菜单
                    child: selectPhotoMenu(context),
                    color: Colors.blue,
                    onPressed: (){},
                  ),

                   */
                  // 上传封面按钮
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    height: 35,
                    child: selectPhotoMenu(context),
                    color: Colors.blue,
                  ),

                  // 删除封面按钮

                  FlatButton(
                    // 一个弹出菜单
                    child: Text("删除封面", style: TextStyle(color: Colors.white),),
                    color: Colors.red,
                    onPressed: (){
                      setState(() {
                        widget.book.coverURL = "https://i0.hdslb.com/bfs/album/5522dd1f5b742d1e1394a17f44d590646b63871d.gif";//"https://www.hualigs.cn/image/60bcfe294addc.jpg";
                      });
                    },
                  ),

                  Container(
                    height: 120,
                    // width: 50,
                    padding: EdgeInsets.zero,
                    child:
                    AspectRatio(
                        aspectRatio: 3.0 / 3.8, // 宽高比
                        child: ExtendedImage.network(
                          widget.book.coverURL,
                          cache: false,
                          fit: BoxFit.fitHeight,
                          enableLoadState: true,
                          loadStateChanged: (state) {
                            return Utils.loadNetWorkImage(state);
                          },
                        ),
                    ),



                  ),


                ],
              ),
            );
          }
        }
      ),


      // 4 书籍管理
      TFormRow.customCell(
        widget: Container(
            color: Colors.grey[100],
            height: 36,
            width: double.infinity,
            alignment: Alignment.bottomLeft,
            child: Text("书籍管理"),
            padding: EdgeInsets.fromLTRB(15, 0, 0, 5),
        ),
        tag: "blank",
      ),


      // 5 书架

      TFormRow.customSelector(
        require: false,
        title: "书架",
        tag: "shelfName",
        placeholder: "请选择所在书架",
        onTap: (context, row) async {
          var shelfNames = ["",];
          shelfMap.keys.toList().forEach((name) {
            shelfNames.add(name);
          });
          PickerTool.showStringPicker(context,
              title: "请选择书架",
              data: shelfNames,
              normalIndex: shelfMap.keys.toList().indexOf(row.value) ?? 0,
              clickCallBack: (index, value) {
                setState(() {
                  row.value = value;
                });

              }
          );
        },
        fieldConfig: TFormFieldConfig(
          selectorIcon: SizedBox.shrink(),
        ),
      ),

      /*
      TFormRow.selector(
        require: false,
        title: "书架",
        tag: "shelfName",
        placeholder: "请选择所在书架",
        options: shelfOptions,
        value: ""
      ),

       */

      // 6 备注
      TFormRow.input(
        enabled: true,
        requireStar: false,
        require: false,
        title: "备注",
        tag: "notes",
        placeholder: "请输入备注",
        value: "",
      ),

      // 7 借给
      TFormRow.input(
        enabled: false,
        require: false,
        requireStar: false,
        title: "借给",
        tag: "lender",
        placeholder: "请输入借出人的信息",
        value: "",
        suffixWidget: (context, row) {

          FlatButton noISBN = FlatButton(
            child: LentButtonText,
            shape: LentButtonShape,
            color: LentButtonColor,
            onPressed: () {
              setState(() {
                row.enabled = !row.enabled;
                isLent = row.enabled;

                if (row.enabled) {
                  LentButtonText = Text("已借出");
                  LentButtonColor = null;
                  LentButtonShape = RoundedRectangleBorder(
                      side: BorderSide(
                          color: Colors.black
                      )
                  );
                  row.placeholder = "请输入借出人姓名";
                  row.value = "";

                } else {
                  LentButtonText = Text("未借出", style: TextStyle(color: Colors.white),);
                  LentButtonColor = Colors.blue;
                  LentButtonShape = RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.white,
                      )
                  );
                  row.placeholder = "该书未借出";
                  row.value = "该书未借出";
                }

              });
            },
          );
          return noISBN;
        },
      ),

      // 8 购买信息
      TFormRow.customCell(
        widget: Container(
            color: Colors.grey[100],
            height: 36,
            width: double.infinity,
            alignment: Alignment.bottomLeft,
            child: Text("购买信息"),
            padding: EdgeInsets.fromLTRB(15, 0, 0, 5),
        ),
        tag: "blank",
      ),

      // 9 购买渠道
      TFormRow.input(
        enabled: true,
        require: false,
        requireStar: false,
        title: "购买渠道",
        tag: "buyFrom",
        textAlign: TextAlign.right,
        placeholder: "请输入购买渠道(淘宝/京东/书店/...)",
        value: "",
      ),

      // 10 购买日期
      TFormRow.customSelector(
        require: false,
        title: "购买日期",
        tag: "buyDate",
        placeholder: "请选择购买日期",
        onTap: (context, row) async {
          return Utils.showPickerDate_Chinese(context, current: row.value);
        },
        fieldConfig: TFormFieldConfig(
          selectorIcon: SizedBox.shrink(),
        ),
      ),

      // 11 买入价格
      TFormRow.input(
        require: false,
        enabled: true,
        requireStar: false,
        title: "买入价格",
          tag: "price",
        textAlign: TextAlign.right,
        placeholder: "请输入价格",
        keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
        value: "",
        suffixWidget: (context, row) {
          return Text("元");
        }
      ),

      // 12 详细信息
      TFormRow.customCell(
        widget: Container(
            color: Colors.grey[100],
            height: 36,
            width: double.infinity,
            alignment: Alignment.bottomLeft,
            child: Text("详细信息"),
            padding: EdgeInsets.fromLTRB(15, 0, 0, 5),
        ),
        tag: "blank",
      ),

      // 13 作者
      TFormRow.input(
        require: false,
        enabled: true,
        requireStar: false,
        title: "作者",
        tag: "author",
        textAlign: TextAlign.right,
        placeholder: "请输入作者姓名",
        value: "",
      ),

      // 14 译者
      TFormRow.input(
        require: false,
        enabled: true,
        requireStar: false,
        title: "译者",
        tag: "translator",
        textAlign: TextAlign.right,
        placeholder: "请输入译者姓名",
        value: "",
      ),

      // 15 出版社
      TFormRow.input(
        require: false,
        enabled: true,
        requireStar: false,
        title: "出版社",
        tag: "press",
        textAlign: TextAlign.right,
        placeholder: "请输入出版社信息",
        value: "",
      ),

      // 16 出版日期
      TFormRow.customSelector(
        require: false,
        title: "出版日期",
        tag: "publicationDate",
        placeholder: "请选择出版日期(年-月)",
        onTap: (context, row) async {
          //return Utils.showPickerDateOnlyYearAndMonth(context);
          return Utils.showPickerDate_Chinese_OnlyYearAndMonth(context, current: row.value);
        },
        fieldConfig: TFormFieldConfig(
          selectorIcon: SizedBox.shrink(),
        ),
      ),


      // 17 总页数
      TFormRow.input(
        require: false,
        enabled: true,
        requireStar: false,
        title: "总页数",
        tag: "totalPages",
        textAlign: TextAlign.right,
        placeholder: "请输入该书的总页数",
        value: "",
      ),

      // 18 简介信息
      TFormRow.customCell(
        widget: Container(
            color: Colors.grey[100],
            height: 36,
            width: double.infinity,
            alignment: Alignment.bottomLeft,
            child: Text("简介信息"),
            padding: EdgeInsets.fromLTRB(15, 0, 0, 5),
        ),
        tag: "blank",
      ),


      // 19 内容简介
      TFormRow.input(
        require: false,
        enabled: true,
        requireStar: false,
        title: "内容简介",
        tag: "contentIntroduction",
        placeholder: "",
        value: "",
      ),

      // 20 作者简介
      TFormRow.input(
        require: false,
        enabled: true,
        requireStar: false,
        title: "作者简介",
        tag: "authorIntroduction",
        placeholder: "",
        value: "",
      ),

    ];
  }
}