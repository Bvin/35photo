import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:html/dom.dart' as html;

import '../gallary_page.dart';

class AuthorPage extends StatefulWidget{

  final url;

  AuthorPage(this.url);

  @override
  State<StatefulWidget> createState() {
    return PageState();
  }
}

class PageState extends  State<AuthorPage>{

  Dio _dio;
  bool _showLoading = false;
  List<html.Element> _photos;
  String _lastId = "";
  Map _profile = Map();
  String _user_id = "";

  @override
  void initState() {
    _dio = Dio();
    _photos = List();
    load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(child: body()),
      ),
      theme: ThemeData.dark(),
    );
  }

  load() async {
    Response response = await _dio.get(widget.url, options: Options(
      headers: {"Cookie":"user_login=bvin;token2=300d307489ac74db963ce362ae43833d;nude=true;"}
    ));
    String data = response.data;
    html.Document document = html.Document.html(data);
    html.Element profileContainer = document.getElementsByClassName("container-fluid shadowFont")[0];
    String style = profileContainer.attributes["style"];
    String background = style.substring(style.indexOf('('),style.lastIndexOf(')'));
    html.Element avatarElement = profileContainer.getElementsByClassName("avatar140")[0];
    String avatar = avatarElement.attributes["src"];
    html.Element profileFormElement = profileContainer.getElementsByClassName("col-md-10 userNameBlock thinFont")[0];
    String name = profileFormElement.children[0].text;
    String desc = profileFormElement.children[1].text;
    String place = profileFormElement.children[2].text;
    _profile["background"] = background;
    _profile["avatar"] = avatar;
    _profile["name"] = name;
    _profile["desc"] = desc;
    _profile["place"] = place;
    List<html.Element> counters = profileContainer.getElementsByClassName("col-xs-4");
    _profile["followers"] = counters[0].children[0].children[0].text;
    _profile["photocount"] = counters[1].children[0].children[0].text;
    _profile["view"] = counters[2].children[0].children[0].text;
    setState(() {});

    String param = data.substring(
        data.indexOf("user_id="), data.lastIndexOf("cantSetLike "));
    String user_id = param.substring("user_id=".length, param.indexOf('";'));
    _user_id = user_id;
    String last_id = param.substring(
        param.indexOf("showNextListId") + "showNextListId".length + 1,
        param.lastIndexOf(';'));
    _lastId = last_id;
    loadPhotos();
    print(last_id);
  }

  body() {
    if(_profile.isEmpty){
      return Container();
    }
    return NestedScrollView(
      headerSliverBuilder: (buildContext, innerBoxIsScrolled) =>
      <Widget>[
        SliverAppBar(
          expandedHeight: 200,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(children: <Widget>[
              CachedNetworkImage(imageUrl: _profile["background"]),
              Column(children: <Widget>[
                profile(_profile["avatar"], _profile["name"], _profile["desc"], _profile["place"]),
                countBar(),
              ], mainAxisAlignment: MainAxisAlignment.spaceEvenly,)
            ],),
          ),
        )
      ],
      body: gridBody(),
    );
  }

  profile(avatar,name,desc,place){
    return Row(children: <Widget>[
      CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(avatar),
      ),
      Column(children: <Widget>[
        Text(name,style: TextStyle(fontSize: 20),),
        Text(desc),
        Row(children: <Widget>[
          Icon(Icons.place),
          Text(place, ),
        ],)
      ],),
    ], mainAxisAlignment: MainAxisAlignment.center,);
  }

  countBar(){
    return Row(children: <Widget>[
      countView(_profile["followers"], "followers"),
      countView(_profile["photocount"], "view"),
      countView(_profile["view"], "view photo"),
    ],
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    );
  }
  
  countView(count,text){
    return Column(children: <Widget>[
      Text(count.toString(), style: TextStyle(fontSize: 22),),
      Text(text),
    ],);
  }

  gridBody(){
    List<Widget> children = [];
    if(_photos != null){
      children.add(grid());
    }
    children.add(loading());
    return Stack(children: children,);
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

  loadPhotos() async {
      Response response = await _dio.get("https://m1.35photo.pro/show_block.php",
          options: Options(headers: {
            "Cookie":"user_lang=en; _ga=GA1.2.1675562080.1585727189; _gid=GA1.2.1999997836.1585727189; _fbp=fb.1.1585727189511.1481881805; _ym_uid=15857915721044290429; _ym_d=1585791572; _ym_isad=2; user_login=bvin; token2=300d307489ac74db963ce362ae43833d; user_status=new; nude=true; me=fe9c78a3ad3f2178a32a04050d5de96d; session=6kcskbrq7ngidcgkhr60l9pkuh; user_lastEnter=1585818915 If-Modified-Since: Thu, 02 Apr 2020 09:14:48 GMT",
          }),
          queryParameters: {
            "type": "getNextPageData",
            "page": "photoUser",
            "lastId": _lastId,
            "user_id": _user_id,
          }
      );
      String data = response.data;
      Map map = json.decode(data);
      //_lastId = map["lastId"];
      html.Document document = html.Document.html(map["data"]);
      List<html.Element> elements = document.getElementsByClassName("showPrevPhoto");
      _photos.addAll(elements);
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