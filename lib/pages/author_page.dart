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
  int _lastId = 1;
  Map _profile = Map();

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
    );
  }

  load() async {
    Response response = await _dio.get(widget.url);
    html.Document document = html.Document.html(response.data);
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
}