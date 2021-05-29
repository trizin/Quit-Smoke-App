import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quitsmoke/constants.dart';
import 'package:quitsmoke/size_config.dart';
import 'package:quitsmoke/static/lang.dart';

class GuideViewScreen extends StatefulWidget {
  GuideViewScreen({Key key, this.id, this.lang}) : super(key: key);
  final String id;
  final String lang;
  @override
  _GuideViewScreenState createState() => _GuideViewScreenState();
}

class _GuideViewScreenState extends State<GuideViewScreen> {
  Map actual = {};
  List<Map> content = [];
  @override
  void initState() {
    actual = langs[widget.lang]["guide"][widget.id];
    content = actual["content"];
    print(content.length);
    super.initState();
  }

  ClipPath buildHeader(BuildContext context) {
    return ClipPath(
      child: Container(
        padding: EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.white, Colors.white]),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Hero(
                  tag: actual["image"],
                  child: SvgPicture.asset(
                    actual["image"],
                    width: getProportionateScreenWidth(150),
                    alignment: Alignment.topCenter,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                AutoSizeText(
                  "${actual["title"]}",
                  style: Theme.of(context).textTheme.headline3.copyWith(
                      color: Colors.black,
                      fontSize: getProportionateScreenWidth(26)),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(actual["title"]),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildHeader(context),
            for (Map i in content)
              buildTextContainer(context, i['title'], i['text'])
          ],
        ),
      ),
    );
  }

  Container buildTextContainer(BuildContext context, String title, var text) {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                blurRadius: 12,
                color: kShadowColor.withAlpha(50),
                offset: Offset(0, 0))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title",
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(fontSize: getProportionateScreenWidth(26)),
            textAlign: TextAlign.left,
          ),
          new Divider(
            color: Colors.grey,
          ),
          text[0].length == 1
              ? Text(
                  "$text",
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                      fontSize: getProportionateScreenWidth(22),
                      color: Colors.black.withOpacity(.8)),
                  textAlign: TextAlign.left,
                )
              : Column(
                  children: [
                    for (String i in text)
                      Column(
                        children: [
                          Text(
                            "$i",
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(
                                    fontSize: getProportionateScreenWidth(22),
                                    color: Colors.black.withOpacity(.8)),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(
                            height: 10,
                          )
                        ],
                      )
                  ],
                )
        ],
      ),
    );
  }
}
