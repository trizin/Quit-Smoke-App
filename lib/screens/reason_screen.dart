import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quitsmoke/size_config.dart';
import 'package:quitsmoke/static/lang.dart';
import 'package:quitsmoke/comps/getlang.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReasonScreen extends StatefulWidget {
  ReasonScreen({Key key}) : super(key: key);

  @override
  _ReasonScreenState createState() => _ReasonScreenState();
}

class _ReasonScreenState extends State<ReasonScreen> {
  String lang;

  List<String> reasons;

  void initState() {
    loadReasons();
    super.initState();
    lang = getLang();
  }

  void loadReasons() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String _reasons = pref.getString("reason");
    if (!_reasons.startsWith("[")) {
      reasons = [_reasons];
      pref.setString("reason", jsonEncode(reasons));
    } else {
      reasons = List<String>.from(jsonDecode(_reasons).map((x) => x));
    }
    setState(() {});
  }

  void saveReasons() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("reason", jsonEncode(reasons));
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      leading: new IconButton(
        icon: new Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Hero(
            tag: "wallet",
            child: Icon(
              Icons.bolt,
              color: Colors.white,
              size: getProportionateScreenWidth(26),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            "${langs[lang]["home"]["reason"]}",
            style: Theme.of(context).textTheme.bodyText2.copyWith(
                color: Colors.white, fontSize: getProportionateScreenWidth(26)),
          )
        ],
      ),
    );
  }

  bool _sheetopen = false;
  final scaffoldState = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      key: scaffoldState,
      appBar: buildAppBar(context),
      floatingActionButton: floatingButton(context),
      backgroundColor: Colors.deepPurple,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        width: double.infinity,
        height: SizeConfig.screenHeight,
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 3,
              child: Center(
                child: Text("${langs[lang]["reason"]["somegoodreasons"]}",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline4.copyWith(
                        color: Colors.white.withAlpha(200),
                        fontWeight: FontWeight.w300,
                        fontSize: getProportionateScreenWidth(36))),
              ),
            ),
            if (reasons != null)
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.only(bottom: 100, top: 10),
                  itemBuilder: (BuildContext context, int index) {
                    return renderListElement(index, context);
                  },
                  itemCount: reasons.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                ),
              )
          ],
        ),
      ),
    );
  }

  String newReason = "";
  FloatingActionButton floatingButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        if (!_sheetopen)
          scaffoldState.currentState.showBottomSheet((context) => Container(
                padding: EdgeInsets.all(15),
                color: Colors.white,
                height: getProportionateScreenHeight(250),
                width: double.infinity,
                child: Column(children: [
                  Text(
                    "${langs[lang]["reason"]["addnew"]}",
                    style: Theme.of(context)
                        .textTheme
                        .headline4
                        .copyWith(fontSize: getProportionateScreenWidth(22)),
                  ),
                  Divider(),
                  TextField(
                    onChanged: (value) => newReason = value,
                    maxLines: 3,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "${langs[lang]["reason"]["reason"]}"),
                    style: Theme.of(context)
                        .textTheme
                        .headline4
                        .copyWith(fontSize: getProportionateScreenWidth(22)),
                  ),
                  ElevatedButton(
                    style: TextButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 20),
                        padding: EdgeInsets.all(8)),
                    child: Text("${langs[lang]["wallet"]["add"]}"),
                    onPressed: () {
                      _sheetopen = false;
                      reasons.add(newReason);
                      newReason = "";
                      saveReasons();
                      setState(() {});
                      Navigator.pop(context);
                    },
                  )
                ]),
              ));
        else
          Navigator.pop(context);
        _sheetopen = !_sheetopen;
      },
      child: Icon(Icons.add, color: Colors.green),
    );
  }

  Widget renderListElement(int index, BuildContext context) {
    return Dismissible(
      key: Key(reasons[index]),
      onDismissed: (direction) {
        reasons.removeAt(index);
        saveReasons();
      },
      confirmDismiss: (DismissDirection direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("${langs[lang]["misc"]["confirm"]}"),
              content: Text("${langs[lang]["misc"]["areusuredelete"]}"),
              actions: <Widget>[
                TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      "${langs[lang]["misc"]["delete"]}",
                      style: TextStyle(color: Colors.red),
                    )),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("${langs[lang]["misc"]["cancel"]}"),
                ),
              ],
            );
          },
        );
      },
      background: Container(
        padding: EdgeInsets.all(getProportionateScreenWidth(20)),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32), color: Colors.red),
        child: Center(
          child: Text(
            "${langs[lang]["misc"]["delete"]}",
            style: TextStyle(
                color: Colors.white, fontSize: getProportionateScreenWidth(22)),
          ),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(getProportionateScreenWidth(20)),
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  blurRadius: 10,
                  color: Colors.deepPurple[600],
                  spreadRadius: 2,
                  offset: Offset(3, 2))
            ],
            borderRadius: BorderRadius.circular(32),
            color: Colors.deepPurple[400]),
        child: Row(
          children: [
            Flexible(
              child: Text("${reasons[index]}",
                  style: Theme.of(context).textTheme.headline4.copyWith(
                      color: Colors.white.withAlpha(200),
                      fontWeight: FontWeight.w300,
                      fontSize: getProportionateScreenWidth(21))),
            )
          ],
        ),
      ),
    );
  }
}
