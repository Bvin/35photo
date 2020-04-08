import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as html;

class CandidatesPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return PageState();
  }
}

class PageState extends State<CandidatesPage>{

  List<Map> _dataList = List();
  Dio _dio;

  bool _loading = false;

  @override
  void initState() {
    _dio = Dio();
    load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: body(),
      ),
      theme: ThemeData.dark(),
    );
  }

  body() {
    if(_dataList.isEmpty){
      return loading();
    }
    return ListView.builder(
        itemCount: _dataList.length,
        shrinkWrap: true,
        itemBuilder: (ctx, index) => listItem(_dataList[index])
    );
  }

  Widget listItem(map){
    List<String> images = map["images"];
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(map["title"]),
          subtitle: Text(map["subtitle"]),
          trailing: Text("${map["count"]}p"),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: images.length,
            itemBuilder: (ctx, index) =>
                CachedNetworkImage(imageUrl: images[index]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15, left: 8, right: 8),
          child: Divider(color: Colors.white54,),
        )
      ],
    );
  }

  load() async {
    _loading = true;
    setState(() {});
    Response response = await _dio.get("https://35photo.pro/new/contender2/fresh_members/?page=1");
    html.Document document = html.Document.html(response.data);
    html.Element element = document.getElementsByClassName("containerMain")[0].getElementsByClassName("container-fluid")[0];
    element.children.forEach((e){
      print(e.outerHtml);
      Map map = Map();
      if(e.children.length > 0 ) {
        html.Element row = e.children[0];
        if(row.children.isNotEmpty){
          html.Element title = row.children[0];
          map["url"] = title.children[0].attributes["href"];
          map["title"] = title.children[0].text;
          map["subtitle"] = title.children[1].text;
          map["count"] =
              row.getElementsByClassName("col-md-1 col-xs-3")[0].children[0]
                  .children[0].text;
        }
        html.Element imageRow = e.children[1];
        List<String> images = List();
        imageRow.children.forEach((imgChild) {
          images.add(imgChild.children[0].attributes["src"]);
        });
        map["images"] = images;
        _dataList.add(map);
      }
    });
    _loading = false;
    setState(() {});
  }

  loading(){
    return Center(
      child: Visibility(
        child: CircularProgressIndicator(),
        visible: _loading,
      ),
    );
  }
}