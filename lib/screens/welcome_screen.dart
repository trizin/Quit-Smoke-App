import 'dart:convert';
import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:quitsmoke/comps/getlang.dart';
import 'package:quitsmoke/comps/snappable.dart';
import 'package:quitsmoke/size_config.dart';
import 'package:quitsmoke/static/currencies.dart';
import 'package:quitsmoke/static/lang.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  WelcomeScreen({Key key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  List<String> reason = [];
  String currentReason;
  String lang = "";
  final myController = TextEditingController();
  final myController2 = TextEditingController();
  final myController3 = TextEditingController();
  double pricePerCigaratte;
  int dailycigarattes;
  int index = 0;
  String currency;
  final snapKey = GlobalKey<SnappableState>();

  @override
  void initState() {
    stopDate = DateTime.now();
    super.initState();
    lang = getLang();
  }

  bool starting = false;
  _startNow() async {
    if (pricePerCigaratte == null ||
        dailycigarattes == null ||
        reason == null ||
        reason.length == 0 ||
        currency == null) return false;
    setState(() {
      starting = true;
    });
    snapKey.currentState.snap();

    SharedPreferences pref = await SharedPreferences.getInstance();
    Future.delayed(Duration(seconds: 5), () {
      pref.setString("startTime", stopDate.toIso8601String());
      pref.setDouble("pricePerCigaratte", pricePerCigaratte);
      pref.setInt("dailycigarattes", dailycigarattes);
      pref.setString("currency", currency);
      pref.setString("reason", jsonEncode(reason));

      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
    });
  }

  Widget router(BuildContext context, int i) {
    switch (i) {
      case 0:
        return Container(
          height: SizeConfig.screenHeight / 1.4,
          padding: EdgeInsets.all(25),
          child: Column(
            children: [
              Text(langs[lang]["welcome"]["welcometext"],
                  style: Theme.of(context).textTheme.headline4,
                  textAlign: TextAlign.center,
                  textScaleFactor: 1),
              SizedBox(height: getProportionateScreenHeight(50)),
              Text(
                langs[lang]["welcome"]["tellreason"],
                style: Theme.of(context).textTheme.headline4.copyWith(
                    fontSize: getProportionateScreenWidth(22),
                    color: Colors.black.withAlpha(150)),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: getProportionateScreenHeight(15),
              ),
              TextField(
                controller: myController,
                textAlign: TextAlign.center,
                maxLines: 1,
                onChanged: (value) => currentReason = value,
                decoration: InputDecoration(
                    hintText: langs[lang]["welcome"]["reasonhint"]),
              ),
              Column(
                children: [
                  TextButton(
                      onPressed: () {
                        if (currentReason.trim() == "") return false;
                        if (reason.contains(currentReason.trim())) return false;
                        reason.add(currentReason.trim());
                        currentReason = "";
                        myController.clear();
                        setState(() {});
                      },
                      child: Text(
                          "\u{2795} ${langs[lang]["welcome"]["addtolist"]}"))
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: reason
                        .map((e) => Row(
                              children: [
                                Text("${reason.indexOf(e) + 1}. "),
                                Expanded(
                                  child: Text(
                                    e,
                                    style: TextStyle(
                                        fontSize:
                                            getProportionateScreenWidth(20)),
                                  ),
                                )
                              ],
                            ))
                        .toList(),
                  ),
                ),
              ),
              SizedBox.shrink()
            ],
          ),
        );
      case 1:
        return Container(
          padding: EdgeInsets.all(25),
          child: Column(
            children: [
              Text(
                langs[lang]["welcome"]["weneedtoknow"],
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    .copyWith(fontSize: getProportionateScreenWidth(32)),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: getProportionateScreenHeight(55),
              ),
              TextFormField(
                controller: myController2,
                onChanged: (value) => dailycigarattes = int.parse(value),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: new InputDecoration(
                  labelText: langs[lang]["welcome"]["howmanyperday"],
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(),
                  ),

                  //fillColor: Colors.green
                ),
              ),
              SizedBox(
                height: getProportionateScreenHeight(15),
              ),
              TextFormField(
                controller: myController3,
                onChanged: (value) => pricePerCigaratte =
                    double.parse(value.replaceAll(",", ".")),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: new InputDecoration(
                  labelText: langs[lang]["welcome"]["howmuchpercigcost"],
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(),
                  ),
                  //fillColor: Colors.green
                ),
              ),
              SizedBox(
                height: getProportionateScreenHeight(15),
              ),
              FittedBox(
                child: DropdownButton<String>(
                  value: currency ?? null,
                  hint: Text(
                    langs[lang]["welcome"]["choosecurrency"],
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(fontSize: getProportionateScreenWidth(26)),
                  ),
                  items: currencyList.map((Map value) {
                    return DropdownMenuItem<String>(
                      value: value["symbol"],
                      child: new Text("${value["name"]} ${value["symbol"]}"),
                    );
                  }).toList(),
                  onChanged: (p) {
                    currency = p;
                    setState(() {});
                  },
                ),
              ),
              SizedBox(
                height: getProportionateScreenHeight(15),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text("${langs[lang]["settings"]["youstopped"]}"),
                      Text(
                        "${DateFormat.yMMMMEEEEd().format(stopDate)}\n${DateFormat.Hms().format(stopDate)}",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  OutlineButton(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    onPressed: () => _pickDate(context),
                    child: Text(
                      "${langs[lang]["settings"]["change"]}",
                      textAlign: TextAlign.center,
                    ),
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColor, width: 2),
                  ),
                ],
              ),
            ],
          ),
        );
      case 2:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Snappable(
                key: snapKey,
                child: Image.asset("./assets/images/cigarette.png",
                    width: getProportionateScreenWidth(200),
                    height: getProportionateScreenWidth(200)),
              ),
              if (!starting)
                AvatarGlow(
                  glowColor: Colors.blue,
                  endRadius: 180.0,
                  duration: Duration(milliseconds: 2000),
                  repeat: true,
                  showTwoGlows: false,
                  repeatPauseDuration: Duration(milliseconds: 100),
                  child: ElevatedButton(
                    child: Text(langs[lang]["welcome"]["start"]),
                    onPressed: () => _startNow(),
                  ),
                ),
            ],
          ),
        );
    }
    return Container();
  }

  DateTime stopDate;

  _pickDate(BuildContext context) async {
    DateTime date = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime.now(),
      initialDate: stopDate,
    );

    TimeOfDay t =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (date != null && t != null)
      setState(() {
        stopDate = date;
        stopDate = stopDate.add(Duration(hours: t.hour, minutes: t.minute));
      });
    print(stopDate);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            router(context, index),
            Expanded(
              child: Text(""),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildpageindicator(0),
                    SizedBox(
                      width: 5,
                    ),
                    buildpageindicator(1),
                    SizedBox(
                      width: 5,
                    ),
                    buildpageindicator(2),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (index == 0 || starting) return false;
                      setState(() {
                        index -= 1;
                      });
                    },
                    icon: Icon(
                      Icons.keyboard_arrow_left,
                      size: getProportionateScreenWidth(32),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (index == 2 || starting) return false;
                      setState(() {
                        if (reason.length != 0 && index == 0 ||
                            (index == 1 &&
                                !(pricePerCigaratte == null ||
                                    dailycigarattes == null ||
                                    currency == null))) index += 1;
                      });
                    },
                    icon: Icon(
                      Icons.keyboard_arrow_right,
                      size: getProportionateScreenWidth(32),
                    ),
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
            ),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

  AnimatedContainer buildpageindicator(int i) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 100),
      width: index == i ? 15 : 10,
      height: 10,
      decoration: BoxDecoration(
          color: index == i ? Colors.blue : Colors.grey,
          borderRadius: BorderRadius.circular(20)),
    );
  }
}
