import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart'as html;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PageState();
  }
}

class PageState extends State<MyApp>{

  List<Map> _genres;

  @override
  void initState() {
    loadGenres();
    super.initState();
  }

  loadHtml() async {
    Dio dio = Dio();
    Response response = await dio.get("https://35photo.pro/genre/");
    html.Document document = html.Document.html(response.data);
    List<html.Element> element = document.getElementsByClassName("parentGenre");
    element.forEach((e){
      html.Element element1 = e.children[0];
      var style = element1.attributes["style"];
      RegExp regExp = RegExp("http.*?jpg");
      Match match = regExp.firstMatch(style);
      String background = match.group(0);
      print(background);
    });
  }

  loadGenres(){
    _genres = <Map>[
      {"category_id":0,"category_name":"Home","display_name":"Home",},
      {"category_id":1,"category_name":"action","display_name":"Action",},
      {"category_id":2,"category_name":"macro","display_name":"Macro",},
      {"category_id":3,"category_name":"humour","display_name":"Humour",},
      {"category_id":4,"category_name":"mood","display_name":"Mood",},
      {"category_id":5,"category_name":"wildlife","display_name":"Wildlife",},
      {"category_id":6,"category_name":"landscape","display_name":"Landscape",},
      {"category_id":7,"category_name":"street","display_name":"Street",},
      {"category_id":8,"category_name":"documentary","display_name":"Documentary",},
      {"category_id":9,"category_name":"night","display_name":"Night",},
      {"category_id":10,"category_name":"creative-edit","display_name":"Creative Edit",},
      {"category_id":11,"category_name":"architecture","display_name":"Architecture",},
      {"category_id":12,"category_name":"fine-art-nude","display_name":"Fine-art-nude",},
      {"category_id":13,"category_name":"portrait","display_name":"Portrait",},
      {"category_id":14,"category_name":"everyday","display_name":"Everyday",},
      {"category_id":15,"category_name":"abstract","display_name":"Abstract",},

      {"category_id":17,"category_name":"conceptual","display_name":"Conceptual",},
      {"category_id":18,"category_name":"still-life","display_name":"Still-life",},
      {"category_id":19,"category_name":"performance","display_name":"Performance",},
      {"category_id":20,"category_name":"underwater","display_name":"Underwater",},
      {"category_id":21,"category_name":"animals","display_name":"Animals",},
    ];
  }

  @override
  Widget build(BuildContext context) {
    loadHtml();
    return Container();
  }
}
