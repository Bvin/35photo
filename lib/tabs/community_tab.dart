import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as html;
import 'package:photo35/pages/comnu_page.dart';

class CommunityTab extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return PageState();
  }
}

class PageState extends State<CommunityTab>{

  List<Map> communities = List();
  bool _showLoading = false;
  Dio _dio;

  @override
  void initState() {
    _dio = Dio();
    _dio.interceptors.add(DioCacheManager(CacheConfig()).interceptor);
    load();
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    if(communities.isEmpty){
      return loading();
    }
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      children: communities.map((map) => item(map)).toList(),
    );
  }

  Widget item(map) {
    List<String> images = map["images"];
    return GestureDetector(
      child: Card(
        child: Column(
          children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(map["name"]),
          ),
          Expanded(
            child: GridView.count(
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              shrinkWrap: true,
              children: images.map((img) => CachedNetworkImage(imageUrl: img))
                  .toList()
          ),
          ),
        ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ),
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder:
            (ctx) => CommunityPage(map["url"])));
      },
    );
  }

  load() async {
    _showLoading = true;
    setState(() {});
    Response response = await _dio.get("https://35photo.pro/community/",
        options: buildCacheOptions(Duration(hours: 3)));
    html.Document document = html.Document.html(response.data);
    html.Element element = document.getElementsByClassName("containerMain")[0];
    html.Element center = element.children[0].children[0].children[0];//center
    center.children.forEach((e){
      if(e.children.length==2){
        Map map = Map();
        html.Element title = e.children[0].children[0];//title/a
        map["url"] = title.attributes["href"];
        map["name"] = title.text;
        List<String> images = List();
        e.children[1].children.forEach((item){
          html.Element img = item.getElementsByTagName("img")[0];
          images.add(img.attributes["src"]);
        });
        map["images"] = images;
        communities.add(map);
      }
    });
    _showLoading = false;
    setState(() {});
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