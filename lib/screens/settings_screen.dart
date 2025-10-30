import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quitsmoke/comps/getlang.dart';
import 'package:quitsmoke/static/currencies.dart';
import 'package:quitsmoke/static/lang.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../size_config.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String lang = "";
  late int? dailyCigarattes;
  late double? pricePerCigaratte;
  late String? currency;
  late final TextEditingController controllerday;
  late final TextEditingController controllercost;

  @override
  void initState() {
    controllercost = TextEditingController();
    controllerday = TextEditingController();
    lang = getLang();
    loadData();
    super.initState();
  }

  Future<void> loadData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    dailyCigarattes = pref.getInt("dailycigarattes");
    pricePerCigaratte = pref.getDouble("pricePerCigaratte");
    currency = pref.getString("currency");
    stopDate = (DateTime.tryParse(pref.getString("startTime") ?? '')) ??
        DateTime.now();

    controllerday.text = dailyCigarattes.toString();
    controllercost.text = pricePerCigaratte.toString();
    setState(() {});
  }

  saveData() async {
    if (pricePerCigaratte == null ||
        dailyCigarattes == null ||
        currency == null) return false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setDouble("pricePerCigaratte", pricePerCigaratte!);
    pref.setInt("dailycigarattes", dailyCigarattes!);
    pref.setString("currency", currency!);
    pref.setString("startTime", stopDate.toIso8601String());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              controller: controllerday,
              onChanged: (value) => dailyCigarattes = int.parse(value),
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
              controller: controllercost,
              onChanged: (value) =>
                  pricePerCigaratte = double.parse(value.replaceAll(",", ".")),
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
                      .bodyMedium
                      ?.copyWith(fontSize: getProportionateScreenWidth(26)),
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50),
                  child: OutlinedButton(
                    onPressed: () => _pickDate(context),
                    child: Text(
                      "${langs[lang]["settings"]["change"]}",
                      textAlign: TextAlign.center,
                    ),
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Theme.of(context).primaryColor, width: 2)),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Text(""),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: OutlinedButton(
                onPressed: () => saveData(),
                child: Text(langs[lang]["settings"]["save"]),
                style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: Theme.of(context).primaryColor, width: 2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  late DateTime stopDate;

  _pickDate(BuildContext context) async {
    DateTime? date = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime.now(),
      initialDate: stopDate,
    );

    TimeOfDay? t =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (date != null && t != null)
      setState(() {
        stopDate = date;
        print(t.hour);
        stopDate = stopDate.add(Duration(hours: t.hour, minutes: t.minute));
      });
    print(stopDate);
  }

  AppBar buildAppBar(BuildContext context) {
    SizeConfig().init(context);
    return AppBar(
      leading: new IconButton(
        icon: new Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Hero(
            tag: "settings",
            child: Icon(
              Icons.settings,
              color: Colors.black,
              size: getProportionateScreenWidth(26),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            "${langs[lang]["home"]["settings"]}",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black, fontSize: getProportionateScreenWidth(26)),
          )
        ],
      ),
    );
  }
}
