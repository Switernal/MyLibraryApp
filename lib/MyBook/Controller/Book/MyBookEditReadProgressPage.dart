import 'package:flutter/material.dart';
// Function
import 'package:my_library/MyBook/Function/MyBookRequest.dart';
import 'package:my_library/MyBook/Model/MyBookModel.dart';
import 'package:my_library/Functions/Utils/Utils.dart';

// 输入框控制器
TextEditingController textController = TextEditingController();

// 错误文字
String errorText = null;

class MyBookEditReadProgressPage extends StatefulWidget {
  
  dynamic refreshReadProgress;
  int readProgress;
  MyBookModel book;

  MyBookEditReadProgressPage({this.refreshReadProgress, this.readProgress, this.book}) {
    errorText = null;
    textController.text = readProgress == 0 ? "" : readProgress.toString();
  }
  
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyBookEditReadProgressPageState();
  }
}

class MyBookEditReadProgressPageState extends State<MyBookEditReadProgressPage> {

  FocusNode _focusNode = FocusNode();

  Future<int> updateReadProgress() async {
    // 获取文本
    String readProgress = textController.text;
    // 如果不为空
    if (readProgress != "") {
      // 开一个请求
      var request = MyBookRequest();
      await request.init();
      // 设置Book
      widget.book.readProgress = int.parse(readProgress, onError: (error) {return 0;});

      print(widget.book);
      // 发送更新请求
      var statusCode = await request.updateBook(book: widget.book);
      // 返回结果
      return statusCode;
    } else {
      // 如果没有设置页码, 返回-2, 表示没有更新
      return -2;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    /// 设置焦点在最后
    if (textController.text != "") {
      textController.selection = TextSelection.fromPosition(
        TextPosition(
            affinity: TextAffinity.downstream,
            offset: widget.book.readProgress.toString().length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("设置阅读状态"),
      ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () {

          if (int.tryParse(textController.text) == null) {
            setState(() {
              errorText = "只能输入0~${widget.book.totalPages}的整数";
            });
          }

          if (errorText != null) {
            return;
          }

          Utils.showToast("更新中...", context, mode: ToastMode.Loading, duration: 5);

          // 调用详情页的刷新方法
          // 如果输入为空,则默认输入值为0

          updateReadProgress().then((statusCode) {
            switch (statusCode) {
              case 1:
              // 1:更新成功
                Utils.showToast("阅读进度更新成功", context, mode: ToastMode.Success);
                break;
              case 0:
              // 0:更新失败
                Utils.showToast("阅读进度更新失败", context, mode: ToastMode.Error);
                break;
              case -2:
              // 没有更新,直接返回
                break;
              default:
                Utils.showToast("发生未知错误", context, mode: ToastMode.Error);
                break;
            }

            // 刷新页面
            widget.refreshReadProgress(
                int.parse(textController.text, onError: (error) { return 0; })
            );
            Navigator.of(context).pop();
          });

        },
      ),

      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(_focusNode),
        child: Padding(
          padding: EdgeInsets.only(top: 30, left: 20, right: 20),
          child: TextField(
            onTap: () => FocusScope.of(context).requestFocus(_focusNode),
            focusNode: _focusNode,
            controller: textController,
            keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
            maxLines: 1,
            autofocus: true,
            cursorColor: Colors.blue,
            // maxLength: 11,
            maxLengthEnforced: true,
            //focusNode: FocusNode.,
            decoration: InputDecoration(

              border: OutlineInputBorder(),
              hintText: "请输入当前阅读到的页码",
              labelStyle: TextStyle(fontSize: 20),
              labelText: "更新阅读进度",
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

            // 监听输入
            onChanged: (text) {
              int inputProgress = int.parse(textController.text);
              if (widget.book.totalPages > 0 && (inputProgress > widget.book.totalPages || inputProgress < 0)) {
                setState(() {
                  errorText = "全书共${widget.book.totalPages}页，只能输入0~${widget.book.totalPages}之间的整数";
                });
              } else {
                setState(() {
                  errorText = null;
                });
              }
            },
          ),
        ),
      ),
    );
  }
}