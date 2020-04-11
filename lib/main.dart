import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';
import 'package:photo35/pages/condidates_page.dart';
import 'package:photo35/tabs/explore_tab.dart';
import 'genres_page.dart';
import 'tabs/community_tab.dart';
import 'tabs/home_tab.dart';
import 'package:html/dom.dart' as html;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PageState();
  }
}

class PageState extends State<MyApp>{

  List<Widget> _tabBodies;
  int currentPage = 0;
  Dio _dio;
  List<Map> recommend;
  List<Map> authors;
  Widget _body;

  @override
  void initState() {
    _dio = Dio();
    _dio.interceptors.add(DioCacheManager(CacheConfig()).interceptor);
    recommend = List();
    authors = List();
    loadHtml();
    super.initState();
  }

  loadGenres(){
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: _tabBodies == null ? Container() : _body == null
            ? _tabBodies[currentPage]
            : _body,
        bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.home), title: Text("Home")),
              BottomNavigationBarItem(
                  icon: Icon(Icons.explore), title: Text("Explore")),
              BottomNavigationBarItem(
                  icon: Icon(Icons.flag), title: Text("Community")),
              BottomNavigationBarItem(
                  icon: Icon(Icons.category), title: Text("Genres")),
            ],
          currentIndex: currentPage,
          onTap: (index){
            currentPage = index;
            setState(() {});
          },
        ),
        drawer: Drawer(child: ListView(
          children: <Widget>[
            ListTile(title: Text("Home"), onTap: (){
              _body = _tabBodies[currentPage];
              setState(() {});
            },),
            ListTile(title: Text("Candidates"), onTap: (){
              _body = CandidatesPage();
              setState(() {});
            },),
          ],
        ),),
      ),
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
    );
  }


  loadHtml() async {
    Response response = await _dio.get("https://35photo.pro/",
        options: buildCacheOptions(Duration(minutes: 20), options: Options(
            headers: {
              "Cookie":"user_login=bvin;token2=300d307489ac74db963ce362ae43833d;nude=true;"
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
        )),
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

    List<html.Element> part2 = document.getElementsByClassName("col-md-6 shadowFont");
    part2.forEach((e){//aimg||gradientMainGenre
      Map map = Map();
      html.Element e0 = e.children[0];//a
      if ("a".compareTo(e0.localName) != 0) {
        e0 = e0.getElementsByTagName("a")[0];
      }
      map["url"] = e0.attributes["href"];//
      map["img"] = e0.children[0].attributes["src"];

      html.Element e1 = e.children[1].children[0];//
      map["avatar"] = e1.children[0].attributes["src"];
      map["title"] = e1.children[1].text;
      map["subtitle"] = e1.children[2].text;
      recommend.add(map);
    });

    List<html.Element> authorsElement = document.getElementsByClassName("col-md-6");
    print(authorsElement.length);
    authorsElement.forEach((e){
      if(e.children.length == 2) {
        Map map = Map();
        html.Element c1 = e.children[0]; //第一行
        if(c1.children.length == 3){
          map["avatar"] = c1.children[0].attributes["src"];
          map["author"] = c1.children[1].text;
          map["url"] = c1.children[1].attributes["href"];
          html.Element c2 = e.children[1]; //第2行
          List<Map> images = List();
          c2.children.forEach((e) {
            Map map = Map();
            html.Element a = e.children[0]; //a
            map["url"] = a.attributes["href"];
            String src = a.children[0].attributes["src"]; //img
            if (src != null) {
              map["img"] = src;
              images.add(map);
            }
          });
          map["photos"] = images;
          authors.add(map);
        }
      }
    });


    _tabBodies = [
      HomeTab(recommend),
      ExploreTab(authors),
      CommunityPage(),
      GenresPage()
    ];
    setState(() {});
  }
}
