import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_library/Functions/Utils/LocalStorageUtils.dart';
import 'package:my_library/User/Model/UserModel.dart';
import 'package:tform/tform.dart';

import 'package:my_library/Functions/Widgets/verifitionc_code_button.dart';
import 'package:my_library/Functions/Utils/Utils.dart';

import 'package:my_library/User/Function/UserRequest.dart';
import 'dart:convert';

enum UserMode {
  add,
  edit,
}

// 手机号是否合法
bool isPhoneNumberValid = false;
// 是否同意
bool _isAgree = false;
var _checkIcon = Icons.check_box_outline_blank;
// 第一次输入密码
String firstPasswd = null;
String oldPassword = "";

// 表单中的值
List values = [];
// 表单中的错误信息
List errors = [];
// 用户信息
Map<String, String> newUserInfo = {
  "username": null,
  "email": null,
  "phone": null,
  "password": null
};

class UserSignUpPage extends StatefulWidget {

  /// 页面模式
  UserMode mode;

  /// 修改信息用的临时存储用户信息
  UserModel nowUser;

  UserSignUpPage({this.mode = UserMode.add, @required this.nowUser}) {
    // 如果是编辑模式, 手机号默认合法
    isPhoneNumberValid = mode == UserMode.edit ? true : false;

    /// 填上个人信息
    newUserInfo["username"] = nowUser.userName;
    newUserInfo["email"] = nowUser.email;
    newUserInfo["phone"] = nowUser.phone;
    newUserInfo["password"] = nowUser.password;
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return UserSignUpPageState();
  }
}


class UserSignUpPageState extends State<UserSignUpPage> {


  /// 获取当前用户信息
  /*
  Future<UserModel> getUserInfo() async {
    var user;
    if (widget.mode == UserMode.edit) {
      var userID = await LocalStorageUtils.getUserID_Local();
      nowUser = await UserRequest().getUserByID(userID);
    } else {
      nowUser = UserModel();
    }
    return user;
  }
  */

  @override
  void initState() {
    // TODO: implement initState
    print(_formKey.currentState);
    super.initState();
  }

