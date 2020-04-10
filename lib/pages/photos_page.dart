import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:page_view_indicator/page_view_indicator.dart';
import 'package:photo_view/photo_view.dart';
import 'author_page.dart';

class PhotosPage extends StatefulWidget{

  final String url;

  PhotosPage(this.url);

  @override
  State<StatefulWidget> createState() {
    return PageState();
  }
}
class PageState extends State<PhotosPage>{

  var _dio;
  Map _photoData;
  List _series;
  List _others;
  String _authorUrl;
  bool _showLoading = false;
  final pageIndexNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    _dio = Dio();
    load();
    super.initState();
  }

  load() async {
    _showLoading = true;
    setState(() {});
    Response response = await _dio.get(widget.url);
    String html = response.data;
    String startPref = "photoData = ";
    int start = html.indexOf(startPref) + startPref.length;
    int end = html.lastIndexOf("};") + 1;
    String json = html.substring(start,end);
    _photoData = jsonDecode(json);
    if(_photoData.containsKey("series")){
      _series = _photoData["series"];
    }
    _others = _photoData["other_photos"];
    print(_series);

    dom.Document document = dom.Document.html(response.data);
    dom.Element element = document.getElementById("userAvatar");
    _authorUrl = element.attributes["href"];
    _showLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(child: page()),
      ),
      theme: ThemeData.dark(),
    );
  }

  page(){
    if(_photoData == null){
      return loading();
    }
    return Stack(
      children: <Widget>[
        PageView.builder(
          onPageChanged: (index) => pageIndexNotifier.value = index,
          itemCount: pageCount(),
          itemBuilder: (ctx, index) {
            if(_series == null){
              if(index == 0){
                return PhotoView(imageProvider: CachedNetworkImageProvider(_photoData["src"]));
              }else{
                return lastPage();
              }
            }else{
              if(index == _series.length){
                return lastPage();
              }else{
                return PhotoView(imageProvider: CachedNetworkImageProvider(_series[index]["src"]));
              }
            }
          },
        ),
        PageViewIndicator(
          normalBuilder: (animationController, index) => Circle(
            size: 8.0,
            color: Colors.black87,
          ),
          highlightedBuilder:  (animationController, index) => ScaleTransition(
            scale: CurvedAnimation(
              parent: animationController,
              curve: Curves.ease,
            ),
            child: Circle(
              size: 12.0,
              color: Colors.accents.elementAt((index + 3) * 3),
            ),
          ),
          pageIndexNotifier: pageIndexNotifier,
          length: pageCount(),
        ),
      ],
      alignment: FractionalOffset.bottomCenter,
    );
  }

  pageCount(){
    return _series == null ? 2 : _series.length + 1;
  }

  loading(){
    return Center(
      child: Visibility(
        child: CircularProgressIndicator(),
        visible: _showLoading,
      ),
    );
  }

  lastPage(){
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: 70),
          child: GestureDetector(
            child: author(),
            onTap: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>AuthorPage(_authorUrl)));
            },
          ),
        ),
        Expanded(child: grid(),),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceAround,
    );
  }

  grid() {
    return GridView.count(
      crossAxisCount: 3,
      children: _others.map((map) => CachedNetworkImage(imageUrl: map["src"])).toList(),
    );
  }

  author(){
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 50),
          child: Text(_photoData["user_name"], style: TextStyle(fontSize: 22),),
        ),
        Row(
          children: <Widget>[
          countView(Icons.remove_red_eye, _photoData["photo_see"]),
          countView(Icons.favorite, _photoData["photo_fav"]),
          countView(Icons.star, _photoData["photo_rating"]),
        ],
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        )
      ],
    );
  }

  countView(icon, count){
    return Column(
      children: <Widget>[
        Icon(icon),
        Text(count.toString()),
      ],
    );
  }
}