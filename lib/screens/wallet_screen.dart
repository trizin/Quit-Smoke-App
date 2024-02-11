import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quitsmoke/comps/cigaratte.dart';
import 'package:quitsmoke/comps/getlang.dart';
import 'package:quitsmoke/constants.dart';
import 'package:quitsmoke/static/lang.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../size_config.dart';

class WalletScreen extends StatefulWidget {
  final Cigaratte cigaratteManager;

  WalletScreen({Key? key, required this.cigaratteManager}) : super(key: key);

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String lang = "en";
  List<Transaction> trlist = [];
  final scaffoldState = GlobalKey<ScaffoldState>();

  double _amountofmoney = 0;
  String _tstitle = "";
  bool _sheetopen = false;
  bool _details = false;
  String currency = "";

  double get currentBalance {
    double m = 0;
    for (var k in trlist) m += k.price;
    return widget.cigaratteManager.getSavedMoney - m;
  }

  _getTransactions() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    currency = pref.getString("currency") ?? 'unknown';
    var tr = jsonDecode((pref.getString("transactionData") ?? "[]"));
    for (var e in tr) {
      trlist.add(Transaction(
          price: e["price"],
          time: DateTime.parse(e["time"]),
          title: e["title"],
          description: e["description"] ?? ""));
    }
    setState(() {});
  }

  _addTransaction({
    required DateTime date,
    required double price,
    required String title,
    required String description,
  }) {
    if (price > currentBalance) return;
    trlist.insert(
        0,
        Transaction(
            time: date, price: price, title: title, description: description));
    _saveTransaction();
    setState(() {});
  }

  _removeTransaction(int index) async {
    trlist.removeAt(index);
    _saveTransaction();
    setState(() {});
  }

  _saveTransaction() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<Map> lister = [];
    for (var k in trlist) {
      lister.add(k.toJson);
    }
    pref.setString("transactionData", jsonEncode(lister));
  }

  late Timer statetimer;

  @override
  void initState() {
    lang = getLang();
    super.initState();

    _getTransactions();
    statetimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    statetimer.cancel();
    super.dispose();
  }

  String? _tsdescription;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      key: scaffoldState,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!_sheetopen)
            scaffoldState.currentState!.showBottomSheet((context) => Container(
                  padding: EdgeInsets.all(15),
                  color: Colors.white,
                  height: getProportionateScreenHeight(340),
                  width: double.infinity,
                  child: Column(children: [
                    Text(
                      "${langs[lang]["wallet"]["newtransaction"]}",
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontSize: getProportionateScreenWidth(22)),
                    ),
                    TextField(
                      onChanged: (value) => _tstitle = value,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "${langs[lang]["wallet"]["title"]}"),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontSize: getProportionateScreenWidth(22)),
                    ),
                    TextField(
                      onChanged: (value) => _tsdescription = value,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "${langs[lang]["wallet"]["description"]}"),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontSize: getProportionateScreenWidth(22)),
                    ),
                    TextField(
                      onChanged: (value) =>
                          _amountofmoney = double.parse(value),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "${langs[lang]["wallet"]["amount"]}"),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontSize: getProportionateScreenWidth(22)),
                    ),
                    ElevatedButton(
                      style: TextButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 20),
                          padding: EdgeInsets.all(8)),
                      child: Text("${langs[lang]["wallet"]["add"]}"),
                      onPressed: () {
                        _sheetopen = false;
                        _addTransaction(
                            date: DateTime.now(),
                            price: _amountofmoney,
                            title: _tstitle,
                            description: _tsdescription ?? 'unknown');
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
      ),
      appBar: buildAppBar(context),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AspectRatio(
              aspectRatio: _details ? 1 : 2.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${langs[lang]["wallet"]["balance"]}",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white.withAlpha(240),
                        fontWeight: FontWeight.w300),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: AutoSizeText(
                      "${NumberFormat.currency(symbol: currency).format(currentBalance)}",
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                              color: Colors.white,
                              fontSize: getProportionateScreenWidth(42)),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                  _details
                      ? Column(
                          children: [
                            Text(
                              "${langs[lang]["wallet"]["daily"]} ${widget.cigaratteManager.moneyPerSecond * 60 * 60 * 24} $currency",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                      color: Colors.white.withAlpha(200),
                                      fontWeight: FontWeight.w300,
                                      fontSize:
                                          getProportionateScreenWidth(22)),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "${langs[lang]["wallet"]["weekly"]} ${widget.cigaratteManager.moneyPerSecond * 60 * 60 * 24 * 7} $currency",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                      color: Colors.white.withAlpha(200),
                                      fontWeight: FontWeight.w300,
                                      fontSize:
                                          getProportionateScreenWidth(22)),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "${langs[lang]["wallet"]["monthly"]} ${widget.cigaratteManager.moneyPerSecond * 60 * 60 * 24 * 30} $currency",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                      color: Colors.white.withAlpha(200),
                                      fontWeight: FontWeight.w300,
                                      fontSize:
                                          getProportionateScreenWidth(22)),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "${langs[lang]["wallet"]["yearly"]} ${widget.cigaratteManager.moneyPerSecond * 60 * 60 * 24 * 365} $currency",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                      color: Colors.white.withAlpha(200),
                                      fontWeight: FontWeight.w300,
                                      fontSize:
                                          getProportionateScreenWidth(22)),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                      : SizedBox.shrink(),
                  IconButton(
                    icon: Icon(
                      _details ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      size: getProportionateScreenWidth(26),
                    ),
                    onPressed: () {
                      _details = !_details;
                      setState(() {});
                    },
                  )
                ],
              ),
            ),
            SizedBox(
              height: getProportionateScreenHeight(10),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(22),
                        topRight: Radius.circular(22)),
                    boxShadow: [
                      BoxShadow(
                          color: kShadowColor.withOpacity(.3),
                          blurRadius: 7,
                          offset: Offset(0, -3))
                    ]),
                child: ListView.builder(
                  itemCount: trlist.length,
                  itemBuilder: (context, index) {
                    final item = trlist[index];
                    print(item);
                    return Dismissible(
                      key: Key(item.time.toIso8601String()),
                      confirmDismiss: (DismissDirection direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("${langs[lang]["misc"]["confirm"]}"),
                              content: Text(
                                  "${langs[lang]["misc"]["areusuredelete"]}"),
                              actions: <Widget>[
                                TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text(
                                      "${langs[lang]["misc"]["delete"]}",
                                      style: TextStyle(color: Colors.red),
                                    )),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child:
                                      Text("${langs[lang]["misc"]["cancel"]}"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      background: Container(
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.red),
                        child: Center(
                            child: Text(
                          "DELETE",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: getProportionateScreenWidth(32)),
                        )),
                      ),
                      onDismissed: (direction) {
                        _removeTransaction(index);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Transaction removed')));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                  color: kShadowColor.withOpacity(.3),
                                  blurRadius: 7,
                                  offset: Offset(3, 3))
                            ]),
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                          color: Colors.white,
                                          fontSize:
                                              getProportionateScreenWidth(22)),
                                ),
                                if (item.description != null &&
                                    item.description != "" &&
                                    item.description!.length > 2)
                                  Text(
                                    item.description ?? "",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                            color: Colors.grey[100],
                                            fontSize:
                                                getProportionateScreenWidth(
                                                    16)),
                                  ),
                                Text(
                                  DateFormat.yMMMMEEEEd().format(item.time),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                          color: Colors.white70,
                                          fontSize:
                                              getProportionateScreenWidth(16)),
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: FittedBox(
                                child: Text(
                                  "${NumberFormat.currency(symbol: currency).format(item.price)}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                          color: Colors.white,
                                          fontSize:
                                              getProportionateScreenWidth(25)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
      backgroundColor: Colors.green,
    );
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
              Icons.account_balance_wallet,
              color: Colors.white,
              size: getProportionateScreenWidth(26),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            "${langs[lang]["home"]["wallet"]}",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white, fontSize: getProportionateScreenWidth(26)),
          )
        ],
      ),
    );
  }
}

class Transaction {
  final double price;
  final DateTime time;
  final String title;
  final String? description;

  get toJson =>
      {"price": price, "time": time.toIso8601String(), "title": title};

  Transaction({
    required this.price,
    required this.time,
    required this.title,
    this.description = "",
  });
}
