import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quitsmoke/comps/cigaratte.dart';
import 'package:quitsmoke/comps/getlang.dart';
import 'package:quitsmoke/comps/particlePainer.dart';
import 'package:quitsmoke/comps/progress_painter.dart';
import 'package:quitsmoke/constants.dart';
import 'package:quitsmoke/screens/guide_screen.dart';
import 'package:quitsmoke/screens/progress_screen.dart';
import 'package:quitsmoke/screens/reason_screen.dart';
import 'package:quitsmoke/screens/settings_screen.dart';
import 'package:quitsmoke/screens/wallet_screen.dart';
import 'package:quitsmoke/size_config.dart';
import 'package:quitsmoke/static/lang.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'guideview_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Cigaratte cigaraManager;
  String lang = "";
  String currency = "";
  String tiptext = "";

  Future<void> loadData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    currency = pref.getString("currency");

    cigaraManager = Cigaratte(
        dailyCigarattes: pref.getInt("dailycigarattes"),
        pricePerCigaratte: pref.getDouble("pricePerCigaratte"),
        startDate: DateTime.parse(pref.getString("startTime")));
  }

  int lastRndInt = -1;
  @override
  void initState() {
    loadData();
    lang = getLang();

    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
    Random rnd = new Random();
    int rndInt = rnd.nextInt(langs[lang]["tipsandfacts"].length);
    while (rndInt == lastRndInt)
      rndInt = rnd.nextInt(langs[lang]["tipsandfacts"].length);
    lastRndInt = rndInt;
    tiptext = langs[lang]["tipsandfacts"][rndInt];
    tipOpacity = 1;
    Timer(Duration(seconds: 8), () {
      tipOpacity = 0;
      setState(() {});
    });
    Timer.periodic(Duration(seconds: 10), (timer) {
      tipOpacity = 1;
      tiptext = langs[lang]["tipsandfacts"]
          [rnd.nextInt(langs[lang]["tipsandfacts"].length)];
      setState(() {});
      Timer(Duration(seconds: 8), () {
        tipOpacity = 0;
        setState(() {});
      });
    });
  }

  showAlertDialog(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text(
        "${langs[lang]["home"]["cancel"]}",
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget helpButton = FlatButton(
      child: Text(
        "${langs[lang]["guide"]["ifyouslip"]["title"]}",
      ),
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return GuideViewScreen(id: "ifyouslip", lang: lang);
        }));
      },
    );
    Widget helpButton2 = FlatButton(
      child: Text(
        "${langs[lang]["guide"]["managecravings"]["title"]}",
      ),
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return GuideViewScreen(id: "managecravings", lang: lang);
        }));
      },
    );
    Widget continueButton = FlatButton(
      child: Text(
        "${langs[lang]["home"]["reset"]}",
        style: TextStyle(color: Colors.red),
      ),
      onPressed: () async {
        Navigator.of(context).pop();
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString("startTime", DateTime.now().toIso8601String());
        loadData();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("${langs[lang]["home"]["resetall"]}"),
      content: Text("${langs[lang]["home"]["resetallq"]}"),
      actions: [
        continueButton,
        helpButton,
        helpButton2,
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  double tipOpacity = 0;

  @override
  Widget build(BuildContext context) {
    if (cigaraManager == null) return Text("");
    Size sc = MediaQuery.of(context).size;
    SizeConfig().init(context);
    return Scaffold(
      appBar: buildAppBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: getProportionateScreenHeight(20),
          ),
          AspectRatio(
            aspectRatio: 2.2,
            child: Stack(
              children: [
                ParticlePainterWidget(
                  widgetSize: MediaQuery.of(context).size,
                ),
                CustomPaint(
                  painter: ProgressPainter(
                    completedPercentage: cigaraManager.getdayPercentage,
                    circleWidth: 15,
                    defaultCircleColor: Colors.lightGreen,
                    percentageCompletedCircleColor:
                        Colors.grey.withOpacity(0.2),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${cigaraManager.getdayPercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                              fontSize: getProportionateScreenWidth(52),
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                    color: kShadowColor.withOpacity(.2),
                                    blurRadius: 32)
                              ]),
                        ),
                        Text(
                          '${langs[lang]["home"]["day"].toUpperCase()} ${cigaraManager.calculatePassedTime().inDays + 1}',
                          style: TextStyle(
                            fontSize: getProportionateScreenWidth(26),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 1000),
              opacity: tipOpacity,
              child: FittedBox(
                child: Text(
                  tiptext,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: getProportionateScreenWidth(14)),
                ),
              ),
            ),
          ),
          SizedBox(
            height: getProportionateScreenHeight(15),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: getProportionateScreenWidth(15),
                ),
                buildCategoryCard(sc, context,
                    color: Colors.green,
                    icon: Icons.account_balance_wallet,
                    text: "${langs[lang]["home"]["wallet"]}",
                    id: "wallet", onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return WalletScreen(
                      cigaratteManager: cigaraManager,
                    );
                  }));
                }),
                SizedBox(
                  width: getProportionateScreenWidth(15),
                ),
                buildCategoryCard(sc, context,
                    color: Colors.blue,
                    icon: Icons.timelapse,
                    text: "${langs[lang]["home"]["progress"]}",
                    id: "progress", onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return ProgressPage(
                      cigaratteManager: cigaraManager,
                    );
                  }));
                }),
                SizedBox(
                  width: getProportionateScreenWidth(15),
                ),
                buildCategoryCard(sc, context,
                    color: Colors.red,
                    icon: Icons.book,
                    text: "${langs[lang]["home"]["guide"]}",
                    id: "guide", onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return GuideScreen(
                      cigaratteManager: cigaraManager,
                    );
                  }));
                }),
                SizedBox(
                  width: getProportionateScreenWidth(15),
                ),
                buildCategoryCard(sc, context,
                    color: Colors.deepPurple,
                    icon: Icons.bolt,
                    text: "${langs[lang]["home"]["reason"]}asd",
                    id: "reasons", onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return ReasonScreen();
                  }));
                }),
                SizedBox(
                  width: getProportionateScreenWidth(15),
                ),
                buildCategoryCard(sc, context,
                    color: Colors.grey,
                    icon: Icons.settings,
                    text: "${langs[lang]["home"]["settings"]}",
                    id: "settings", onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return SettingsScreen();
                  })).then((value) => loadData());
                }),
                SizedBox(
                  width: getProportionateScreenWidth(15),
                ),
              ],
            ),
          ),
          SizedBox(
            height: getProportionateScreenHeight(5),
          ),
          IconButton(
            icon: Icon(
              Icons.settings_backup_restore,
              size: getProportionateScreenWidth(32),
              color: Colors.red,
            ),
            onPressed: () => showAlertDialog(context),
          ),
          Text(
            "${_converToText(cigaraManager.calculatePassedTime(), cigaraManager.upcomingEvent["time"])}",
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(fontSize: getProportionateScreenWidth(18)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: AutoSizeText(
              "${langs[lang]["progressDescription"][cigaraManager.upcomingEvent["id"]]}",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyText1,
              maxLines: 2,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                buildInfoCard(
                    context,
                    "${cigaraManager.calculatePassedTime().inDays} ${langs[lang]["home"]["day"].toLowerCase()}, ${cigaraManager.calculatePassedTime().inHours % 24} ${langs[lang]["home"]["hour"].toLowerCase()}, ${cigaraManager.calculatePassedTime().inMinutes % 60} ${langs[lang]["home"]["minute"].toLowerCase()}, ${cigaraManager.calculatePassedTime().inSeconds % 60} ${langs[lang]["home"]["second"].toLowerCase()}",
                    "${langs[lang]["home"]["timePassed"]}",
                    Icons.timer,
                    Colors.teal),
                buildInfoCard(
                    context,
                    "${NumberFormat.currency(symbol: currency).format(cigaraManager.getSavedMoney)}",
                    "${langs[lang]["home"]["moneyEarned"]}",
                    Icons.account_balance_wallet,
                    Colors.green),
                buildInfoCard(
                    context,
                    "${NumberFormat("#,###").format(cigaraManager.getsavedCigarattes.round())}",
                    "${langs[lang]["home"]["cigarratesnotsmoked"]}",
                    Icons.smoke_free,
                    Colors.red)
              ],
            ),
          ),
          Expanded(child: SizedBox.shrink()),
          buildBottom(),
          SizedBox(
            height: getProportionateScreenHeight(25),
          )
        ],
      ),
    );
  }

  Row buildBottom() {
    int days = cigaraManager.calculatePassedTime().inDays;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (int i in cigaraManager.generateDayItem)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: getProportionateScreenWidth(days > 100
                    ? 3
                    : days > 10
                        ? 6
                        : 10),
              ),
              buildDayItem(
                  count: i % 365,
                  checked: cigaraManager.calculatePassedTime().inDays + 1 > i,
                  current: cigaraManager.calculatePassedTime().inDays + 1 == i),
              SizedBox(
                width: getProportionateScreenWidth(days > 100
                    ? 3
                    : days > 10
                        ? 6
                        : 10),
              ),
            ],
          )
      ],
    );
  }

  String _converToText(Duration passed, Duration requiredTime) {
    if (requiredTime.inDays > passed.inDays) {
      return "${langs[lang]["home"]["daysafter"].replaceAll("X", (requiredTime.inDays - passed.inDays).toString())}";
    } else if (requiredTime.inSeconds > passed.inSeconds) {
      Duration diff = requiredTime - passed;
      return "${diff.inHours}:${diff.inMinutes % 60}:${diff.inSeconds % 60} ${langs[lang]["home"]["minafter"]}";
    }
    return "";
  }

  Column buildDayItem({int count, bool checked, bool current}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        checked
            ? Icon(
                Icons.check,
                color: Colors.green,
              )
            : current
                ? Icon(
                    Icons.adjust,
                    color: Colors.green,
                  )
                : Icon(
                    Icons.adjust,
                    color: Theme.of(context).backgroundColor,
                  ),
        SizedBox(
          height: 4,
        ),
        Container(
          padding: EdgeInsets.all(getProportionateScreenWidth(12)),
          decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(getProportionateScreenWidth(24)),
              color: checked ? Colors.lightGreen : Colors.grey[100],
              boxShadow: [
                BoxShadow(
                    color: kShadowColor.withOpacity(.32),
                    blurRadius: 12,
                    offset: Offset(5, 5)),
                BoxShadow(
                    color: Colors.white, blurRadius: 12, offset: Offset(-5, -5))
              ]),
          child: AutoSizeText(
            "$count",
            style: TextStyle(color: checked ? Colors.white : Colors.grey),
            maxLines: 1,
          ),
        )
      ],
    );
  }

  Padding buildInfoCard(BuildContext context, String title, String text,
      IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.all(getProportionateScreenWidth(20)),
      child: SizedBox(
        width: getProportionateScreenWidth(222),
        child: Container(
          height: getProportionateScreenHeight(150),
          padding: EdgeInsets.all(getProportionateScreenWidth(20)),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(context).primaryIconTheme.color,
              ),
              color: Theme.of(context).backgroundColor,
              boxShadow: [
                BoxShadow(
                    color: kShadowColor.withOpacity(.32),
                    offset: Offset(6, 6),
                    blurRadius: 12)
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: getProportionateScreenWidth(150),
                    child: AutoSizeText(
                      title,
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                          fontSize: getProportionateScreenWidth(16),
                          color: color),
                      maxLines: 2,
                    ),
                  ),
                  Icon(
                    icon,
                    size: getProportionateScreenWidth(28),
                  ),
                ],
              ),
              SizedBox(height: 5),
              AutoSizeText(
                text,
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: getProportionateScreenWidth(14)),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  InkWell buildCategoryCard(Size sc, BuildContext context,
      {Color color, IconData icon, String text, String id, Function onTap}) {
    return InkWell(
      onTap: onTap,
      child: Ink(
        padding: EdgeInsets.symmetric(
            horizontal: 10, vertical: getProportionateScreenHeight(15)),
        decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).primaryIconTheme.color,
            ),
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).backgroundColor,
            boxShadow: [
              BoxShadow(
                  color: Colors.white,
                  blurRadius: 15,
                  offset: Offset(-4, -4),
                  spreadRadius: 1.0),
            ]),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: getProportionateScreenWidth(120),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: id,
                child: Icon(
                  icon,
                  color: color,
                  size: getProportionateScreenWidth(26),
                ),
              ),
              SizedBox(
                width: 3,
              ),
              AutoSizeText(
                text,
                style: Theme.of(context).textTheme.headline4.copyWith(
                    color: color,
                    fontSize: getProportionateScreenWidth(20),
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      actions: [],
    );
  }
}
