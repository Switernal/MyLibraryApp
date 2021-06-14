import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:my_library/MyBook/Function/MyBookRequest.dart';

class BookStatisticsCell extends StatefulWidget {

  // 行
  int index = 0;

  BookStatisticsCell({ @required this.index});

  @override
  State<StatefulWidget> createState() {

    // TODO: implement createState
    return BookStatisticsCellState();
  }
}

class BookStatisticsCellState extends State<BookStatisticsCell> {

  /// 1. 藏书数量
  int totalBooks = 0;
  /// 2. 书架藏书比例
  Map<String, int> countsInEachShelf = {};
  /// 3. 作者数量
  int totalAuthors = 0;
  /// 4. 各个作者藏书数量
  Map<String, int> countsOfEachAuthor = {};
  /// 5. 出版社数量
  int totalPresses = 0;
  /// 6. 各个出版社数量
  Map<String, int> countsOfEachPress = {};

  Widget customArea() {

    switch (widget.index) {
      case 0:
        return totalBookArea();
        break;
      case 1:
        break;
      case 2:
        break;
      case 3:
        break;
      case 4:
        break;
      case 5:
        break;
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {

    // 卡片Cell
    return Container(

      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            spreadRadius: 2,
            color: Color.fromARGB(20, 0, 0, 0),
          ),
        ],
      ),

      child: Column(
        children: [
          countsInEachShelfArea(),
        ],
      ),
    );
  }

  /// 1. 藏书数量
  Future getTotalBooks() async {
    // totalBooks = await MyBookRequest().
  }
  Widget totalBookArea() {
    return Container(
      child: Row(
        children: [
          Text("藏书数量", style: TextStyle(fontSize: 16),),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("总藏书数量"),
              Text("${totalBooks} 本"),
            ],
          ),
        ],
      ),
    );
  }

  /// 2. 书架藏书比例
  Future getCountsInEachShelf() async {
    // totalBooks = await MyBookRequest().
  }
  Widget countsInEachShelfArea() {
    return Container(
      child: Column(
        children: [
          Text("藏书数量", style: TextStyle(fontSize: 16),),
          Divider(),
          AspectRatio(
            aspectRatio: 1,
            child: PieChart(
              PieChartData(
                  pieTouchData: PieTouchData(touchCallback: (pieTouchResponse) {
                    setState(() {
                      final desiredTouch = pieTouchResponse.touchInput is! PointerExitEvent &&
                          pieTouchResponse.touchInput is! PointerUpEvent;
                      if (desiredTouch && pieTouchResponse.touchedSection != null) {
                        touchedIndex = pieTouchResponse.touchedSectionIndex;
                      } else {
                        touchedIndex = -1;
                      }
                    });
                  }),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: showingSections()),
              ),
            ),
        ],
      ),
    );
  }
  int touchedIndex = -1;
  List<PieChartSectionData> showingSections() {
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: const Color(0xff0293ee),
            value: 40,
            title: '40%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xffffffff)),
          );
        case 1:
          return PieChartSectionData(
            color: const Color(0xfff8b250),
            value: 30,
            title: '30%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xffffffff)),
          );
        case 2:
          return PieChartSectionData(
            color: const Color(0xff845bef),
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xffffffff)),
          );
        case 3:
          return PieChartSectionData(
            color: const Color(0xff13d38e),
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xffffffff)),
          );
        default:
          throw Error();
      }
    });
  }
}