  // 表单通过GlobalKey获取,遍历表单组件获取值得内容
  final GlobalKey _formKey = GlobalKey<TFormState>();

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text(widget.mode == UserMode.add ? "注册用户" : "修改个人信息")),
      body: TForm.builder(
            key: _formKey,
            rows: buildFormRows(),
            divider: Divider(
              height: 1,
            ),
          ),

      // 提交表单,遍历组件获取值
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () async {
          values.clear();

          var state = _formKey.currentState as TFormState;
          for (var row in state.rows) {
            values.add(row.value);
          }
          // 移除最后一项(自定义cell)
          values.removeLast();

          // 检查错误
          errors = state.validate();

          if (errors.isNotEmpty) {
            Utils.showToast(errors.first, context,  mode: ToastMode.Warning);
            return null;
          } else {
            if (values[3] != "3972") {
              Utils.showToast("验证码不正确", context, mode: ToastMode.Error);
              return null;
            }

            if (widget.mode == UserMode.edit) {
              if (Utils.EncryptPassword(oldPassword) != widget.nowUser.password) {
                Utils.showToast("旧密码不正确", context, mode: ToastMode.Error);
                return;
              }
            }
            if (values[5] != values[6]) {
              Utils.showToast("两次输入密码不一致", context, mode: ToastMode.Error);
              return null;
            }
            if (values[1] != "" &&
                !RegExp(r'^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$')
                    .hasMatch(values[1])) {
              Utils.showToast("请输入正确的邮箱", context, mode: ToastMode.Warning);
              return null;
            }
          }

          // 设置map
          newUserInfo["username"] = values[0];
          newUserInfo["email"] = values[1];
          newUserInfo["phone"] = values[2];
          newUserInfo["password"] =
              Utils.EncryptPassword(values[5]); // 密码进行3重加密

          print(newUserInfo);

          if (_isAgree == false) {
            Utils.showToast("请先同意《用户协议》和《隐私政策》", context,
                mode: ToastMode.Warning);
            return;
          }

          switch (widget.mode) {
            case UserMode.add:
              Utils.showToast("注册中...", context, mode: ToastMode.Loading, duration: 6);

              var request = UserRequest();
              await request.init();
              var statuCode = await request.Register(newUserInfo);

              switch (statuCode) {
                case 1:
                  Utils.showToast("注册成功", context, mode: ToastMode.Success);
                  Navigator.pop(context);
                  break;
                case 0:
                  Utils.showToast("用户已存在, 请直接登录", context, mode: ToastMode.Message);
                  break;
                default:
                  Utils.showToast("未知错误", context, mode: ToastMode.Error);
                  break;
              }
              break;

            case UserMode.edit:
              
              Utils.showToast("修改中...", context, mode: ToastMode.Loading, duration: 5);

              var request = UserRequest();
              await request.init();
              var statuCode = await request.Update(newUserInfo);

              switch (statuCode) {
                case 1:
                  Utils.showToast("修改成功", context, mode: ToastMode.Success);
                  Navigator.pop(context);
                  break;

                default:
                  Utils.showToast("修改失败", context, mode: ToastMode.Error);
                  break;
              }
              break;
          }
        }, // onPressed
      ),
    );
  }

  List<TFormRow> buildFormRows() {
    return [
      // 0
      TFormRow.input(
        requireStar: true,
        title: "用户名",
        placeholder: "请输入用户名",
        clearButtonMode: OverlayVisibilityMode.editing,
        //onChanged: (row) => print(row.value),
        validator: (row) => row.value != "",
        value: newUserInfo["username"] ?? "",
      ),

      // 1
      TFormRow.input(
        requireStar: true,
        require: true,
        title: "邮箱",
        placeholder: "请输入邮箱",
        clearButtonMode: OverlayVisibilityMode.editing,
        value: newUserInfo["email"] ?? "",
        //onChanged: (row) => print(row.value),
      ),

      // 2
      TFormRow.input(
        keyboardType: TextInputType.number,
        title: "手机号",
        placeholder: "请输入手机号",
        maxLength: 11,
        requireMsg: "请输入正确的手机号",
        requireStar: true,
        clearButtonMode: OverlayVisibilityMode.editing,
        //textAlign: TextAlign.right,
        validator: (row) {
          return RegExp(
                  r'^((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9]))\d{8}$')
              .hasMatch(row.value);
        },
        onChanged: (row) {
          isPhoneNumberValid = RegExp(
                  r'^((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9]))\d{8}$')
              .hasMatch(row.value);
        },
        tag: "手机号",
        value: newUserInfo["phone"] ?? "",
      ),

      // 3
      TFormRow.input(
        title: "验证码",
        placeholder: "请输入验证码",
        requireStar: true,
        clearButtonMode: OverlayVisibilityMode.editing,
        validator: (row) => row.value != "",
        suffixWidget: (context, row) {
          var button = VerifitionCodeButton(
            title: "获取验证码",
            seconds: 60,
            onPressed: () {
              if (isPhoneNumberValid) {
                Utils.showToast("验证码已发送", context, mode: ToastMode.Success);
              } else {
                Utils.showToast("手机号不正确", context, mode: ToastMode.Warning);
              }
            },
          );
          button.isPhoneNumberValid = isPhoneNumberValid;
          return button;
        },
      ),

      // 4
      /// 如果是编辑模式,显示旧密码
      widget.mode == UserMode.edit ?
        TFormRow.input(
          requireStar: true,
          require: true,
          title: "旧密码",
          value: "",
          obscureText: true,
          state: false,
          placeholder: "请输入旧密码",
          clearButtonMode: OverlayVisibilityMode.editing,
          validator: (row) => row.value != "",
          suffixWidget: (context, row) {
            return GestureDetector(
              onTap: () {
                row.state = !row.state;
                row.obscureText = !row.obscureText;
                TForm.of(context).reload();
              },
              child: Icon(
                row.state ? Icons.visibility_off : Icons.visibility,
                size: 20,
              ),
            );
          },
          onChanged: (row) => oldPassword = row.value,
        ) : TFormRow.customCellBuilder(require: false, widgetBuilder: (context, row) => Container()),

      // 5
      TFormRow.input(
        requireStar: true,
        title: widget.mode == UserMode.edit ? "新密码" : "密码",
        value: "",
        obscureText: true,
        state: false,
        placeholder: "请输入密码",
        clearButtonMode: OverlayVisibilityMode.editing,
        validator: (row) => row.value != "",
        suffixWidget: (context, row) {
          return GestureDetector(
            onTap: () {
              row.state = !row.state;
              row.obscureText = !row.obscureText;
              TForm.of(context).reload();
            },
            child: Icon(
              row.state ? Icons.visibility_off : Icons.visibility,
              size: 20,
            ),
          );
        },
        onChanged: (row) => firstPasswd = row.value,
      ),

      // 6
      TFormRow.input(
        requireStar: true,
        title: widget.mode == UserMode.edit ? "再次输入新密码" : "再次输入密码",
        value: "",
        obscureText: true,
        state: false,
        placeholder: "请再次输入密码",
        clearButtonMode: OverlayVisibilityMode.editing,
        validator: (row) => row.value != "",
        suffixWidget: (context, row) {
          return GestureDetector(
            onTap: () {
              row.state = !row.state;
              row.obscureText = !row.obscureText;
              TForm.of(context).reload();
            },
            child: Icon(
              row.state ? Icons.visibility_off : Icons.visibility,
              size: 20,
            ),
          );
        },
      ),

      // 7
      TFormRow.customCellBuilder(
          require: false,
          widgetBuilder: (context, row) {
            return Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    child: Icon(
                      _checkIcon,
                      color: Colors.blue,
                    ),
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size.zero),
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                    ),
                    //color: Colors.orange,
                    onPressed: () {
                      setState(() {
                        _isAgree = !_isAgree;
                        if (_isAgree) {
                          _checkIcon = Icons.check_box;
                        } else {
                          _checkIcon = Icons.check_box_outline_blank;
                        }
                      });
                    },
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('我已详细阅读并同意',
                          style: TextStyle(color: Colors.black, fontSize: 13)),
                      TextButton(
                          onPressed: null,
                          child: Text("《隐私政策》",
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 13))),
                      Text('和',
                          style: TextStyle(color: Colors.black, fontSize: 13)),
                      TextButton(
                          onPressed: null,
                          child: Text("《用户协议》",
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 13))),
                    ],
                  ),
                ],
              ),
            );
          }),

      /*
      TFormRow.customSelector(
        title: "婚姻状况",
        placeholder: "请选择",
        state: [
          ["未婚", "已婚"],
          [
            TFormRow.input(
                title: "配偶姓名", placeholder: "请输入配偶姓名", requireStar: true),
            TFormRow.input(
                title: "配偶电话", placeholder: "请输入配偶电话", requireStar: true)
          ]
        ],
        onTap: (context, row) async {
          String value = await showPicker(row.state[0], context);
          if (row.value != value) {
            if (value == "已婚") {
              TForm.of(context).insert(row, row.state[1]);
            } else {
              TForm.of(context).delete(row.state[1]);
            }
          }
          return value;
        },
      ),
      TFormRow.selector(
        title: "学历",
        placeholder: "请选择",
        options: [
          TFormOptionModel(value: "专科"),
          TFormOptionModel(value: "本科"),
          TFormOptionModel(value: "硕士"),
          TFormOptionModel(value: "博士")
        ],
        //value: "专科"
      ),
      TFormRow.multipleSelector(
        title: "家庭成员",
        placeholder: "请选择",
        options: [
          TFormOptionModel(value: "父亲", selected: false),
          TFormOptionModel(value: "母亲", selected: false),
          TFormOptionModel(value: "儿子", selected: false),
          TFormOptionModel(value: "女儿", selected: false)
        ],

      ),
      TFormRow.customSelector(
        title: "出生年月",
        placeholder: "请选择",
        onTap: (context, row) async {
          return showPickerDate(context);
        },
        fieldConfig: TFormFieldConfig(
          selectorIcon: SizedBox.shrink(),
        ),
      ),
      TFormRow.customCell(
        widget: Container(
            color: Colors.grey[200],
            height: 48,
            width: double.infinity,
            alignment: Alignment.center,
            child: Text("------ 我是自定义的Cell ------")),
      ),

      Expanded(
                    child: RichText(
                        text: TextSpan(text: '我已经详细阅读并同意',
                            style: TextStyle(color: Colors.black, fontSize: 13),
                            children: <TextSpan>[
                              TextSpan(
                                  text: '《隐私政策》', style: TextStyle(color: Colors
                                  .blue, decoration: TextDecoration.underline)),
                              TextSpan(text: '和'),
                              TextSpan(
                                  text: '《用户协议》', style: TextStyle(color: Colors
                                  .blue, decoration: TextDecoration.underline))
                            ])),
                  )
      */
    ];
  }
}
