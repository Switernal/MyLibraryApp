import 'package:flutter/material.dart';

// Function
import 'package:my_library/MyBook/Function/MyBookRequest.dart';
import 'package:my_library/MyBook/Model/MyBookModel.dart';
import 'package:my_library/Functions/Utils/Utils.dart';

// 输入框控制器
TextEditingController textController = TextEditingController();

// 错误文字
String errorText = null;


class MyBookEditLentOutPage extends StatefulWidget {

  dynamic refreshLentOut;
  String lender;
  MyBookModel book;

  MyBookEditLentOutPage({this.refreshLentOut, this.lender, this.book}) {
    textController.text = lender;
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyBookEditLentOutPageState();
  }
}

class MyBookEditLentOutPageState extends State<MyBookEditLentOutPage> {

  FocusNode _focusNode = FocusNode();

  Future<int> updateLentOut() async {
    // 获取文本
    String lender = textController.text;

    // 开一个请求
    var request = MyBookRequest();
    await request.init();

    // 如果不为空
    if (lender != "") {
      // 设置Book
      widget.book.isLentOut = true;
      widget.book.lender = lender;
      // 发送更新请求
      var statusCode = await request.updateBook(book: widget.book);
      // 返回结果
      return statusCode;
    } else {
      // 如果没有借出人, 返回-2, 表示没有更新
      // 设置Book
      widget.book.isLentOut = false;
      widget.book.lender = "";
      // 发送更新请求
      var statusCode = await request.updateBook(book: widget.book);
      // 返回结果
      return statusCode;
    }
  }

  // 编辑完成回调
  void editingFinish() {
    updateLentOut().then((statusCode) {
      switch (statusCode) {
        case 1:
        // 1:更新成功
          Utils.showToast("借出人更新成功", context, mode: ToastMode.Success);
          break;
        case 0:
        // 0:更新失败
          Utils.showToast("借出人更新失败", context, mode: ToastMode.Error);
          break;
        case -2:
        // 没有更新,直接返回
          break;
        default:
          Utils.showToast("发生未知错误", context, mode: ToastMode.Error);
          break;
      }

      // 刷新页面
      widget.refreshLentOut(textController.text,);
      Navigator.of(context).pop();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    /// 设置焦点在最后
    if (textController.text != "") {
      textController.selection = TextSelection.fromPosition(
        TextPosition(
            affinity: TextAffinity.downstream,
            offset: widget.book.lender.toString().length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("设置借出状态"),
      ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () {
          Utils.showToast("更新中...", context, mode: ToastMode.Loading);
          // 调用详情页的刷新方法
          // 如果输入为空,则默认输入值为""
          editingFinish();
        },
      ),

      body: Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: 30, left: 20, right: 20),
        child: TextField(
          focusNode: _focusNode,
          controller: textController,
          // keyboardType: TextInputType.text,
          maxLines: 1,
          autofocus: true,
          cursorColor: Colors.blue,
          // maxLength: 11,
          maxLengthEnforced: true,
          //focusNode: FocusNode.,
          decoration: InputDecoration(

            border: OutlineInputBorder(),
            hintText: "请输入借出人姓名",
            labelStyle: TextStyle(fontSize: 20),
            labelText: "更新借出状态",
            errorText: errorText,
            //prefixIcon: Icon(Icons.auto_awesome_motion),
            // 未获得焦点边框设为灰色
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            //获得焦点边框设为蓝色
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),

          ),

          onTap: () {
            setState(() {
              FocusScope.of(context).requestFocus(_focusNode);
            });
          },

          onEditingComplete: (){
            _focusNode.unfocus();
            editingFinish();
          },

          /*
          onEditingComplete: () {
            updateLentOut().then((statusCode) {
              switch (statusCode) {
                case 1:
                // 1:更新成功
                  Utils.showToast("借出人更新成功", context);
                  break;
                case 0:
                // 0:更新失败
                  Utils.showToast("借出人更新失败", context);
                  break;
                case -2:
                // 没有更新,直接返回
                  break;
                default:
                  Utils.showToast("未知错误", context);
                  break;
              }

              // 刷新页面
              widget.refreshLentOut(textController.text,);
              Navigator.of(context).pop();
            });
          },

           */

          // 监听输入
          // onChanged: (text) {
          //   if (text != "") {
          //     setState(() {
          //       errorText = null;
          //     });
          //   } else {
          //     setState(() {
          //       errorText = "书柜名不能为空";
          //     });
          //   }
          // },
        ),
      ),
    );
  }
}