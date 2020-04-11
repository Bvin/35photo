import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
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

  Dio _dio;
  Map _photoData;
  List _series;
  List _others;
  String _authorUrl;
  bool _showLoading = false;
  final pageIndexNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    _dio = Dio();
    _dio.interceptors.add(DioCacheManager(CacheConfig()).interceptor);
    load();
    super.initState();
  }

  load() async {
    _showLoading = true;
    setState(() {});
    Response response = await _dio.get(widget.url,
        options: buildCacheOptions(Duration(minutes: 20))
    );
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
        body: page(),
      ),
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
    );
  }

  page(){
    if(_photoData == null){
      return loading();
    }
    int count = pageCount();
    return Stack(
      children: <Widget>[
        PageView.builder(
          onPageChanged: (index) => pageIndexNotifier.value = index,
          itemCount: count,
          itemBuilder: (ctx, index) {
            if(_series == null){
              if(index == 0){
                return image(_photoData["src"]);
              }else{
                return lastPage();
              }
            }else{
              if(index == _series.length){
                return lastPage();
              }else{
                return image(_series[index]["src"]);
              }
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: PageViewIndicator(
            normalBuilder: (animationController, index) => indicator(index, count),
            highlightedBuilder:  (animationController, index) => ScaleTransition(
              scale: CurvedAnimation(
                parent: animationController,
                curve: Curves.ease,
              ),
              child: indicatorOnSelected(index, count),
            ),
            pageIndexNotifier: pageIndexNotifier,
            length: count,
          ),
        ),
      ],
      alignment: FractionalOffset.bottomCenter,
    );
  }

  image(url) {
    return PhotoView(
      imageProvider: CachedNetworkImageProvider(url),
      loadingBuilder: (context, event) =>
          Center(child: CircularProgressIndicator(),),
    );
  }

  indicator(index, count){
    if(index == count - 1){
      return authorIndicator(6.0, Colors.white54);
    }else{
      return photoIndicator(7.0, Colors.white54);
    }
  }

  indicatorOnSelected(index, count){
    if(index == count - 1){
      return authorIndicator(7.0, Colors.white);
    }else{
      return photoIndicator(8.0, Colors.white);
    }
  }

  photoIndicator(size, color){
    return Circle(
      size: size,
      color: color,
    );
  }

  authorIndicator(size, color){
    return Container(
      width: size,
      height: size,
      color: color,
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
    return GestureDetector(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 70, bottom: 30),
            child: author(),
          ),
          Expanded(child: grid(),),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceAround,
      ), onTap: () {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (ctx) => AuthorPage(_authorUrl))
      );
    },
    );
  }

  grid() {
    return GridView.count(
      physics: NeverScrollableScrollPhysics(),
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