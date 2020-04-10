import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:photo35/pages/photos_page.dart';

class HomeTab extends StatefulWidget{

  final List<Map> recommend;

  HomeTab(this.recommend);

  @override
  State<StatefulWidget> createState() {
    return TabState();
  }
}

class TabState extends State<HomeTab>{


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return grid();
  }

  grid(){
    return StaggeredGridView.countBuilder(
      itemCount: widget.recommend.length,
        crossAxisCount: 4,
        crossAxisSpacing: 1,
        mainAxisSpacing: 3,
        padding: EdgeInsets.only(left: 2,right: 2,top: 24),
        itemBuilder: (ctx,index){
          if(index<4){
            return gridItem(widget.recommend[index]);
          }else{
            return cardItem(widget.recommend[index]);
          }
        },
        staggeredTileBuilder: (index){
          if(index<4){
            return StaggeredTile.count(2, 3);
          }else{
            return StaggeredTile.count(index.isEven?1:3, 2);
          }
        },
    );
  }

  Widget gridItem(map){
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(map["genre"],style: TextStyle(fontSize: 12),),
          ),
          Expanded(
            child: GestureDetector(
              child: Stack(
                children: <Widget>[
                  CachedNetworkImage(imageUrl: map["img"], fit: BoxFit.cover,),
                  Positioned(
                    bottom: 5,
                    left: 5,
                    child: Text(map["author"],style: TextStyle(fontSize: 12),),
                  ),
                ],
                fit: StackFit.expand,
                alignment: Alignment.bottomRight,
              ),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => PhotosPage(map["url"])));
              },
            ),
          )
        ],
        mainAxisSize: MainAxisSize.max,
      ),
      color: Colors.black,
    );
  }

  Widget cardItem(map) {
    return click(Container(
      child: Stack(
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(map["avatar"]),),
            title: Text(map["title"]),
            subtitle: Text(map["subtitle"]),
          )
        ],
        alignment: Alignment.bottomLeft,
      ),
      decoration: map["img"] == null ? null : BoxDecoration(
          image: DecorationImage(
              image: CachedNetworkImageProvider(map["img"]),
              fit: BoxFit.cover
          )
      ),
    ), (){
      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => PhotosPage(map["url"])));
    });
  }

  click(child, onTap) {
    return GestureDetector(child: child, onTap: onTap,);
  }

}