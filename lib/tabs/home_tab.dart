import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as html;

class HomeTab extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return TabState();
  }
}

class TabState extends State<HomeTab>{

  Dio _dio;
  List<Map> recommend;

  @override
  void initState() {
    _dio = Dio();
    recommend = List();
    loadHtml();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return
        GridView.count(crossAxisCount: 2,
        childAspectRatio: 1.3,
        children:recommend.map(
                (map)=>gridItem(map["genre"], map["img"], map["author"])
        ).toList(),)
      ;
  }

  Widget gridItem(genre,imageUrl, author){
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(genre,),
          ),
          Expanded(
            child: Container(
              child: Stack(
                children: <Widget>[
                  CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover,),
                  Positioned(
                    bottom: 0,
                    left: 1,
                    child: Text(author,),
                  ),
                ],
                fit: StackFit.expand,
                alignment: Alignment.bottomRight,
              ),
            ),
          )
        ],
        mainAxisSize: MainAxisSize.max,
      ),
    );
  }

  card(imageUrl, avatarUrl, title, subtitle) {
    return Stack(
      children: <Widget>[
        CachedNetworkImage(imageUrl: imageUrl),
        ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl),),
          title: Text(title),
          subtitle: Text(subtitle),
        )
      ],
    );
  }

  loadHtml() async {
    Response response = await _dio.get("https://35photo.pro/",
        options: Options(
          headers: {
            "Cookie":"user_login=bvin;token2=300d307489ac74db963ce362ae43833d;"
          }
            //Cookie: user_lang=en;
          // _ga=GA1.2.1675562080.1585727189;
          // _gid=GA1.2.1999997836.1585727189;
          // _fbp=fb.1.1585727189511.1481881805;
          // _ym_uid=15857915721044290429;
          // _ym_d=1585791572;
          // user_login=bvin;
          // token2=300d307489ac74db963ce362ae43833d;
          // user_status=new;
          // me=1c8288be0961a35ce165492f52a4ed1d;
          // nude=true;
          // _ym_isad=2;
          // PHPSESSID=a0m6l632om2m4sqr3140tp7qf2;
          // user_lastEnter=1585880109;
          // session=a0m6l632om2m4sqr3140tp7qf2;
          // _gat=1;
          // _ym_visorc_52086456=w
        )
    );
    html.Document document = html.Document.html(response.data);
    List<html.Element> elements = document.getElementsByClassName("col-md-3 col-xs-6");
    elements.forEach((e){
      Map map = Map();
      map["genre"] = e.children[0].text;
      html.Element children1 = e.getElementsByClassName("parentGenre")[0];
      String href = children1.attributes["onclick"];
      map["url"] = href.substring(href.indexOf('\'')+1,href.lastIndexOf('\''),);
      String style = children1.children[0].attributes["style"];
      map["img"] = style.substring(style.indexOf("https"),style.indexOf("jpg")+3);
      map["author"] = children1.children[1].text;
      //print(map);
      recommend.add(map);
    });
    setState(() {});
  }
}