import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:quitsmoke/comps/cigaratte.dart';
import 'package:quitsmoke/comps/getlang.dart';
import 'package:quitsmoke/comps/progress_painter.dart';
import 'package:quitsmoke/static/htimes.dart';
import 'package:quitsmoke/static/lang.dart';

import '../size_config.dart';

class ProgressPage extends StatefulWidget {
  final Cigaratte cigaratteManager;
  ProgressPage({Key key, this.cigaratteManager}) : super(key: key);

  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  String lang = "";
  Timer statetimer;
  @override
  void initState() {
    super.initState();
    lang = getLang();
    statetimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    statetimer.cancel();
    super.dispose();
  }

  String _converToText(Duration passed, Duration requiredTime) {
    if (requiredTime.inDays > passed.inDays) {
      return "${requiredTime.inDays - passed.inDays} ${langs[lang]["process"]["daysleft"]}";
    } else if (requiredTime.inSeconds > passed.inSeconds) {
      Duration diff = requiredTime - passed;
      return "${diff.inHours}:${diff.inMinutes % 60}:${diff.inSeconds % 60} ${langs[lang]["process"]["minleft"]}";
    } else {
      return "${langs[lang]["process"]["completed"]}";
    }
  }

  double _getPercentage(Duration passed, Duration requiredTime) =>
      passed > requiredTime
          ? 100
          : 100 -
              ((requiredTime.inSeconds - passed.inSeconds) /
                  requiredTime.inSeconds *
                  100);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        backgroundColor: Colors.blue,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: htimes.length,
                  itemBuilder: (context, i) {
                    return Container(
                        decoration: BoxDecoration(),
                        padding:
                            EdgeInsets.all(getProportionateScreenWidth(16)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Column(
                                children: [
                                  AutoSizeText(
                                    _converToText(
                                        widget.cigaratteManager
                                            .calculatePassedTime(),
                                        htimes[i]["time"]),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(
                                            color: Colors.white,
                                            fontSize:
                                                getProportionateScreenWidth(
                                                    22)),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                  ),
                                  AutoSizeText(
                                    langs[lang]["progressDescription"]
                                        [htimes[i]["id"]],
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4
                                        .copyWith(
                                            color: Colors.white,
                                            fontSize:
                                                getProportionateScreenWidth(
                                                    15)),
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                width: getProportionateScreenHeight(42),
                                height: getProportionateScreenHeight(42),
                                child: CustomPaint(
                                  child: Center(
                                    child: _getPercentage(
                                                widget.cigaratteManager
                                                    .calculatePassedTime(),
                                                htimes[i]["time"]) ==
                                            100
                                        ? Icon(
                                            Icons.check,
                                            color: Colors.lightGreenAccent,
                                          )
                                        : AutoSizeText(
                                            "${htimes[i]["time"].inDays - widget.cigaratteManager.calculatePassedTime().inDays}",
                                            style: TextStyle(
                                              color: Colors.lightGreenAccent,
                                            ),
                                            maxLines: 1,
                                            textScaleFactor: 1.0),
                                  ),
                                  painter: ProgressPainter(
                                      completedPercentage: _getPercentage(
                                          widget.cigaratteManager
                                              .calculatePassedTime(),
                                          htimes[i]["time"]),
                                      circleWidth: 10,
                                      defaultCircleColor:
                                          Colors.lightGreenAccent,
                                      percentageCompletedCircleColor:
                                          Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ));
                  }),
            )
          ],
        ),
        appBar: buildAppBar(context));
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      leading: new IconButton(
        icon: new Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Hero(
            tag: "progress",
            child: Icon(
              Icons.timelapse,
              color: Colors.white,
              size: getProportionateScreenWidth(26),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            "${langs[lang]["home"]["progress"]}",
            style: Theme.of(context).textTheme.bodyText2.copyWith(
                color: Colors.white, fontSize: getProportionateScreenWidth(26)),
          )
        ],
      ),
    );
  }
}
