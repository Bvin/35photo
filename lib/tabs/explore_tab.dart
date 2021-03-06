import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:html/dom.dart' as html;
import '../gallary_page.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class ExploreTab extends StatefulWidget{

  final List<Map> authors;

  ExploreTab(this.authors);

  @override
  State<StatefulWidget> createState() {
    return TabState();
  }
}

class TabState extends State<ExploreTab>{

  Dio _dio;
  bool _showLoading = false;
  List<html.Element> _photos;
  int _lastId = 1;

  @override
  void initState() {
    _dio = Dio();
    _photos = List();
    load(_lastId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(child: body()),
      ),
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
    );
  }

  body() {
    return NestedScrollView(
        headerSliverBuilder: (buildContext, innerBoxIsScrolled) => <Widget>[
          SliverAppBar(
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: title(),
            ),
          )
        ],
        body: gridBody(),
    );
  }

  gridBody(){
    List<Widget> children = [];
    if(_photos != null){
      children.add(grid());
    }
    children.add(loading());
    return Stack(children: children,);
  }

  title() {
    return PageView.builder(
        itemCount: widget.authors.length,
        itemBuilder: (ctx, index) => author(widget.authors[index])
    );
  }

  Widget author(map){
    return Padding(padding: EdgeInsets.all(15), child: Column(
      children: <Widget>[
        Row(children: <Widget>[
          Padding(padding: EdgeInsets.only(right: 10, bottom: 10),
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(map["avatar"]),
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 10),
              child: Text(map["author"], style: TextStyle(fontSize: 18),)),
        ],),
        Row(
          children: imgs(map["photos"]),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        )
      ],
    ),);
  }

  List<Widget> imgs(List<Map> maps){
    return maps.map((m) => clickImage(m)).toList();
  }

  Widget clickImage(m){
    return GestureDetector(
      child: CachedNetworkImage(imageUrl: m["img"], fit: BoxFit.cover,height: 100,),
      onTap: (){
        print(m["url"]);
      },
    );
  }

  authors(map){
    return Row(children: <Widget>[
      CircleAvatar(backgroundImage: CachedNetworkImageProvider(map["avatar"]),),
      Text(map["author"]),
    ],);
  }

  images(map){
    return Row(
      children: map["photos"].map((m)=> GestureDetector(
        child: CachedNetworkImage(imageUrl: m["img"]),
        onTap: (){
          print(m["url"]);
        },
      )).toList(),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );
  }

  grid(){
    return StaggeredGridView.countBuilder(
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      crossAxisCount: 2,
      itemCount: _photos.length,
      itemBuilder: (ctx,index)=> GestureDetector(
        child: CachedNetworkImage(imageUrl: _photos[index].attributes["src"]),
        onTap: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => GalleryPage(_photos, index)));
        },
      ),
      staggeredTileBuilder: (index) => StaggeredTile.fit(1),
    );
  }

  loading(){
    return Center(
      child: Visibility(
        child: CircularProgressIndicator(),
        visible: _showLoading,
      ),
    );
  }

  load(lastId) async {
    _showLoading = true;
    setState(() {});
    Response response = await _dio.get("https://m1.35photo.pro/show_block.php",
        options: Options(headers: {
          "Cookie":"user_lang=en; _ga=GA1.2.1675562080.1585727189; _gid=GA1.2.1999997836.1585727189; _fbp=fb.1.1585727189511.1481881805; _ym_uid=15857915721044290429; _ym_d=1585791572; _ym_isad=2; user_login=bvin; token2=300d307489ac74db963ce362ae43833d; user_status=new; nude=true; me=fe9c78a3ad3f2178a32a04050d5de96d; session=6kcskbrq7ngidcgkhr60l9pkuh; user_lastEnter=1585818915 If-Modified-Since: Thu, 02 Apr 2020 09:14:48 GMT",
        }),
        queryParameters: {
          "type": "getNextPageData",
          "page": "new",
          "lastId": lastId,
          "prevNew": true,
          "part": "actual",
        }
    );
    String data = response.data;
    Map map = json.decode(data);
    //_lastId = map["lastId"];
    html.Document document = html.Document.html(map["data"]);
    List<html.Element> elements = document.getElementsByClassName("showPrevPhoto");
    _photos.addAll(elements);
    _showLoading = false;
    setState(() {});
    elements.forEach((e){
      String src = e.attributes["src"];
      String alt = e.attributes["alt"];
      String title = e.attributes["title"];
      print(e);
    });

    //print(map["data"]);
  }
}

